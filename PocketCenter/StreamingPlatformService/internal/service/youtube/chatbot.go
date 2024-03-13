package ytbot

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"streamingservice/internal/model"

	"google.golang.org/api/option"
	"google.golang.org/api/youtube/v3"
)

type LiveChatBotInput struct {
	Urls         []string
	RefetchCache bool
}

func NewLiveChatBot(input *LiveChatBotInput, client *http.Client) *model.LiveChatBot {
	service, err := youtube.NewService(context.Background(), option.WithHTTPClient(client))

	if err != nil {
		log.Fatalf("Error creating YouTube client: %v", err)
	}

	liveChatIds := fetchChatIds(input.Urls, service)

	chatReaders := make(map[string]<-chan *model.LiveChatMessage)
	chatWriters := make(map[string]chan<- string)
	for url, chatId := range liveChatIds {
		chatReaders[url] = readChat(service, chatId)
		chatWriters[url] = writeChat(service, chatId)
	}

	return &model.LiveChatBot{
		ChatReaders: chatReaders,
		ChatWriters: chatWriters,
	}
}

func readChat(service *youtube.Service, chatId string) <-chan *model.LiveChatMessage {

	messageChannel := make(chan *model.LiveChatMessage)
	const extraPercent float64 = 0.1

	// https://levelup.gitconnected.com/use-go-channels-as-promises-and-async-await-ee62d93078ec
	go func(chatId string) {
		defer close(messageChannel)

		var nextPageToken string = ""

		for {
			// get live chats from chatId
			call := service.LiveChatMessages.List(chatId, []string{"snippet", "authorDetails"})
			call.PageToken(nextPageToken)
			response, err := call.Do()
			if err != nil {
				fmt.Println("Closing Channel: ", chatId, " Error getting live chat messages:", err)
				break
			}

			for _, item := range response.Items {
				messageChannel <- mapMessage(*item)
			}
			nextPageToken = response.NextPageToken

			time.Sleep(10*time.Second + time.Millisecond*time.Duration((float64(response.PollingIntervalMillis)*(1+extraPercent))))
		}
	}(chatId)
	return messageChannel

}

func writeChat(service *youtube.Service, chatId string) chan<- string {
	messageChannel := make(chan string)

	go func(chatId string) {
		for newMessage := range messageChannel {
			go func(newMessage string) {
				call := service.LiveChatMessages.Insert([]string{"snippet"}, &youtube.LiveChatMessage{
					Snippet: &youtube.LiveChatMessageSnippet{
						LiveChatId: chatId,
						Type:       "textMessageEvent",
						TextMessageDetails: &youtube.LiveChatTextMessageDetails{
							MessageText: newMessage,
						},
					},
				})
				_, err := call.Do()
				if err != nil {
					fmt.Println("Error sending message: ", newMessage, " On Channel: ", chatId, " Error Was: ", err)
				}
			}(newMessage)
		}
	}(chatId)

	return messageChannel
}

// parallely fetch chatIds from urls
// alternate solution : https://stackoverflow.com/questions/40809504/idiomatic-goroutine-termination-and-error-handling
func fetchChatIds(urls []string, service *youtube.Service) map[string]string {

	type job struct {
		url    string
		chatId string
	}

	responseChannel := make(chan job)
	defer close(responseChannel)

	// parallelize the requests
	for _, url := range urls {
		go func(url string) {
			cidRes, cidErr := service.Videos.List([]string{"liveStreamingDetails"}).Id(url).Do()
			if cidErr != nil {
				log.Fatalf("Error getting live chat id: %v", cidErr)
			}
			responseChannel <- job{url, cidRes.Items[0].LiveStreamingDetails.ActiveLiveChatId}
		}(url)
	}

	// wait for all responses
	chatIds := make(map[string]string)
	for range urls {
		j := <-responseChannel
		chatIds[j.url] = j.chatId
	}

	return chatIds
}
