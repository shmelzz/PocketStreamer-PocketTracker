package repository

import (
	"fmt"
	"pocketaction/internal/model"
	"pocketaction/internal/util"
)

type AppwriteDocumentRepsitory struct {
	appwriteApiKey string
}

func NewAppwriteDocumentRepsitory(apiKey string) *AppwriteDocumentRepsitory {
	return &AppwriteDocumentRepsitory{
		appwriteApiKey: apiKey,
	}
}

func (a *AppwriteDocumentRepsitory) GetPocketActionDocument() ([]model.Action, error) {
	var client = NewClient()
	client.SetEndpoint("https://cloud.appwrite.io/v1")
	client.SetProject("65ee36f3d4d5d4a74ef1")
	client.SetKey(a.appwriteApiKey)
	documents, err := client.Call("GET", a.getPathListOfDocuments("pocket-streamer", "pocket-actions-service"), nil, nil)
	if err != nil {
		return nil, err
	}
	actions := []model.Action{}
	documentsArray := documents["documents"].([]interface{})
	for _, value := range documentsArray {
		document := value.(map[string]interface{})
		actions = append(actions,
			model.Action{
				DisplayName: util.ToString(document["displayName"]),
				Type:        util.ToString(document["type"]),
				Payload:     util.ToString(document["payload"]),
			})
	}
	return actions, nil

}

func (a *AppwriteDocumentRepsitory) getPathListOfDocuments(databaseId string, collectionId string) string {
	return fmt.Sprintf("/databases/%s/collections/%s/documents", databaseId, collectionId)
}
