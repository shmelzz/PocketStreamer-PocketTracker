package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"pocketcenter/internal/model"
	"pocketcenter/internal/services"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

type FeatureHandler struct {
	broadcastService *services.BroadcastService
	userAuthAddress  string
	logger           *zap.Logger
}

func NewFeatureHandler(
	broadcastService *services.BroadcastService,
	userAuthAddress string,
	zapLogger *zap.Logger,
) *FeatureHandler {
	return &FeatureHandler{
		broadcastService: broadcastService,
		userAuthAddress:  userAuthAddress,
		logger:           zapLogger,
	}
}

type VersionResponse struct {
	Version string `json:"version"`
}

func (f *FeatureHandler) HandleVersion(c *gin.Context) {
	r := c.Request
	w := c.Writer
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	json.NewEncoder(w).Encode(VersionResponse{Version: "v1"})
}

func (f *FeatureHandler) HandleFaceTracking(c *gin.Context) {
	r := c.Request
	w := c.Writer
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, username, err := f.validateToken(token)
	if err != nil {
		f.logger.Error("Error when try to validate", zap.Error(err))
		http.Error(w, "Error when try to validate", http.StatusBadRequest)
		return
	}
	if !ok {
		f.logger.Error("Validation not passed", zap.Error(err))
		http.Error(w, "Validation not passed", http.StatusUnauthorized)
		return
	}
	client, err := f.broadcastService.AddTracker(w, r)
	logger := f.logger.With(zap.String("username", username))
	if err != nil {
		logger.Error("Cant add tracker", zap.Error(err))
		http.Error(w, "Can't add tracker", http.StatusBadRequest)
		return
	}

	go func() {
		defer f.broadcastService.RemoveTrackerClient(session)
		for {
			message, err := client.Read()
			if err != nil {
				logger.Error("Error reading message:", zap.Error(err))
				return
			}

			var data model.FaceTrackingFeatures
			if err = json.Unmarshal(message, &data); err != nil {
				logger.Error("Error unmarshalling JSON:", zap.Error(err))
			}

			err = f.broadcastService.Broadcast(message, session)
			if err != nil {
				logger.Error("Error when broadcasting", zap.Error(err))
				return
			}
		}
	}()
}

func (f *FeatureHandler) HandleReceiver(c *gin.Context) {
	r := c.Request
	w := c.Writer
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, username, err := f.validateToken(token)

	if err != nil {
		f.logger.Error("Validation error", zap.Error(err))
		http.Error(w, "Error when try to validate", http.StatusBadRequest)
		return
	}
	if !ok {
		f.logger.Error("Validation not passed", zap.Error(err))
		http.Error(w, "Validation not passed", http.StatusUnauthorized)
		return
	}

	logger := f.logger.With(zap.String("username", username))
	client, err := f.broadcastService.AddComposer(w, r)
	if err != nil {
		logger.Error("Cant add composer", zap.Error(err))
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
					logger.Error("Error writing message:", zap.Error(err))
					return
				}
			}
		}
	}()
}

func (f *FeatureHandler) validateToken(token string) (bool, string, error) {
	// Create a new request to the userauthsessionservice
	req, err := http.NewRequest("POST", f.userAuthAddress+"/auth/validate", nil)
	if err != nil {
		return false, "", err
	}

	// Add the token to the request header
	req.Header.Add("Authentication", token)

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return false, "", err
	}
	defer resp.Body.Close()

	// Check the response
	if resp.StatusCode != http.StatusOK {
		return false, "", nil
	}

	var result map[string]string
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return false, "", err
	}

	// Extract the username from the response
	username, ok := result["username"]
	if !ok {
		return false, "", fmt.Errorf("Username not found in response")
	}

	return true, username, nil
}
