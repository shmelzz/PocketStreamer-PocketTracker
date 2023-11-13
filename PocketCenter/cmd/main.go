package main

import (
	"fmt"
	app "pocketcenter/internal"
	"pocketcenter/internal/config"
)

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}
	application := app.NewApp(cfg)

	application.Run()
}
