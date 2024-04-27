package app

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"
	"userauth/internal/config"
	"userauth/internal/handlers"
	"userauth/internal/repository"
	"userauth/internal/router"
	"userauth/internal/service"
	"userauth/internal/zaploki"

	docs "userauth/internal/docs"

	"github.com/gin-gonic/gin"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v4/pgxpool"
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
		Labels:       map[string]string{"port": cfg.Port, "app_environment": cfg.AppEnv, "app": "userauthsession"},
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
	docs.SwaggerInfo.BasePath = cfg.SwaggerBasePath
	fmt.Println("Swagger base path" + cfg.SwaggerBasePath)
	pgxPool, err := initDB(context.Background(), &cfg.Repo)
	if err != nil {
		log.Fatal(err)
	}
	userAuthRepository := repository.NewUserAuthRepository(pgxPool)
	sessionRepository := repository.NewSessionRepository(pgxPool)
	userAuthService := service.NewUserAuthService(userAuthRepository)
	sessionService := service.NewSessionService(sessionRepository)
	handler := handlers.NewUserAuthHandler(userAuthService, sessionService)
	logger := SetUpLoki(cfg)
	engine := router.InitRoutes(handler, logger)

	return &App{
		Engine: engine,
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
	log.Fatal(app.Engine.Run(fmt.Sprintf("%s:%s", app.Config.ServerAddress, app.Config.Port)))
}

func initDB(ctx context.Context, config *config.RepoConfig) (*pgxpool.Pool, error) {
	pgxConfig, err := pgxpool.ParseConfig(config.Dsn)
	if err != nil {
		return nil, err
	}

	pool, err := pgxpool.ConnectConfig(ctx, pgxConfig)
	if err != nil {
		return nil, fmt.Errorf("unable to connect to database: %w", err)
	}
	fmt.Printf("Connected to database")

	// migrations

	m, err := migrate.New(config.Mig_dir, config.Dsn)
	if err != nil {
		return nil, err
	}

	if err := m.Down(); err != nil && err != migrate.ErrNoChange {
		return nil, err
	}

	if err := m.Up(); err != nil {
		return nil, err
	}

	return pool, nil
}
