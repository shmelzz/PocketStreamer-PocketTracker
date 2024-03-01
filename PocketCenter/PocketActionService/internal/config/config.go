package config

import (
	"os"
)

type Config struct {
	ServerAddress   string
	Port            string
	UserAuthAddress string
}

func LoadConfig() (*Config, error) {
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
	}, nil
}
