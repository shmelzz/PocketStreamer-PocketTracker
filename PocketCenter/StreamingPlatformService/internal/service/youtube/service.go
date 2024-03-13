// https://developers.google.com/youtube/v3/code_samples/go
package ytbot

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/user"
	"path/filepath"
	"streamingservice/internal/config"
	"strings"

	"golang.org/x/net/context"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

type YoutubeService struct {
	localConfig config.Config
}

func NewYoutubeService(cfg config.Config) *YoutubeService {
	return &YoutubeService{
		localConfig: cfg,
	}
}

// This variable indicates whether the script should launch a web server to
// initiate the authorization flow or just display the URL in the terminal
// window. Note the following instructions based on this setting:
// * launchWebServer = true
//  1. Use OAuth2 credentials for a web application
//  2. Define authorized redirect URIs for the credential in the Google APIs
//     Console and set the RedirectURL property on the config object to one
//     of those redirect URIs. For example:
//     config.RedirectURL = "http://localhost:8090"
//  3. In the startWebServer function below, update the URL in this line
//     to match the redirect URI you selected:
//     listener, err := net.Listen("tcp", "localhost:8090")
//     The redirect URI identifies the URI to which the user is sent after
//     completing the authorization flow. The listener then captures the
//     authorization code in the URL and passes it back to this script.
//
// * launchWebServer = false
//  1. Use OAuth2 credentials for an installed application. (When choosing
//     the application type for the OAuth2 client ID, select "Other".)
//  2. Set the redirect URI to "urn:ietf:wg:oauth:2.0:oob", like this:
//     config.RedirectURL = "urn:ietf:wg:oauth:2.0:oob"
//  3. When running the script, complete the auth flow. Then copy the
//     authorization code from the browser and enter it on the command line.
const launchWebServer = true

// getClient uses a Context and Config to retrieve a Token
// then generate a Client. It returns the generated Client.
func (y *YoutubeService) GetClient(isNew bool, authUrlChan chan string, scope ...string) (*http.Client, error) {
	ctx := context.Background()

	fmt.Println(y.localConfig.GoogleSecret.ClientSecret)
	b := []byte(y.localConfig.GoogleSecret.ClientSecret)

	// If modifying the scope, delete your previously saved credentials
	// at ~/.credentials/youtube-go.json
	config, err := google.ConfigFromJSON(b, scope...)
	if err != nil {
		log.Fatalf("Unable to parse client secret file to config: %v", err)
	}

	// Use a redirect URI like this for a web app. The redirect URI must be a
	// valid one for your OAuth2 credentials.
	// config.RedirectURL = "http://localhost:8090"
	// Use the following redirect URI if launchWebServer=false in oauth2.go
	config.RedirectURL = y.localConfig.GoogleSecret.OathRedirectUrl

	cacheFile, err := y.tokenCacheFile()
	if err != nil {
		log.Fatalf("Unable to get path to cached credential file. %v", err)
	}

	tok, err := y.tokenFromFile(cacheFile)

	if err != nil || isNew {
		authURL := config.AuthCodeURL("state-token", oauth2.AccessTypeOffline)
		authUrlChan <- authURL
		if launchWebServer {
			fmt.Println("Trying to get token from web")
			tok, err = y.getTokenFromWeb(y.localConfig, config, authURL)
		} else {
			fmt.Println("Trying to get token from prompt")
			tok, err = y.getTokenFromPrompt(config, authURL)
		}
		if err == nil {
			y.saveToken(cacheFile, tok)
		}
	}
	return config.Client(ctx, tok), err
}

// startWebServer starts a web server that listens on http://localhost:8080.
// The webserver waits for an oauth code in the three-legged auth flow.
func (y *YoutubeService) startWebServer(cfg config.Config) (codeCh chan string, err error) {
	host := strings.Replace(cfg.GoogleSecret.OathRedirectUrl, "http://", "", 1)
	listener, err := net.Listen("tcp", host)
	if err != nil {
		return nil, err
	}
	codeCh = make(chan string) // js-> create new promise

	go http.Serve(listener, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		code := r.FormValue("code")
		codeCh <- code // send code to OAuth flow  // js-> resolve-promise
		listener.Close()
		w.Header().Set("Content-Type", "text/plain")
		fmt.Fprintf(w, "Received code: %v\r\nYou can now safely close this browser window.", code)
	}))

	return codeCh, nil // js-> return promise
}

