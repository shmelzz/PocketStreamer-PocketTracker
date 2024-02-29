package config

import (
	"os"
)

type Config struct {
	ServerAddress string
	Port          string
	Repo          RepoConfig
}

type RepoConfig struct {
	Dsn     string
	Mig_dir string
}

func LoadConfig() (*Config, error) {
	dsn := os.Getenv("DSN")
	mig_dir := os.Getenv("MIGRATIONS_DIR")
	repoConfig := RepoConfig{
		Dsn:     dsn,
		Mig_dir: mig_dir,
	}
	serverAddress := os.Getenv("SERVER_ADDRESS")
	port := os.Getenv("SERVER_PORT")
	if serverAddress == "" {
		serverAddress = "0.0.0.0"
		port = "8080" // Default address
	}
	return &Config{
		ServerAddress: serverAddress,
		Port:          port,
		Repo:          repoConfig,
	}, nil
}
