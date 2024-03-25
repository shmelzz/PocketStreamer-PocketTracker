package model

type PocketAction struct {
	Type    string `json:"type"`
	Payload string `json:"payload"`
}

type AppwriteFile struct {
	Id       string
	Mimetype string
}
