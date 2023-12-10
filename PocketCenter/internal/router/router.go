package router

import (
	"net/http"
	"pocketcenter/internal/handlers"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// InitRoutes initializes all the routes for the application.
func InitRoutes(handler *handlers.FeatureHandler) {
	http.HandleFunc("/facetracking", handler.HandleFaceTracking)
	http.HandleFunc("/composed", handler.HandleReceiver)
	http.Handle("/metrics", promhttp.Handler())
	http.HandleFunc("/version", handler.HandleVersion)
}
