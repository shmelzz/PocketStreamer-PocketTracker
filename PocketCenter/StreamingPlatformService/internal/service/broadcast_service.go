package service

import (
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"go.uber.org/zap"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type BroadcastService struct {
	sessions       map[string]bool
	trackerClients map[string]*BroadcastClient
	mu             sync.Mutex
}

type BroadcastClient struct {
	conn *websocket.Conn
	Send chan []byte
}

func NewBroadcastService() *BroadcastService {
	return &BroadcastService{
		sessions:       make(map[string]bool),
		trackerClients: make(map[string]*BroadcastClient),
	}
}

func (s *BroadcastService) AddTracker(w http.ResponseWriter, r *http.Request) (*BroadcastClient, error) {
	session := r.Header.Get("SessionId")

	if session == "" {
		return nil, fmt.Errorf("can not find session Id")
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return nil, err
	}

	client := &BroadcastClient{conn: conn, Send: make(chan []byte)}
	s.mu.Lock()
	s.sessions[session] = true
	s.trackerClients[session] = client
	zap.S().Info("Add tracker")
	s.mu.Unlock()
	return client, nil
}

func (s *BroadcastService) RemoveTrackerClient(session string) {
	c := s.trackerClients[session]

	s.mu.Lock()
	delete(s.trackerClients, session)
	s.mu.Unlock()

	c.conn.Close()
	close(c.Send)
}

func (s *BroadcastService) SendToClient(c *BroadcastClient, message []byte) error {
	return c.conn.WriteMessage(websocket.TextMessage, message)
}

func (s *BroadcastService) Broadcast(message []byte, sessionId string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.trackerClients[sessionId] == nil {
		return fmt.Errorf("Cant find sessionId")
	}

	select {
	case s.trackerClients[sessionId].Send <- message:
		zap.S().Debug("Send to composer, message: ", message)
	default:
	}
	return nil
}

func (c *BroadcastClient) Read() ([]byte, error) {
	_, message, err := c.conn.ReadMessage()
	return message, err
}
