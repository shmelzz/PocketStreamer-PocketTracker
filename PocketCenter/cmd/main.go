package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	app "pocketcenter/internal"
	"pocketcenter/internal/config"
	"pocketcenter/internal/model"
	"sync"

	"github.com/gorilla/websocket"
)

const (
	port = 3000 // Your port number
)

type client struct {
	conn *websocket.Conn
	send chan []byte
}

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}

	clients = make(map[*client]bool)
	mu      sync.Mutex
)

func main() {
	// http.HandleFunc("/facetracking", handleFaceTracking)
	// http.HandleFunc("/composed", handleReceiver)
	// addrs, err := net.InterfaceAddrs()
	// if err != nil {
	// 	panic(err)
	// }
	// for _, addr := range addrs {
	// 	if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
	// 		if ipnet.IP.To4() != nil {
	// 			fmt.Println(ipnet.IP.String())
	// 		}
	// 	}
	// }
	// fmt.Println("Listening on port", port, "...", "From IP: ")
	// log.Fatal(http.ListenAndServe("0.0.0.0:"+fmt.Sprintf("%d", port), nil))

	cfg, err := config.LoadConfig()
	if err != nil {
		fmt.Println(err)
	}
	application := app.NewApp(cfg)

	application.Run()

}

func handleFaceTracking(w http.ResponseWriter, r *http.Request) {
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

func handleReceiver(w http.ResponseWriter, r *http.Request) {
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
