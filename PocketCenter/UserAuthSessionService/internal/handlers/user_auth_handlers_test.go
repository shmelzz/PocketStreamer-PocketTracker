package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"userauth/internal/model"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Define an interface that matches the service.SessionService interface
type mockSessionService struct {
	mock.Mock
}

func (m *mockSessionService) GetSessionId(ctx context.Context) (string, error) {
	args := m.Called(ctx)
	return args.String(0), args.Error(1)
}

func (m *mockSessionService) deleteSessionId(ctx context.Context, sessionId string) error {
	args := m.Called(ctx, sessionId)
	return args.Error(0)
}

func (m *mockSessionService) WaitForTracker(ctx context.Context, sessionId string) (model.WaitForTrackerResponse, error) {
	args := m.Called(ctx, sessionId)
	return args.Get(0).(model.WaitForTrackerResponse), args.Error(1)
}

func (m *mockSessionService) FindComposer(ctx context.Context, sessionId string, username string, token string) error {
	args := m.Called(ctx, sessionId, username, token)
	return args.Error(0)
}

func TestUserAuthHandler_GetSession(t *testing.T) {
	// Create a mock session service
	mockService := new(mockSessionService)
	mockService.On("GetSessionId", mock.Anything).Return("session123", nil)

	// Create a new UserAuthHandler instance with the mock service
	handler := NewUserAuthHandler(nil, mockService)

	// Create a new Gin context for the test
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)

	// Call the GetSession function
	handler.GetSession(c)

	// Assert the response status code
	assert.Equal(t, http.StatusOK, w.Code)

	// Assert the response body
	var response model.GetSessionResponse
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "session123", response.SessionId)

	// Assert that the mock service's GetSessionId method was called
	mockService.AssertCalled(t, "GetSessionId", mock.Anything)
}
