package app

import (
	"context"
	"fmt"
	"pocketaction/internal/config"
	docs "pocketaction/internal/docs"
	"pocketaction/internal/handlers"
	"pocketaction/internal/repository"
	"pocketaction/internal/router"
	"pocketaction/internal/service"
	"pocketaction/internal/util"
	"pocketaction/internal/zaploki"
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
		Labels:       map[string]string{"port": cfg.Port, "app_environment": cfg.AppEnv, "app": "pocketactionservice"},
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

	_, err := util.CreateIfNotExistFolder("presentation")
	if err != nil {
		fmt.Println(err)
	}
	docs.SwaggerInfo.BasePath = cfg.SwaggerBasePath
	fmt.Println("Swagger base path" + cfg.SwaggerBasePath)
	broadcastService := service.NewBroadcastService(zaplogger)
	documentRepository := repository.NewAppwriteDocumentRepsitory(cfg.AppwriteAPIKey)
	pdfToImageService := service.NewPdfToImageService(zaplogger)
	documentService := service.NewDocumentService(documentRepository, pdfToImageService, zaplogger)
	handler := handlers.NewPocketActionHandler(broadcastService, documentService, cfg.UserAuthAddress, zaplogger)

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
