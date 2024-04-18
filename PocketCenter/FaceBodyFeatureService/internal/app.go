package app

import (
	"context"
	"fmt"
	"log"
	"net"
	"pocketcenter/internal/config"
	"pocketcenter/internal/handlers"
	"pocketcenter/internal/router"
	"pocketcenter/internal/services"
	"pocketcenter/internal/zaploki"

	"time"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

type App struct {
	Engine *gin.Engine
	Config *config.Config
}

func SetUpLoki(cfg *config.Config) *zap.Logger {
	zapConfig := zap.NewProductionConfig()
	loki := zaploki.New(context.Background(), zaploki.Config{
		Url:          cfg.LokiAddress,
		BatchMaxSize: 1000,
		BatchMaxWait: 10 * time.Second,
		Labels:       map[string]string{"port": cfg.Port, "app_environment": cfg.AppEnv, "app": "facebodyfeature"},
	})

	logger, err := loki.WithCreateLogger(zapConfig, "port"+cfg.Port)
	if err != nil {
		logger.Error(err.Error())
	}
	logger.Info("Loki Setup")
	return logger
}

// NewApp creates and configures your application.
func NewApp(cfg *config.Config) *App {
	zaplogger := SetUpLoki(cfg)
	handlers := handlers.NewFeatureHandler(services.NewBroadcastService(), cfg.UserAuthAddress, zaplogger)
	engine := router.InitRoutes(handlers, zaplogger)
	// Set up the router and routes.

	return &App{
		Config: cfg,
		Engine: engine,
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
	log.Fatal((app.Engine.Run(fmt.Sprintf("%s:%s", app.Config.ServerAddress, app.Config.Port))))
}
