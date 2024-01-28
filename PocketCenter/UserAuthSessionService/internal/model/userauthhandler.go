package model

// UserLoginRequest represents the request body for a login attempt
type UserLoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// UserRegisterResponse represents the response body for a successful registration
type UserRegisterResponse struct {
	Message string `json:"message"`
}

// UserLoginResponse represents the response body for a successful login
type UserLoginResponse struct {
	Token string `json:"token"`
}

// UserInfoResponse represents the response body for a successful token validation
type UserInfoResponse struct {
	Username string `json:"username"`
}
