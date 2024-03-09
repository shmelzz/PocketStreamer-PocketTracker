package twitchbot

import (
	"streamingservice/internal/model"
	"time"

	"github.com/gempir/go-twitch-irc/v4"
)

func ConnectToTwitch(messages chan model.LiveChatMessage, channelName string) {
	client := twitch.NewAnonymousClient()

	client.OnPrivateMessage(func(message twitch.PrivateMessage) {
		go func() {
			messages <- model.LiveChatMessage{
				Username: message.User.DisplayName,
				Message:  message.Message,
			}
		}()
	})

	client.Join(channelName)

	client.SendPings = true
	client.IdlePingInterval = time.Second * 30

	err := client.Connect()
	if err != nil {
		panic(err)
	}
}
