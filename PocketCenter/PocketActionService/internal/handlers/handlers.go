package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"pocketaction/internal/model"
	"pocketaction/internal/service"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

type PocketActionHandler struct {
	broadcastService *service.BroadcastService
	documentService  *service.DocumentService
	userAuthAddress  string
	logger           *zap.Logger
}

func NewPocketActionHandler(
	broadcastService *service.BroadcastService,
	documentService *service.DocumentService,
	userAuthAddress string,
	zapLogger *zap.Logger,
) *PocketActionHandler {
	return &PocketActionHandler{
		broadcastService: broadcastService,
		userAuthAddress:  userAuthAddress,
		documentService:  documentService,
		logger:           zapLogger,
	}
}

// PocketAction godoc
// @Summary Trigger PocketAction
// @Description Trigger Action, send to Composer use websocket
// @Tags action
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Param action body model.PocketAction true "PocketAction request"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /pocketaction [post]
func (p *PocketActionHandler) HandlePocketAction(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	ok, username, err := p.validateToken(token)
	if err != nil {
		p.logger.Sugar().Errorf(err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"message": "Error when try to validate"})
		return
	}
	if !ok {
		p.logger.Sugar().Infof("Validation not passed")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Validation not passed"})
		return
	}
	// Use gin to read the request data
	var pocketAction model.PocketAction
	if err := c.BindJSON(&pocketAction); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		p.logger.Sugar().Infof("Error reading JSON: %s", err.Error(), zap.String("username", username))
		return
	}

	// Struct to byte -> send to broadcast
	jsonBytes, _ := json.Marshal(pocketAction)
	err = p.broadcastService.Broadcast(jsonBytes, c.Request.Header.Get("SessionId"))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		p.logger.Sugar().Infof("Cant found session Id : %s", err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "success"})
	p.logger.Sugar().Infow("Pocket action handled successfully",
		zap.String("type", pocketAction.Type),
		zap.String("payload", pocketAction.Payload))
}

// PocketAction document godoc
// @Summary Get global PocketAction document
// @Description Get global PocketAction document
// @Tags action
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Success 200 {object} model.PocketActionDocument "PocketAction document"
// @Failure 404 "Not Found"
// @Router /document [get]
func (p *PocketActionHandler) HandlePocketActionDocument(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	ok, _, err := p.validateToken(token)
	if err != nil {
		p.logger.Sugar().Errorf(err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"message": "Error when try to validate"})
		return
	}
	if !ok {
		p.logger.Sugar().Infof("Validation not passed")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Validation not passed"})
		return
	}
	document, err := p.documentService.GetActionDocument()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Cant parse actions"})
		return
	}
	c.JSON(http.StatusOK, document)
}

func (p *PocketActionHandler) HandleVersion(c *gin.Context) {
	response := model.Version{
		Version: "1.1.1",
	}

	c.JSON(http.StatusOK, response)
}

func (f *PocketActionHandler) validateToken(token string) (bool, string, error) {
	// Create a new request to the userauthsessionservice
	req, err := http.NewRequest("POST", f.userAuthAddress+"/auth/validate", nil)
	if err != nil {
		return false, "", err
	}

	// Add the token to the request header
	req.Header.Add("Authentication", token)

	// Send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return false, "", err
	}
	defer resp.Body.Close()

	// Check the response
	if resp.StatusCode != http.StatusOK {
		return false, "", nil
	}

	var result map[string]string
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return false, "", err
	}

	// Extract the username from the response
	username, ok := result["username"]
	if !ok {
		return false, "", fmt.Errorf("Username not found in response")
	}

	return true, username, nil
}

// Websocket connect handler
func (f *PocketActionHandler) HandleReceiver(c *gin.Context) {
	r := c.Request
	w := c.Writer
	token := r.Header.Get("Authentication")
	session := r.Header.Get("SessionId")
	ok, username, err := f.validateToken(token)
	if err != nil {
		f.logger.Sugar().Error(err)
		c.JSON(http.StatusBadRequest, "Error when try to validate")
		return
	}
	if !ok {
		f.logger.Sugar().Info("Validation not passed")
		c.JSON(http.StatusUnauthorized, "Validation not passed")
		return
	}

	client, err := f.broadcastService.AddComposer(w, r)
	if err != nil {
		f.logger.Sugar().Error(err, zap.String("username", username))
		f.broadcastService.RemoveComposerClient(session)
		return
	}

	go func() {
		defer f.broadcastService.RemoveComposerClient(session)

		for {
			select {
			case message, ok := <-client.Send:
				if !ok {
					// The send channel was closed
					return
				}
				err := f.broadcastService.SendToClient(client, message)
				if err != nil {
					f.logger.Sugar().Error("Error writing message:", err)
					return
				}
			}
		}
	}()
}

// PocketAction presentation godoc
// @Summary Get presentation link by page document
// @Description Get presentation link by page document
// @Tags action
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /presentation [get]
func (p *PocketActionHandler) HandlePresentation(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	ok, username, err := p.validateToken(token)
	if err != nil {
		p.logger.Sugar().Errorf(err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"message": "Error when try to validate"})
		return
	}
	if !ok {
		p.logger.Sugar().Infof("Validation not passed")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Validation not passed"})
		return
	}
	document, err := p.documentService.GetPresentationPdfPath()
	p.logger.Sugar().Error(err, zap.String("username", username))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "cant get presentation processed, error: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, document)
}

// PocketAction presentation zip godoc
// @Summary Get presentation zip by page document
// @Description Get presentation zip by page document
// @Tags action
// @Accept json
// @Produce json
// @Param Authentication header string true "Authentication"
// @Param SessionId header string true "SessionId"
// @Success 200 "Ok"
// @Failure 404 "Not Found"
// @Router /presentation-zip [get]
func (p *PocketActionHandler) HandlePresentationZip(c *gin.Context) {
	token := c.Request.Header.Get("Authentication")
	sessionId := c.Request.Header.Get("SessionId")

	ok, username, err := p.validateToken(token)
	if err != nil {
		p.logger.Sugar().Errorf(err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"message": "Error when try to validate"})
		return
	}
	if !ok {
		p.logger.Sugar().Infof("Validation not passed")
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Validation not passed"})
		return
	}
	document, err := p.documentService.GetPresentationZipPath(sessionId)
	if err != nil {
		p.logger.Sugar().Error(err, zap.String("username", username))
		c.JSON(http.StatusBadRequest, gin.H{"message": "cant get presentation processed, error: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"imageFileExtension": document})
}
