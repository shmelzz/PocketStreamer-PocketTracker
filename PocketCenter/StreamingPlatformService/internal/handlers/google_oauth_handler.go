package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"streamingservice/internal/model"
	"streamingservice/internal/service"
	twitchbot "streamingservice/internal/service/twitch"
	ytbot "streamingservice/internal/service/youtube"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"google.golang.org/api/youtube/v3"
)

type GoogleOAuthHandler struct {
	userAuthAddress  string
	youtubeService   *ytbot.YoutubeService
	broadcastService *service.BroadcastService
	actionService    *service.PocketActionService
}

func NewGoogleOAuthHandler(
	userAuthAddress string,
	youtubeService *ytbot.YoutubeService,
	broadcastService *service.BroadcastService,
	actionService *service.PocketActionService,
) *GoogleOAuthHandler {
	return &GoogleOAuthHandler{
		userAuthAddress:  userAuthAddress,
		youtubeService:   youtubeService,
		broadcastService: broadcastService,
		actionService:    actionService,
	}
}

// Login godoc
// @Summary Login use oath
// @Description Login, get url to login in google account
// @Tags login
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Param StreamId header string true "StreamId"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /google/login [get]
func (g *GoogleOAuthHandler) Login(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	streamId := c.Request.Header.Get("StreamId")
	ok, err := g.validateToken(token)
	if err != nil {
		zap.S().Errorf(err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"message": "Error when try to validate"})
		return
	}
	if !ok {
		zap.S().Infof("Validation not passed")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Validation not passed"})
		return
	}

	ch := make(chan string)
	go func() {
		client, err := g.youtubeService.GetClient(true, ch, youtube.YoutubeScope)
		fmt.Println("Get client")
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		chatBot := ytbot.NewLiveChatBot(&ytbot.LiveChatBotInput{
			Urls:         []string{streamId},
			RefetchCache: true,
		}, client)
		chatReader := chatBot.ChatReaders[streamId]

		for {
			select {
			case msg := <-chatReader:
				fmt.Println(msg.Message)
				jsonBytes, _ := json.Marshal(msg)
				g.broadcastService.Broadcast(jsonBytes, c.Request.Header.Get("SessionId")) // Use your Broadcast function here to broadcast the received message
			}
		}
	}()
	url := <-ch
	fmt.Println(url)
	c.JSON(http.StatusOK, gin.H{"oauth_url": url})
}

func (g *GoogleOAuthHandler) validateToken(token string) (bool, error) {
	// Create a new request to the userauthsessionservice
	zap.S().Debug(g.userAuthAddress + "/auth/validate")
	req, err := http.NewRequest("POST", g.userAuthAddress+"/auth/validate", nil)
	if err != nil {
		return false, err
	}

	// Add the token to the request header
	req.Header.Add("Authentication", token)

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		zap.S().Debug(err.Error())
		return false, err
	}
	defer resp.Body.Close()

	// Check the response
	if resp.StatusCode != http.StatusOK {
		return false, nil
	}

	return true, nil
}

// Websocket connect handler
func (g *GoogleOAuthHandler) HandleReceiver(c *gin.Context) {
	r := c.Request
	w := c.Writer
	token := r.Header.Get("Authentication")
	sessionId := r.Header.Get("SessionId")
	platform := r.Header.Get("Platform")

	ok, err := g.validateToken(token)
	if err != nil {
		zap.S().Error(err)
		c.JSON(http.StatusBadRequest, "Error when try to validate")
		return
	}
	if !ok {
		zap.S().Info("Validation not passed")
		c.JSON(http.StatusUnauthorized, "Validation not passed")
		return
	}

	client, err := g.broadcastService.AddTracker(w, r)
	if err != nil {
		zap.S().Error(err)
		g.broadcastService.RemoveTrackerClient(sessionId)
		return
	}

	if platform == "twitch" {
		channelName := r.Header.Get("Channel")
		messagesCh := make(chan model.LiveChatMessage)
		go func() {
			twitchbot.ConnectToTwitch(messagesCh, channelName)
		}()
		go func() {
			for {
				select {
				case msg := <-messagesCh:
					go g.actionService.ProcessChat(token, sessionId, msg)
					jsonBytes, _ := json.Marshal(msg)
					g.broadcastService.Broadcast(jsonBytes, sessionId) // Use your Broadcast function here to broadcast the received message
				}
			}
		}()
	}

	go func() {
		defer g.broadcastService.RemoveTrackerClient(sessionId)

		for {
			select {
			case message, ok := <-client.Send:
				if !ok {
					// The send channel was closed
					return
				}
				err := g.broadcastService.SendToClient(client, message)
				if err != nil {
					zap.S().Error("Error writing message:", err)
					return
				}
			}
		}
	}()
}
