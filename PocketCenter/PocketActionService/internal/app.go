package app

import (
	"fmt"
	"pocketaction/internal/config"
	"pocketaction/internal/docs"
	"pocketaction/internal/handlers"
	"pocketaction/internal/router"
	"pocketaction/internal/service"

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

	docs.SwaggerInfo.BasePath = "/action"
	service := service.NewBroadcastService()
	handler := handlers.NewPocketActionHandler(service, cfg.UserAuthAddress)

	// Set up the router and routes.
	engine := router.InitRoutes(handler)
	return &App{
		Config: cfg,
		Engine: engine,
	}
}

// Run starts the application.
func (app *App) Run() {
	fmt.Println("Listening on port", app.Config.Port)
	zap.S().Fatal(app.Engine.Run(fmt.Sprintf("%s:%s", app.Config.ServerAddress, app.Config.Port)))
}