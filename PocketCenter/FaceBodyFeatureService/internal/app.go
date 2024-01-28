package app

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"pocketcenter/internal/config"
	"pocketcenter/internal/handlers"
	"pocketcenter/internal/router"
	"pocketcenter/internal/services"
)

type App struct {
	Config *config.Config
}

// NewApp creates and configures your application.
func NewApp(cfg *config.Config) *App {
	handlers := handlers.NewFeatureHandler(services.NewBroadcastService())
	router.InitRoutes(handlers)
	// Set up the router and routes.

	return &App{
		Config: cfg,
	}
}

// Run starts the application.
func (app *App) Run() {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		panic(err)
	}
	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				fmt.Println(ipnet.IP.String())
			}
		}
	}
	fmt.Println("Listening on port", app.Config.Port, "...", "From IP: ")
	log.Fatal(http.ListenAndServe(app.Config.ServerAddress+":"+app.Config.Port, nil))
}
