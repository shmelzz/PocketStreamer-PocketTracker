package router

import (
	"net/http"
	"pocketcenter/internal/handlers"
)

// InitRoutes initializes all the routes for the application.
func InitRoutes(handler *handlers.FeatureHandler) {
	http.HandleFunc("/facetracking", handler.HandleFaceTracking)
	http.HandleFunc("/composed", handler.HandleReceiver)
}
