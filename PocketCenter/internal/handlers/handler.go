package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"pocketcenter/internal/model"
	"sync"

	"github.com/gorilla/websocket"
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}

	clients = make(map[*client]bool)
	mu      sync.Mutex
)

type client struct {
	conn *websocket.Conn
	send chan []byte
}

type FeatureHandler struct {
}

func NewFeatureHandler() *FeatureHandler {
	return &FeatureHandler{}
}

func (f *FeatureHandler) HandleFaceTracking(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	client := &client{conn: conn, send: make(chan []byte)}
	clients[client] = true

	go func() {
		defer deleteClient(client)
		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				log.Println("Error reading message:", err)
				return
			}
			var data model.FaceTrackingFeatures
			err = json.Unmarshal(message, &data)
			if err != nil {
				log.Println("Error unmarshalling JSON:", err)
				continue
			}

			broadcast(message)
		}
	}()
}

func (f *FeatureHandler) HandleReceiver(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	client := &client{conn: conn, send: make(chan []byte)}
	clients[client] = true

	go sendToClient(client)
}

func deleteClient(c *client) {
	mu.Lock()
	delete(clients, c)
	mu.Unlock()

	c.conn.Close()
	close(c.send)
}

func sendToClient(c *client) {
	defer deleteClient(c)
	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				return
			}

			err := c.conn.WriteMessage(websocket.TextMessage, message)
			if err != nil {
				log.Println("Error writing message:", err)
				return
			}
		}
	}
}

func broadcast(message []byte) {
	mu.Lock()
	for client := range clients {
		select {
		case client.send <- message:
			log.Println("Message send to", client)
		default:
			log.Println("client")
		}
	}
	mu.Unlock()
}
