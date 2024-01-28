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
}

func NewFeatureHandler(broadcastService *services.BroadcastService) *FeatureHandler {
	return &FeatureHandler{broadcastService: broadcastService}
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
	client, err := f.broadcastService.AddTracker(w, r)
	if err != nil {
		log.Println(err)
		return
	}

	go func() {
		defer f.broadcastService.RemoveClient(client)
		for {
			message, err := client.Read()
			if err != nil {
				log.Println("Error reading message:", err)
				return
			}

			var data model.FaceTrackingFeatures
			if err = json.Unmarshal(message, &data); err != nil {
				log.Println("Error unmarshalling JSON:", err)
				continue
			}

			f.broadcastService.Broadcast(message)
		}
	}()
}

func (f *FeatureHandler) HandleReceiver(w http.ResponseWriter, r *http.Request) {
	client, err := f.broadcastService.AddComposer(w, r)
	if err != nil {
		log.Println(err)
		return
	}

	go func() {
		defer f.broadcastService.RemoveClient(client)

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
