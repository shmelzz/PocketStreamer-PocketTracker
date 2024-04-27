package services

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"pocketcenter/internal/metrics"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"go.uber.org/zap"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type BroadcastService struct {
	sessions        map[string]bool
	trackerClients  map[string]*Client
	composerClients map[string]*Client
	mu              sync.Mutex
	logger          *zap.Logger
}

type Client struct {
	conn *websocket.Conn
	Send chan []byte
}

func NewBroadcastService(
	zapLogger *zap.Logger,
) *BroadcastService {
	return &BroadcastService{
		sessions:        make(map[string]bool),
		trackerClients:  make(map[string]*Client),
		composerClients: make(map[string]*Client),
		logger:          zapLogger,
	}
}

func (s *BroadcastService) AddTracker(w http.ResponseWriter, r *http.Request, username string) (*Client, error) {
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
	s.trackerClients[session] = client
	s.logger.With(zap.String("username", username), zap.String("session", session)).Info("Add tracker")
	s.mu.Unlock()
	return client, nil
}

func (s *BroadcastService) AddComposer(w http.ResponseWriter, r *http.Request, username string) (*Client, error) {
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
	s.logger.With(zap.String("username", username), zap.String("session", session)).Info("Add composer")
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

	influxClient := influxdb2.NewClient("http://localhost:8086", "Tjo_7XVMbeaLlqim3rmeG-yawFKPkHa6DbsSKBzCNFWajsMrd1ppx7idadnRVLi6MHFRzk2X2mQH6VuWLfQxEA==")
	writeAPI := influxClient.WriteAPIBlocking("pocket-center", "pocket-center")
	if s.composerClients[sessionId] == nil {
		return fmt.Errorf("Cant find session")
	}
	select {
	case s.composerClients[sessionId].Send <- message:
		p := influxdb2.NewPointWithMeasurement("sendToComposerStatus").
			AddField("status", true).
			SetTime(time.Now())
		err := writeAPI.WritePoint(context.Background(), p)
		if err != nil {
			log.Println("Cant connect to influxdb")
		}
		metrics.ComposerDataStatus.WithLabelValues("success").Inc()
		log.Printf("Send a message to client, client count: %d", len(s.composerClients))
	default:
		p := influxdb2.NewPointWithMeasurement("sendToComposerStatus").
			AddField("status", false).
			SetTime(time.Now())
		err := writeAPI.WritePoint(context.Background(), p)
		if err != nil {
			log.Println("Cant connect to influxdb")
		}
		metrics.ComposerDataStatus.WithLabelValues("failed").Inc()
		log.Printf("Failed to send message to client, client count")
	}
	influxClient.Close()
	return nil
}

func (c *Client) Read() ([]byte, error) {
	_, message, err := c.conn.ReadMessage()
	return message, err
}
