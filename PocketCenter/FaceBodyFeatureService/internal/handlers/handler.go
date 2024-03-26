package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"pocketcenter/internal/model"
	"pocketcenter/internal/services"
)

type FeatureHandler struct {
	broadcastService *services.BroadcastService
	userAuthAddress  string
}

func NewFeatureHandler(broadcastService *services.BroadcastService, userAuthAddress string) *FeatureHandler {
	return &FeatureHandler{
		broadcastService: broadcastService,
		userAuthAddress:  userAuthAddress,
	}
}

type VersionResponse struct {
	Version string `json:"version"`
}

func (f *FeatureHandler) HandleVersion(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	json.NewEncoder(w).Encode(VersionResponse{Version: "v1"})
}

func (f *FeatureHandler) HandleFaceTracking(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, err := f.validateToken(token)
	if err != nil {
		log.Println(err)
		http.Error(w, "Error when try to validate", http.StatusBadRequest)
		return
	}
	if !ok {
		log.Println("Validation not passed")
		http.Error(w, "Validation not passed", http.StatusUnauthorized)
		return
	}
	client, err := f.broadcastService.AddTracker(w, r)
	if err != nil {
		log.Println(err)
		http.Error(w, "Can't add tracker", http.StatusBadRequest)
		return
	}

	go func() {
		defer f.broadcastService.RemoveTrackerClient(session)
		for {
			message, err := client.Read()
			if err != nil {
				log.Println("Error reading message:", err)
				return
			}

			var data model.FaceTrackingFeatures
			if err = json.Unmarshal(message, &data); err != nil {
				log.Println("Error unmarshalling JSON:", err)
			}

			err = f.broadcastService.Broadcast(message, session)
			if err != nil {
				log.Printf(err.Error())
				return
			}
		}
	}()
}

func (f *FeatureHandler) HandleReceiver(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, err := f.validateToken(token)
	if err != nil {
		log.Println(err)
		http.Error(w, "Error when try to validate", http.StatusBadRequest)
		return
	}
	if !ok {
		log.Println("Validation not passed")
		http.Error(w, "Validation not passed", http.StatusUnauthorized)
		return
	}

	client, err := f.broadcastService.AddComposer(w, r)
	if err != nil {
		log.Println(err)
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
					log.Println("Error writing message:", err)
					return
				}
			}
		}
	}()
}

func (f *FeatureHandler) validateToken(token string) (bool, error) {
	// Create a new request to the userauthsessionservice
	req, err := http.NewRequest("POST", f.userAuthAddress+"/auth/validate", nil)
	if err != nil {
		log.Println(err)
		return false, err
	}

	// Add the token to the request header
	req.Header.Add("Authentication", token)

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Println(err)
		return false, err
	}
	defer resp.Body.Close()

	// Check the response
	if resp.StatusCode != http.StatusOK {
		log.Println("Token validation failed")
		return false, nil
	}

	return true, nil
}
