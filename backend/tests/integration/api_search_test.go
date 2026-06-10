package testutil

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/nikitakovalevtaverz/chirp/internal/app"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
)

func setupTest(t *testing.T) *httptest.Server {
	t.Helper()
	cfg := &config.Config{
		HTTPPort:           "0",
		AppEnv:             "test",
		AccessTokenSecret:  "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b22",
		RefreshTokenSecret: "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b23",
	}
	a, err := app.New(cfg)
	if err != nil {
		t.Fatalf("app.New: %v", err)
	}
	return httptest.NewServer(a.Server.Handler)
}

func requestJSON(method, url, body string) (*http.Response, error) {
	req, _ := http.NewRequest(method, url, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	return http.DefaultClient.Do(req)
}

func readJSON(r *http.Response, v any) error {
	defer r.Body.Close()
	return json.NewDecoder(r.Body).Decode(v)
}

func registerUser(srv *httptest.Server, username, email string) (string, error) {
	resp, err := requestJSON("POST", srv.URL+"/api/v1/auth/register",
		`{"username":"`+username+`","email":"`+email+`","password":"secret123"}`)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var reg struct {
		AccessToken string `json:"access_token"`
		User        struct {
			ID string `json:"id"`
		} `json:"user"`
	}
	json.NewDecoder(resp.Body).Decode(&reg)
	return reg.AccessToken, nil
}

func assertStatus(t *testing.T, got, want int) {
	t.Helper()
	if got != want {
		t.Fatalf("expected status %d, got %d", want, got)
	}
}

func TestIntegration_SearchAndNotifications(t *testing.T) {
	srv := setupTest(t)
	defer srv.Close()

	// Register user
	token, err := registerUser(srv, "alice_s", "alice_s@test.io")
	if err != nil {
		t.Fatalf("register failed: %v", err)
	}

	// Create tweet
	resp, err := requestJSON("POST", srv.URL+"/api/v1/tweets",
		`{"body":"searchable content for testing"}`)
	if err != nil {
		t.Fatalf("tweet failed: %v", err)
	}
	io.Copy(io.Discard, resp.Body)
	resp.Body.Close()
	assertStatus(t, resp.StatusCode, 401) // no auth

	// Create tweet with auth
	req, _ := http.NewRequest("POST", srv.URL+"/api/v1/tweets",
		strings.NewReader(`{"body":"searchable content for testing"}`))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err = http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("tweet failed: %v", err)
	}
	var tweetResp struct {
		ID string `json:"id"`
	}
	json.NewDecoder(resp.Body).Decode(&tweetResp)
	resp.Body.Close()
	assertStatus(t, resp.StatusCode, 201)

	// Search for it
	resp, err = http.Get(srv.URL + "/api/v1/tweets/search?q=searchable")
	if err != nil {
		t.Fatalf("search failed: %v", err)
	}
	var searchResp struct {
		Data []struct {
			TweetID string `json:"TweetID"`
			Body    string `json:"Body"`
		} `json:"data"`
	}
	json.NewDecoder(resp.Body).Decode(&searchResp)
	resp.Body.Close()
	assertStatus(t, resp.StatusCode, 200)
	if len(searchResp.Data) < 1 {
		t.Fatal("expected at least 1 search result")
	}
	if searchResp.Data[0].Body != "searchable content for testing" {
		t.Fatalf("wrong body in search: %s", searchResp.Data[0].Body)
	}

	// Register another user, like first tweet
	token2, err := registerUser(srv, "bob_s", "bob_s@test.io")
	if err != nil {
		t.Fatalf("second register: %v", err)
	}
	req2, _ := http.NewRequest("POST", srv.URL+"/api/v1/tweets/"+tweetResp.ID+"/like", nil)
	req2.Header.Set("Authorization", "Bearer "+token2)
	resp, err = http.DefaultClient.Do(req2)
	if err != nil {
		t.Fatalf("like failed: %v", err)
	}
	io.Copy(io.Discard, resp.Body)
	resp.Body.Close()
	assertStatus(t, resp.StatusCode, 204)

	// Check notifications for first user
	req3, _ := http.NewRequest("GET", srv.URL+"/api/v1/notifications", nil)
	req3.Header.Set("Authorization", "Bearer "+token)
	resp, err = http.DefaultClient.Do(req3)
	if err != nil {
		t.Fatalf("notifications failed: %v", err)
	}
	var notifResp struct {
		Data   []any `json:"data"`
		Unread int   `json:"unread"`
	}
	json.NewDecoder(resp.Body).Decode(&notifResp)
	resp.Body.Close()
	assertStatus(t, resp.StatusCode, 200)
	if notifResp.Unread < 1 {
		t.Fatal("expected at least 1 unread notification (like)")
	}
}
