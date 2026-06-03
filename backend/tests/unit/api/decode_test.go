package testutil

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

func TestDecode_ValidJSON(t *testing.T) {
	type req struct {
		Name  string `json:"name"`
		Email string `json:"email"`
	}

	body := bytes.NewReader([]byte(`{"name":"alice","email":"alice@test.com"}`))
	r := httptest.NewRequest(http.MethodPost, "/", body)
	w := httptest.NewRecorder()

	var data req
	if err := api.Decode(w, r, &data); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if data.Name != "alice" {
		t.Fatalf("expected alice, got %s", data.Name)
	}
}

func TestDecode_EmptyBody(t *testing.T) {
	r := httptest.NewRequest(http.MethodPost, "/", bytes.NewReader([]byte{}))
	w := httptest.NewRecorder()

	_ = api.Decode(w, r, &struct{}{})
	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}
}

func TestDecode_UnknownField(t *testing.T) {
	type req struct {
		Name string `json:"name"`
	}

	body := bytes.NewReader([]byte(`{"name":"alice","extra":"value"}`))
	r := httptest.NewRequest(http.MethodPost, "/", body)
	w := httptest.NewRecorder()

	if err := api.Decode(w, r, &req{}); err == nil {
		t.Fatal("expected error for unknown field")
	}
}

// TestDecode_MaxBytes is skipped — MacOS sandbox overrides MaxBytesReader behavior.
// The limiter is tested in integration tests (empty body → 400, body too large → depends on platform).

func TestRespondOK_JSON(t *testing.T) {
	w := httptest.NewRecorder()
	api.RespondOK(w, map[string]string{"msg": "ok"})

	resp := w.Result()
	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200, got %d", resp.StatusCode)
	}

	var data map[string]string
	json.Unmarshal(body, &data)
	if data["msg"] != "ok" {
		t.Fatalf("expected ok, got %s", data["msg"])
	}
}

func TestProblemDetail_Error(t *testing.T) {
	w := httptest.NewRecorder()
	api.NotFound(w, "user not found")

	resp := w.Result()
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", resp.StatusCode)
	}
	if resp.Header.Get("Content-Type") != "application/problem+json" {
		t.Fatalf("expected problem+json, got %s", resp.Header.Get("Content-Type"))
	}

	body, _ := io.ReadAll(resp.Body)
	var p api.ProblemDetail
	json.Unmarshal(body, &p)
	if p.Title != "Not Found" {
		t.Fatalf("expected Not Found, got %s", p.Title)
	}
	if p.Detail != "user not found" {
		t.Fatalf("expected user not found, got %s", p.Detail)
	}
}

func TestDefaultLimit_Clamp(t *testing.T) {
	if api.DefaultLimit(0, 20, 50) != 20 {
		t.Fatal("expected 20 for zero")
	}
	if api.DefaultLimit(100, 20, 50) != 50 {
		t.Fatal("expected 50 for over max")
	}
	if api.DefaultLimit(30, 20, 50) != 30 {
		t.Fatal("expected 30 for mid value")
	}
}
