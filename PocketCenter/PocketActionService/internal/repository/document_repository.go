package repository

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"pocketaction/internal/model"
	"pocketaction/internal/util"
	"strings"
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

func (a *AppwriteDocumentRepsitory) GetFiles() (model.AppwriteFile, error) {
	var client = NewClient()
	client.SetEndpoint("https://cloud.appwrite.io/v1")
	client.SetProject("65ee36f3d4d5d4a74ef1")
	client.SetKey(a.appwriteApiKey)
	var presentationPdf = model.AppwriteFile{
		Id:       "0",
		Mimetype: "string",
	}
	response, err := client.Call("GET", a.getPathListOfFiles("pocket-presentation"), nil, nil)
	if err != nil {
		return presentationPdf, err
	}
	pdfs, ok := response["files"].([]interface{})
	if !ok {
		// Handle the case where the type assertion fails
		fmt.Println("Cat parse answer from appwrite list file")
		return presentationPdf, nil
	}
	for _, value := range pdfs {
		pdf := value.(map[string]interface{})
		presentationPdf = model.AppwriteFile{
			Id:       pdf["$id"].(string),
			Mimetype: pdf["mimeType"].(string),
		}
	}
	return presentationPdf, nil
}

func (a *AppwriteDocumentRepsitory) GetPdfs() (string, error) {
	file, err := a.GetFiles()
	if err != nil {
		return "", err
	}
	var client = NewClient()
	client.SetEndpoint("https://cloud.appwrite.io/v1")
	client.SetProject("65ee36f3d4d5d4a74ef1")
	client.SetKey(a.appwriteApiKey)
	fmt.Println(a.getPathGetFile("pocket-presentation", file.Id))
	response, err := client.RawCall("GET", a.getPathGetFile("pocket-presentation", file.Id), nil, nil)
	fmt.Println(response)
	filePath := "./1.pdf"
	a.downloadFile(*response, filePath)
	return filePath, nil
}

func (a *AppwriteDocumentRepsitory) getPathListOfDocuments(databaseId string, collectionId string) string {
	return fmt.Sprintf("/databases/%s/collections/%s/documents", databaseId, collectionId)
}

func (a *AppwriteDocumentRepsitory) getPathListOfFiles(bucketId string) string {
	return fmt.Sprintf("/storage/buckets/%s/files", bucketId)
}

func (a *AppwriteDocumentRepsitory) getPathGetFile(bucketId string, fileId string) string {
	return fmt.Sprintf("/storage/buckets/%s/files/%s/download", bucketId, fileId)
}

func (a *AppwriteDocumentRepsitory) downloadFile(response http.Response, filePath string) error {
	defer response.Body.Close()

	// Check the response status code
	if response.StatusCode != http.StatusOK {
		panic("Failed to download file")
	}

	// Extract filename from 'Content-Disposition' header if available
	contentDisposition := response.Header.Get("Content-Disposition")
	if contentDisposition != "" {
		parts := strings.Split(contentDisposition, ";")
		for _, part := range parts {
			if strings.HasPrefix(strings.TrimSpace(part), "filename=") {
				// filename = strings.Trim(strings.TrimSpace(part), "filename=")
				break
			}
		}
	}

	// Create a new file to save the downloaded file
	out, err := os.Create(filePath)
	if err != nil {
		panic(err)
	}
	defer out.Close()

	// Copy the response body to the file
	_, err = io.Copy(out, response.Body)
	if err != nil {
		panic(err)
	}
	return nil
}
