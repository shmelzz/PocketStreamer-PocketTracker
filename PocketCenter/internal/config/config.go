package config

import (
	"os"
)

type Config struct {
	ServerAddress string
	Port          string
}

func LoadConfig() (*Config, error) {
	serverAddress := os.Getenv("SERVER_ADDRESS")
	port := os.Getenv("SERVER_PORT")
	if serverAddress == "" {
		serverAddress = "0.0.0.0"
		port = "4545" // Default address
	}
	return &Config{
		ServerAddress: serverAddress,
		Port:          port,
	}, nil
}
