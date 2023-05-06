package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

const (
	port = 3000 // Your port number
)

type FaceTrackingData struct {
	TimeCode                   int64     `json:"timeCode"`
	LeftEye                    []float32 `json:"leftEye"`
	RightEye                   []float32 `json:"rightEye"`
	GeometryVertices           []float32 `json:"geometryVertices"`
	GeometryTextureCoordinates []float32 `json:"geometryTextureCoordinates"`
	GeometryTriangleIndices    []float32 `json:"geometryTriangleIndices"`
	GeometryTriangleCount      int32     `json:"geometryTriangleCount"`
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func main() {
	http.HandleFunc("/", handleWebSocketConnection)
	fmt.Println("Listening on port", port, "...")
	log.Fatal(http.ListenAndServe("0.0.0.0:"+fmt.Sprintf("%d", port), nil))
}

func handleWebSocketConnection(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Println("Error reading message:", err)
			break
		}

		var data FaceTrackingData
		err = json.Unmarshal(message, &data)
		if err != nil {
			log.Println("Error unmarshalling JSON:", err)
			continue
		}

		fmt.Printf("Received face tracking data:\n")
		fmt.Printf("TimeCode: %v\n", data.TimeCode)
		fmt.Printf("LeftEye: %v\n", data.LeftEye)
		fmt.Printf("RightEye: %v\n", data.RightEye)
		fmt.Printf("Geometry:")
		fmt.Printf("vertices: %v\n", len(data.GeometryVertices))
		fmt.Printf("textureCoordinates: %v\n", len(data.GeometryTextureCoordinates))
		fmt.Printf("triangleIndices: %v\n", len(data.GeometryTriangleIndices))
		fmt.Printf("triangleCount: %v\n", data.GeometryTriangleCount)

	}
}
