package model

type PocketActionDocument struct {
	Actions []Action `json:"actions"`
}

type Action struct {
	DisplayName string `json:"displayName"`
	Type        string `json:"type"`
	Payload     string `json:"payload"`
}
