package app

import (
	"fmt"
	"log"
	"streamingservice/internal/config"
	"streamingservice/internal/handlers"
	"streamingservice/internal/router"
	"streamingservice/internal/service"

	twitchbot "streamingservice/internal/service/twitch"
	ytbot "streamingservice/internal/service/youtube"

	_ "streamingservice/internal/docs"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

type App struct {
	Engine *gin.Engine
	Config *config.Config
}

// NewApp creates and configures your application.
func NewApp(cfg *config.Config) *App {
	if cfg.AppEnv == "development" {
		zap.ReplaceGlobals(zap.Must(zap.NewDevelopment()))
	} else if cfg.AppEnv == "production" {
		zap.ReplaceGlobals(zap.Must(zap.NewProduction()))
	}
	// Set up the router and routes.
	twitchService := twitchbot.NewTwichService(cfg.TwitchConfig)
	pocketActionService := service.NewPocketActionService(cfg.PocketActionAddress)
	youtubeService := ytbot.NewYoutubeService(*cfg)
	broadcastService := service.NewBroadcastService()
	googleOathHandler := handlers.NewOAuthHandler(
		cfg.UserAuthAddress,
		youtubeService,
		broadcastService,
		pocketActionService,
		twitchService,
	)

	engine := router.InitRoutes(googleOathHandler)
	return &App{
		Config: cfg,
		Engine: engine,
	}
}

// Run starts the application.
func (app *App) Run() {
	fmt.Println("Listening on port", app.Config.Port)
	log.Fatal(app.Engine.Run(fmt.Sprintf("%s:%s", app.Config.ServerAddress, app.Config.Port)))
}