// openURL opens a browser window to the specified location.
// This code originally appeared at:
//
//	http://stackoverflow.com/questions/10377243/how-can-i-launch-a-process-that-is-not-a-file-in-go
func (y *YoutubeService) openURL(url string) error {
	// var err error
	// switch runtime.GOOS {
	// case "linux":
	// 	err = exec.Command("xdg-open", url).Start()
	// case "windows":
	// 	err = exec.Command("rundll32", "url.dll,FileProtocolHandler", "http://localhost:4001/").Start()
	// case "darwin":
	// 	err = exec.Command("open", url).Start()
	// default:
	// 	err = fmt.Errorf("cannot open URL %s on this platform", url)
	// }
	// return err
	return nil
}

// Exchange the authorization code for an access token
func (y *YoutubeService) exchangeToken(config *oauth2.Config, code string) (*oauth2.Token, error) {
	tok, err := config.Exchange(context.Background(), code)

	if err != nil {
		log.Fatalf("Unable to retrieve token %v", err)
	}
	return tok, nil
}

// getTokenFromPrompt uses Config to request a Token and prompts the user
// to enter the token on the command line. It returns the retrieved Token.
func (y *YoutubeService) getTokenFromPrompt(config *oauth2.Config, authURL string) (*oauth2.Token, error) {
	var code string
	fmt.Printf("Go to the following link in your browser. After completing "+
		"the authorization flow, enter the authorization code on the command "+
		"line: \n%v\n", authURL)

	if _, err := fmt.Scan(&code); err != nil {
		log.Fatalf("Unable to read authorization code %v", err)
	}
	return y.exchangeToken(config, code)
}

// getTokenFromWeb uses Config to request a Token.
// It returns the retrieved Token.
func (y *YoutubeService) getTokenFromWeb(localcfg config.Config, config *oauth2.Config, authURL string) (*oauth2.Token, error) {
	codeCh, err := y.startWebServer(localcfg)
	if err != nil {
		fmt.Printf("Unable to start a web server.")
		return nil, err
	}

	err = y.openURL(authURL)
	if err != nil {
		log.Fatalf("Unable to open authorization URL in web server: %v", err)
	} else {
		fmt.Println("Your browser has been opened to an authorization URL.",
			"This program will resume once authorization has been provided.")
		fmt.Println()
		fmt.Println(authURL)
	}

	// Wait for the web server to get the code.
	code := <-codeCh
	return y.exchangeToken(config, code)
}

// tokenCacheFile generates credential file path/filename.
// It returns the generated credential path/filename.
func (y *YoutubeService) tokenCacheFile() (string, error) {
	usr, err := user.Current()
	if err != nil {
		return "", err
	}
	tokenCacheDir := filepath.Join(usr.HomeDir, ".credentials")
	os.MkdirAll(tokenCacheDir, 0700)
	return filepath.Join(tokenCacheDir,
		url.QueryEscape("youtube-go.json")), err
}

// tokenFromFile retrieves a Token from a given file path.
// It returns the retrieved Token and any read error encountered.
func (y *YoutubeService) tokenFromFile(file string) (*oauth2.Token, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, err
	}
	t := &oauth2.Token{}
	err = json.NewDecoder(f).Decode(t)
	defer f.Close()
	return t, err
}

// saveToken uses a file path to create a file and store the
// token in it.
func (y *YoutubeService) saveToken(file string, token *oauth2.Token) {
	fmt.Println("trying to save token")
	fmt.Printf("Saving credential file to: %s\n", file)
	f, err := os.OpenFile(file, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		log.Fatalf("Unable to cache oauth token: %v", err)
	}
	defer f.Close()
	json.NewEncoder(f).Encode(token)
}
