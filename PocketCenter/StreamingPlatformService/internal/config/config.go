package config

import (
	"os"
)

type GoogleSecret struct {
	OathRedirectUrl string
	ClientSecret    string
}

type Config struct {
	ServerAddress       string
	Port                string
	UserAuthAddress     string
	GoogleSecret        GoogleSecret
	AppEnv              string
	PocketActionAddress string
}

func loadGoogleSecrets() (*GoogleSecret, error) {
	oathRedirectUrl := os.Getenv("GOOGLE_REDIRECT_URL")
	clientSecret := os.Getenv("GOOGLE_CLIENT_SECRET")
	return &GoogleSecret{
		OathRedirectUrl: oathRedirectUrl,
		ClientSecret:    clientSecret,
	}, nil
}

func LoadConfig() (*Config, error) {
	pocketActionAddress := os.Getenv("POCKETACTION_ADDRESS")
	serverAddress := os.Getenv("SERVER_ADDRESS")
	port := os.Getenv("SERVER_PORT")
	env := os.Getenv("APP_ENV")

	userAuthAddress := os.Getenv("USER_AUTH_ADDRESS")
	if serverAddress == "" {
		serverAddress = "0.0.0.0"
		port = "8080" // Default address
	}

	googleSecret, err := loadGoogleSecrets()

	return &Config{
		ServerAddress:       serverAddress,
		Port:                port,
		UserAuthAddress:     userAuthAddress,
		GoogleSecret:        *googleSecret,
		AppEnv:              env,
		PocketActionAddress: pocketActionAddress,
	}, err
}
