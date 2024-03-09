package service

import (
	"bytes"
	"encoding/json"
	"net/http"
	"streamingservice/internal/model"
	"strings"

	"go.uber.org/zap"
)

// TODO: Actions ?
// Camera angle change?
// Some actions with effects

type PocketActionService struct {
	pocketActionAddress string
}

func NewPocketActionService(pocketActionAddress string) *PocketActionService {
	return &PocketActionService{
		pocketActionAddress: pocketActionAddress,
	}
}

func (p *PocketActionService) ProcessChat(token string, sessionId string, message model.LiveChatMessage) error {
	action := parseCommandPayload(message)
	p.sendToPocketAction(token, sessionId, action)
	return nil
}

func parseCommandPayload(message model.LiveChatMessage) model.PocketAction {
	// Check if the string starts with "/"
	input := message.Message
	if !strings.HasPrefix(input, "!") {
		return model.PocketAction{
			Type:    "Invalid",
			Payload: "",
		} // Return empty strings if the input is not a command
	}

	// Split the string into command and payload
	parts := strings.SplitN(input, " ", 2)
	command := parts[0]
	var payload string
	if len(parts) > 1 {
		payload = parts[1]
	}

	return model.PocketAction{
		Type:    command,
		Payload: payload,
	}
}

func (p *PocketActionService) sendToPocketAction(token string, sessionId string, pocketAction model.PocketAction) error {
	jsonBytes, _ := json.Marshal(pocketAction)
	body := bytes.NewReader(jsonBytes)
	req, err := http.NewRequest("POST", p.pocketActionAddress+"/action/pocketaction", body)
	if err != nil {
		return err
	}

	// Add the token to the request header
	req.Header.Add("Authentication", token)
	req.Header.Add("SessionId", sessionId)
	req.Header.Set("Content-Type", "application/json")
	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		zap.S().Debug(err.Error())
		return err
	}
	defer resp.Body.Close()

	// Check the response
	if resp.StatusCode != http.StatusOK {
		return nil
	}

	return nil
}
