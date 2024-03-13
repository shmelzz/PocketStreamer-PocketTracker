package model

import "time"

type TwitchChannelValidationRequest struct {
	Channel string `json:"channel"`
}

type TwitchChannelValidationResponse struct {
	IsLive bool `json:"is_live"`
}

type GetTwitchUserResponse struct {
	Data []struct {
		ID              string `json:"id"`
		Login           string `json:"login"`
		DisplayName     string `json:"display_name"`
		Type            string `json:"type"`
		BroadcasterType string `json:"broadcaster_type"`
		Description     string `json:"description"`
		ProfileImageURL string `json:"profile_image_url"`
		OfflineImageURL string `json:"offline_image_url"`
		ViewCount       int    `json:"view_count"`
		Email           string `json:"email"`
		CreatedAt       string `json:"created_at"`
	} `json:"data"`
}

type GetStreamResponse struct {
	Data []struct {
		ID              string    `json:"id"`
		UserID          string    `json:"user_id"`
		UserLogin       string    `json:"user_login"`
		UserName        string    `json:"user_name"`
		GameID          string    `json:"game_id"`
		GameName        string    `json:"game_name"`
		Type            string    `json:"type"`
		Title           string    `json:"title"`
		Tags            []string  `json:"tags"`
		ViewerCount     int       `json:"viewer_count"`
		StartedAt       time.Time `json:"started_at"`
		Language        string    `json:"language"`
		ThumbnailURL    string    `json:"thumbnail_url"`
		TagIds          []string  `json:"tag_ids"`
		IsMatureContent bool      `json:"is_mature"`
	} `json:"data"`
	Pagination struct {
		Cursor string `json:"cursor"`
	} `json:"pagination"`
}
