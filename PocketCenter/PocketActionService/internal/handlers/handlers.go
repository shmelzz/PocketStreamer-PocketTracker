package handlers

import (
	"encoding/json"
	"net/http"
	"pocketaction/internal/model"
	"pocketaction/internal/service"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

type PocketActionHandler struct {
	broadcastService *service.BroadcastService
	userAuthAddress  string
}

func NewPocketActionHandler(
	broadcastService *service.BroadcastService,
	userAuthAddress string,
) *PocketActionHandler {
	return &PocketActionHandler{
		broadcastService: broadcastService,
		userAuthAddress:  userAuthAddress,
	}
}

// PocketAction godoc
// @Summary Trigger PocketAction
// @Description Trigger Action, send to Composer use websocket
// @Tags session
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Param action body model.PocketAction true "PocketAction request"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /pocketaction [post]
func (p *PocketActionHandler) HandlePocketAction(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	ok, err := p.validateToken(token)
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
	// Use gin to read the request data
	var pocketAction model.PocketAction
	if err := c.BindJSON(&pocketAction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		zap.S().Infof("Error reading JSON: %s", err.Error())
		return
	}

	// Struct to byte -> send to broadcast
	jsonBytes, _ := json.Marshal(pocketAction)
	err = p.broadcastService.Broadcast(jsonBytes, c.Request.Header.Get("SessionId"))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		zap.S().Infof("Cant found session Id : %s", err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "success"})
	zap.S().Infow("Pocket action handled successfully",
		zap.String("type", pocketAction.Type),
		zap.String("payload", pocketAction.Payload))
}

func (p *PocketActionHandler) HandleVersion(c *gin.Context) {
	response := model.Version{
		Version: "1.1.1",
	}

	c.JSON(http.StatusOK, response)
}

func (f *PocketActionHandler) validateToken(token string) (bool, error) {
	// Create a new request to the userauthsessionservice
	zap.S().Debug(f.userAuthAddress + "/auth/validate")
	req, err := http.NewRequest("POST", f.userAuthAddress+"/auth/validate", nil)
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
func (f *PocketActionHandler) HandleReceiver(c *gin.Context) {
	r := c.Request
	w := c.Writer
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, err := f.validateToken(token)
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

	client, err := f.broadcastService.AddComposer(w, r)
	if err != nil {
		zap.S().Error(err)
		f.broadcastService.RemoveComposerClient(session)
		return
	}

	go func() {
		defer f.broadcastService.RemoveComposerClient(session)

		for {
			select {
			case message, ok := <-client.Send:
				if !ok {
					// The send channel was closed
					return
				}
				err := f.broadcastService.SendToClient(client, message)
				if err != nil {
					zap.S().Error("Error writing message:", err)
					return
				}
			}
		}
	}()
}
