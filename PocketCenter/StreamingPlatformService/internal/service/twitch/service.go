package twitchbot

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"streamingservice/internal/config"
	"streamingservice/internal/model"
	"time"

	"github.com/gempir/go-twitch-irc/v4"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"
	twitchOauth "golang.org/x/oauth2/twitch"
)

type TwichService struct {
	Config config.TwitchConfig
}

func NewTwichService(cfg config.TwitchConfig) *TwichService {
	return &TwichService{
		Config: cfg,
	}
}

func (t *TwichService) GetTwitchChannelIsLive(token *oauth2.Token, id string) (bool, error) {
	url := fmt.Sprintf("https://api.twitch.tv/helix/streams?user_id=%s", id)
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return false, err
	}
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token.AccessToken))
	req.Header.Set("Client-Id", t.Config.ClientId)
	resp, err := client.Do(req)
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()

	// Check the response status code and print the error message if necessary
	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("Response not ok")
	} else {
		var twitchResp model.GetStreamResponse
		if err := json.NewDecoder(resp.Body).Decode(&twitchResp); err != nil {
			return false, fmt.Errorf("Cant parse json")
		}
		if len(twitchResp.Data) == 0 {
			return false, nil
		} else if twitchResp.Data[0].UserID != id {
			return false, fmt.Errorf("Cant find user")
		}

		return true, nil
	}
}

func (t *TwichService) GetTwitchUserId(token *oauth2.Token, login string) (string, error) {
	url := fmt.Sprintf("https://api.twitch.tv/helix/users?login=%s", login)
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token.AccessToken))
	req.Header.Set("Client-Id", t.Config.ClientId)
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	// Check the response status code and print the error message if necessary
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("Response not ok")
	} else {
		var twitchResp model.GetTwitchUserResponse
		if err := json.NewDecoder(resp.Body).Decode(&twitchResp); err != nil {
			return "", fmt.Errorf("Cant parse json")
		}
		if len(twitchResp.Data) == 0 || twitchResp.Data[0].DisplayName != login {
			return "", fmt.Errorf("Cant find user")
		}
		return twitchResp.Data[0].ID, nil
	}
}

func (t *TwichService) GetTwitchClientToken() (*oauth2.Token, error) {
	var oauth2Config *clientcredentials.Config
	oauth2Config = &clientcredentials.Config{
		ClientID:     t.Config.ClientId,
		ClientSecret: t.Config.ClientSecret,
		TokenURL:     twitchOauth.Endpoint.TokenURL,
	}

	return oauth2Config.Token(context.Background())
}

func (t *TwichService) ConnectToTwitchChat(messages chan model.LiveChatMessage, channelName string) {
	client := twitch.NewAnonymousClient()

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		go func() {
			messages <- model.LiveChatMessage{
				Username: message.User.DisplayName,
				Message:  message.Message,
			}
		}()
	})

	client.Join(channelName)

	client.SendPings = true
	client.IdlePingInterval = time.Second * 30

	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
