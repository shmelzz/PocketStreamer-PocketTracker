package app

import (
	"fmt"
	"log"
	"net/http"
	"pocketaction/internal/config"
)

type App struct {
	Config *config.Config
}

// NewApp creates and configures your application.
func NewApp(cfg *config.Config) *App {
	// handlers := handlers.NewFeatureHandler(service.NewBroadcastService(), cfg.UserAuthAddress)
	// router.InitRoutes(handlers)
	// Set up the router and routes.

	return &App{
		Config: cfg,
	}
}

// Run starts the application.
func (app *App) Run() {
	fmt.Println("Listening on port", app.Config.Port)
	log.Fatal(http.ListenAndServe(app.Config.ServerAddress+":"+app.Config.Port, nil))
}
