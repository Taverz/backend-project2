package testutil

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/nikitakovalevtaverz/chirp/internal/app"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
)

// setupTestApp creates a fresh app with in-memory storage for integration tests.
func setupTestApp(t *testing.T) *app.App {
	t.Helper()
	cfg := &config.Config{
		HTTPPort:           "0",
		AppEnv:             "test",
		AccessTokenSecret:  "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b22",
		RefreshTokenSecret: "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b23",
	}
	a, err := app.New(cfg)
	if err != nil {
		t.Fatalf("failed to create app: %v", err)
	}
	return a
}

// jsonReader encodes v to JSON and returns a reader.
func jsonReader(v any) *bytes.Reader {
	data, _ := json.Marshal(v)
	return bytes.NewReader(data)
}

func TestIntegration_AuthFlow(t *testing.T) {
	a := setupTestApp(t)
	srv := httptest.NewServer(a.Server.Handler)
	defer srv.Close()

	// 1. Register
	resp, err := http.Post(srv.URL+"/api/v1/auth/register", "application/json",
		jsonReader(map[string]string{
			"username": "integ_test",
			"email":    "integ@test.com",
			"password": "password123",
		}))
	if err != nil {
		t.Fatalf("register request failed: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("register: expected 201, got %d", resp.StatusCode)
	}

	var regResp struct {
		User struct {
			ID       string `json:"id"`
			Username string `json:"username"`
			Email    string `json:"email"`
		} `json:"user"`
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
	}
	json.NewDecoder(resp.Body).Decode(&regResp)
	resp.Body.Close()

	if regResp.User.Username != "integ_test" {
		t.Fatalf("expected integ_test, got %s", regResp.User.Username)
	}
	if regResp.AccessToken == "" {
		t.Fatal("expected non-empty access token")
	}

	// 2. Login
	resp, err = http.Post(srv.URL+"/api/v1/auth/login", "application/json",
		jsonReader(map[string]string{
			"email":    "integ@test.com",
			"password": "password123",
		}))
	if err != nil {
		t.Fatalf("login request failed: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("login: expected 200, got %d", resp.StatusCode)
	}

	var loginResp struct {
		AccessToken string `json:"access_token"`
	}
	json.NewDecoder(resp.Body).Decode(&loginResp)
	resp.Body.Close()

	token := loginResp.AccessToken

	// 3. Create tweet
	req, _ := http.NewRequest("POST", srv.URL+"/api/v1/tweets",
		jsonReader(map[string]string{"body": "integration test tweet"}))
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/json")

	resp, err = http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("create tweet failed: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("create tweet: expected 201, got %d", resp.StatusCode)
	}

	var tweetResp struct {
		ID string `json:"id"`
	}
	json.NewDecoder(resp.Body).Decode(&tweetResp)
	resp.Body.Close()

	// 4. Get tweet
	resp, err = http.Get(srv.URL + "/api/v1/tweets/" + tweetResp.ID)
	if err != nil {
		t.Fatalf("get tweet failed: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("get tweet: expected 200, got %d", resp.StatusCode)
	}
	resp.Body.Close()

	// 5. Register second user
	_, err = http.Post(srv.URL+"/api/v1/auth/register", "application/json",
		jsonReader(map[string]string{
			"username": "follower",
			"email":    "follower@test.com",
			"password": "password123",
		}))
	if err != nil {
		t.Fatalf("second register failed: %v", err)
	}

	// 6. Like tweet
	req, _ = http.NewRequest("POST", srv.URL+"/api/v1/tweets/"+tweetResp.ID+"/like", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err = http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("like failed: %v", err)
	}
	if resp.StatusCode != http.StatusNoContent {
		t.Fatalf("like: expected 204, got %d", resp.StatusCode)
	}
	resp.Body.Close()

	// 7. Delete tweet
	req, _ = http.NewRequest("DELETE", srv.URL+"/api/v1/tweets/"+tweetResp.ID, nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err = http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("delete failed: %v", err)
	}
	if resp.StatusCode != http.StatusNoContent {
		t.Fatalf("delete: expected 204, got %d", resp.StatusCode)
	}
	resp.Body.Close()
}

func TestIntegration_Unauthorized(t *testing.T) {
	a := setupTestApp(t)
	srv := httptest.NewServer(a.Server.Handler)
	defer srv.Close()

	// Try creating tweet without auth
	resp, err := http.Post(srv.URL+"/api/v1/tweets", "application/json",
		jsonReader(map[string]string{"body": "no auth"}))
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
	resp.Body.Close()

	// Try timeline without auth
	resp, err = http.Get(srv.URL + "/api/v1/timeline/home")
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
	resp.Body.Close()
}

func TestIntegration_Validation(t *testing.T) {
	a := setupTestApp(t)
	srv := httptest.NewServer(a.Server.Handler)
	defer srv.Close()

	// Register with short password
	resp, err := http.Post(srv.URL+"/api/v1/auth/register", "application/json",
		jsonReader(map[string]string{
			"username": "test",
			"email":    "test@test.com",
			"password": "123",
		}))
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected 400 for short password, got %d", resp.StatusCode)
	}
	resp.Body.Close()

	// Login with bad email
	resp, err = http.Post(srv.URL+"/api/v1/auth/login", "application/json",
		jsonReader(map[string]string{
			"email":    "notfound@test.com",
			"password": "password123",
		}))
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("expected 401 for bad login, got %d", resp.StatusCode)
	}
	resp.Body.Close()
}
