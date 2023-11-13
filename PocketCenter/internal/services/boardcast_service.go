package services

import (
	"log"
	"net/http"
	"sync"

	"pocketcenter/metrics"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type BroadcastService struct {
	clients map[*Client]bool
	mu      sync.Mutex
}

type Client struct {
	conn *websocket.Conn
	Send chan []byte
}

func NewBroadcastService() *BroadcastService {
	return &BroadcastService{
		clients: make(map[*Client]bool),
	}
}

func (s *BroadcastService) AddTracker(w http.ResponseWriter, r *http.Request) (*Client, error) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return nil, err
	}

	client := &Client{conn: conn, Send: make(chan []byte)}
	log.Printf("Add tracker")
	return client, nil
}

func (s *BroadcastService) AddComposer(w http.ResponseWriter, r *http.Request) (*Client, error) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return nil, err
	}

	client := &Client{conn: conn, Send: make(chan []byte)}
	s.mu.Lock()
	s.clients[client] = true
	log.Printf("Add composer")
	s.mu.Unlock()
	return client, nil
}

func (s *BroadcastService) RemoveClient(c *Client) {
	s.mu.Lock()
	delete(s.clients, c)
	s.mu.Unlock()

	c.conn.Close()
	close(c.Send)
}

func (s *BroadcastService) SendToClient(c *Client, message []byte) error {
	return c.conn.WriteMessage(websocket.TextMessage, message)
}

func (s *BroadcastService) Broadcast(message []byte) {
	s.mu.Lock()
	defer s.mu.Unlock()

	for client := range s.clients {
		select {
		case client.Send <- message:
			metrics.ComposerDataStatus.WithLabelValues("success").Inc()
			log.Printf("Send a message to client, client count: %d", len(s.clients))
		default:
			metrics.ComposerDataStatus.WithLabelValues("failed").Inc()
			log.Printf("Failed to send message to client, client count: %d", len(s.clients))
		}
	}
}

func (c *Client) Read() ([]byte, error) {
	_, message, err := c.conn.ReadMessage()
	return message, err
}
