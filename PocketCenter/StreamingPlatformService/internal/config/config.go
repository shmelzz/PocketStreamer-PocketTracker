package config

import (
	"os"
)

type GoogleSecret struct {
	OathRedirectUrl string
	ClientSecret    string
}

type TwitchConfig struct {
	ClientId     string
	ClientSecret string
}

type Config struct {
	ServerAddress       string
	Port                string
	UserAuthAddress     string
	GoogleSecret        GoogleSecret
	AppEnv              string
	PocketActionAddress string
	TwitchConfig        TwitchConfig
}

func loadGoogleSecrets() (*GoogleSecret, error) {
	oathRedirectUrl := os.Getenv("GOOGLE_REDIRECT_URL")
	clientSecret := os.Getenv("GOOGLE_CLIENT_SECRET")
	return &GoogleSecret{
		OathRedirectUrl: oathRedirectUrl,
		ClientSecret:    clientSecret,
	}, nil
}

func loadTwitchConfig() (*TwitchConfig, error) {
	clientId := os.Getenv("TWITCH_CLIENT_ID")
	clientSecret := os.Getenv("TWTICH_CLIENT_SECRET")
	return &TwitchConfig{
		ClientId:     clientId,
		ClientSecret: clientSecret,
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

	twitchConfig, err := loadTwitchConfig()

	return &Config{
		ServerAddress:       serverAddress,
		Port:                port,
		UserAuthAddress:     userAuthAddress,
		GoogleSecret:        *googleSecret,
		AppEnv:              env,
		PocketActionAddress: pocketActionAddress,
		TwitchConfig:        *twitchConfig,
	}, err
}
