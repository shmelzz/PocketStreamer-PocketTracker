package main

import (
	"flag"
	"fmt"
	app "pocketcenter/internal"
	"pocketcenter/internal/config"

	"github.com/joho/godotenv"
)

func getConfigPath() string {
	var configPath string

	flag.StringVar(&configPath, "c", ".env.dev", "path to config file")
	flag.Parse()

	return configPath
}

func main() {
	err := godotenv.Load(getConfigPath())

	if err != nil {
		fmt.Println(err)
	}
	
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}
	application := app.NewApp(cfg)

	go application.Run()

	newCfg, err := config.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}
	newCfg.Port = "4545"
	newCfg.UserAuthAddress = "http://auth_service:8088"
	newApplication := app.NewApp(newCfg)

	newApplication.Run()
}
