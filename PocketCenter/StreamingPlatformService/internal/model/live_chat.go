package model

type LiveChatMessage struct {
	Username string `json:"username"`
	Message  string `json:"message"`
}

type LiveChatBot struct {
	ChatReaders map[string]<-chan *LiveChatMessage
	ChatWriters map[string]chan<- string
}
