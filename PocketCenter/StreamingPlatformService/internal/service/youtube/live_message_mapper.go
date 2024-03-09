package ytbot

import (
	"streamingservice/internal/model"

	"google.golang.org/api/youtube/v3"
)

func mapMessage(message youtube.LiveChatMessage) *model.LiveChatMessage {
	return &model.LiveChatMessage{
		Username: message.AuthorDetails.DisplayName,
		Message:  message.Snippet.DisplayMessage,
	}
}
