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
	sessions        map[string]bool
	composerClients map[string]*Client
	mu              sync.Mutex
	logger          *zap.Logger
}

type Client struct {
	conn *websocket.Conn
	Send chan []byte
}

func NewBroadcastService(zapLogger *zap.Logger) *BroadcastService {
	return &BroadcastService{
		sessions:        make(map[string]bool),
		composerClients: make(map[string]*Client),
		logger:          zapLogger,
	}
}

func (s *BroadcastService) AddComposer(w http.ResponseWriter, r *http.Request) (*Client, error) {
	session := r.Header.Get("SessionId")

	if session == "" {
		return nil, fmt.Errorf("can not find session Id")
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return nil, err
	}

	client := &Client{conn: conn, Send: make(chan []byte)}
	s.mu.Lock()
	s.sessions[session] = true
	s.composerClients[session] = client
	s.logger.Info("Add composer")
	s.mu.Unlock()
	return client, nil
}

func (s *BroadcastService) RemoveComposerClient(session string) {
	c := s.composerClients[session]

	s.mu.Lock()
	delete(s.composerClients, session)
	s.mu.Unlock()

	c.conn.Close()
	close(c.Send)
}

func (s *BroadcastService) SendToClient(c *Client, message []byte) error {
	return c.conn.WriteMessage(websocket.TextMessage, message)
}

func (s *BroadcastService) Broadcast(message []byte, sessionId string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.composerClients[sessionId] == nil {
		return fmt.Errorf("Cant find sessionId")
	}

	select {
	case s.composerClients[sessionId].Send <- message:
		s.logger.Debug("Send to composer, message: ", zap.String("msg", string(message)))
	default:
	}
	return nil
}

func (c *Client) Read() ([]byte, error) {
	_, message, err := c.conn.ReadMessage()
	return message, err
}
