package api

import (
	"encoding/json"
	"net/http"
)

// ProblemDetail is an RFC 7807 error response.
type ProblemDetail struct {
	Type     string `json:"type"`
	Title    string `json:"title"`
	Status   int    `json:"status"`
	Detail   string `json:"detail,omitempty"`
	Instance string `json:"instance,omitempty"`
}

// Error writes an RFC 7807 Problem Details response.
func Error(w http.ResponseWriter, status int, title, detail string) {
	w.Header().Set("Content-Type", "application/problem+json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(ProblemDetail{
		Type:   "about:blank",
		Title:  title,
		Status: status,
		Detail: detail,
	})
}

// BadRequest writes a 400 error.
func BadRequest(w http.ResponseWriter, detail string) {
	Error(w, http.StatusBadRequest, "Bad Request", detail)
}

// NotFound writes a 404 error.
func NotFound(w http.ResponseWriter, detail string) {
	Error(w, http.StatusNotFound, "Not Found", detail)
}

// InternalError writes a 500 error.
func InternalError(w http.ResponseWriter, detail string) {
	Error(w, http.StatusInternalServerError, "Internal Server Error", detail)
}

// Unauthorized writes a 401 error.
func Unauthorized(w http.ResponseWriter, detail string) {
	Error(w, http.StatusUnauthorized, "Unauthorized", detail)
}

// Forbidden writes a 403 error.
func Forbidden(w http.ResponseWriter, detail string) {
	Error(w, http.StatusForbidden, "Forbidden", detail)
}

// Conflict writes a 409 error.
func Conflict(w http.ResponseWriter, detail string) {
	Error(w, http.StatusConflict, "Conflict", detail)
}
