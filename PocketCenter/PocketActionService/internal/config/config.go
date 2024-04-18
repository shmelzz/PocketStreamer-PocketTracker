package config

import (
	"os"
)

type Config struct {
	ServerAddress   string
	Port            string
	UserAuthAddress string
	AppEnv          string
	AppwriteAPIKey  string
	SwaggerBasePath string
	LokiAddress     string
}

func LoadConfig() (*Config, error) {
	swaggerBasePath := os.Getenv("SWAGGER_BASE_PATH")
	lokiAddress := os.Getenv("LOKI_ADDRESS")
	appEnv := os.Getenv("APP_ENV")
	appwrite := os.Getenv("APPWRITE_API_KEY")
	serverAddress := os.Getenv("SERVER_ADDRESS")
	port := os.Getenv("SERVER_PORT")
	userAuthAddress := os.Getenv("USER_AUTH_ADDRESS")
	if serverAddress == "" {
		serverAddress = "0.0.0.0"
		port = "8080" // Default address
	}
	return &Config{
		ServerAddress:   serverAddress,
		Port:            port,
		UserAuthAddress: userAuthAddress,
		AppEnv:          appEnv,
		AppwriteAPIKey:  appwrite,
		SwaggerBasePath: swaggerBasePath,
		LokiAddress:     lokiAddress,
	}, nil
}
