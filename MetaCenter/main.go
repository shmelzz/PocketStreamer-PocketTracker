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

type FaceTrackingFeatures struct {
	TimeCode        float32 `json:"timeCode"`
	MouthStretchR   float32 `json:"mouthStretch_R"`
	MouthRollUpper  float32 `json:"mouthRollUpper"`
	BrowOuterUpR    float32 `json:"browOuterUp_R"`
	EyeLookUpL      float32 `json:"eyeLookUp_L"`
	EyeSquintR      float32 `json:"eyeSquint_R"`
	MouthLeft       float32 `json:"mouthLeft"`
	BrowDownR       float32 `json:"browDown_R"`
	MouthFrownR     float32 `json:"mouthFrown_R"`
	EyeBlinkR       float32 `json:"eyeBlink_R"`
	MouthFrownL     float32 `json:"mouthFrown_L"`
	EyeLookDownR    float32 `json:"eyeLookDown_R"`
	EyeSquintL      float32 `json:"eyeSquint_L"`
	EyeLookOutL     float32 `json:"eyeLookOut_L"`
	JawForward      float32 `json:"jawForward"`
	MouthRollLower  float32 `json:"mouthRollLower"`
	MouthDimpleL    float32 `json:"mouthDimple_L"`
	MouthSmileL     float32 `json:"mouthSmile_L"`
	EyeWideL        float32 `json:"eyeWide_L"`
	BrowOuterUpL    float32 `json:"browOuterUp_L"`
	EyeLookUpR      float32 `json:"eyeLookUp_R"`
	MouthShrugLower float32 `json:"mouthShrugLower"`
	BrowInnerUp     float32 `json:"browInnerUp"`
	MouthUpperUpR   float32 `json:"mouthUpperUp_R"`
	MouthClose      float32 `json:"mouthClose"`
	JawLeft         float32 `json:"jawLeft"`
	MouthStretchL   float32 `json:"mouthStretch_L"`
	JawRight        float32 `json:"jawRight"`
	JawOpen         float32 `json:"jawOpen"`
	CheekSquintR    float32 `json:"cheekSquint_R"`
	EyeLookInL      float32 `json:"eyeLookIn_L"`
	MouthDimpleR    float32 `json:"mouthDimple_R"`
	MouthPucker     float32 `json:"mouthPucker"`
	BrowDownL       float32 `json:"browDown_L"`
	MouthLowerDownL float32 `json:"mouthLowerDown_L"`
	MouthUpperUpL   float32 `json:"mouthUpperUp_L"`
	NoseSneerR      float32 `json:"noseSneer_R"`
	EyeLookDownL    float32 `json:"eyeLookDown_L"`
	MouthRight      float32 `json:"mouthRight"`
	MouthPressR     float32 `json:"mouthPress_R"`
	MouthPressL     float32 `json:"mouthPress_L"`
	CheekPuff       float32 `json:"cheekPuff"`
	CheekSquintL    float32 `json:"cheekSquint_L"`
	EyeLookInR      float32 `json:"eyeLookIn_R"`
	MouthSmileR     float32 `json:"mouthSmile_R"`
	MouthShrugUpper float32 `json:"mouthShrugUpper"`
	EyeBlinkL       float32 `json:"eyeBlink_L"`
	MouthFunnel     float32 `json:"mouthFunnel"`
	NoseSneerL      float32 `json:"noseSneer_L"`
	MouthLowerDownR float32 `json:"mouthLowerDown_R"`
	EyeLookOutR     float32 `json:"eyeLookOut_R"`
	EyeWideR        float32 `json:"eyeWide_R"`
	TongueOut       float32 `json:"tongueOut"`
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

		var data FaceTrackingFeatures
		err = json.Unmarshal(message, &data)
		if err != nil {
			log.Println("Error unmarshalling JSON:", err)
			continue
		}

		fmt.Printf("Received face tracking data:\n")
		fmt.Printf("TimeCode: %v\n", data.TimeCode)
		fmt.Printf("TongueOut: %v\n", data.TongueOut)
	}
}
