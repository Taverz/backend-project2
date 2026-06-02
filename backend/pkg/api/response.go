package api

import (
	"encoding/json"
	"net/http"
)

// Respond writes a JSON response with the given status code.
func Respond(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if v != nil {
		json.NewEncoder(w).Encode(v)
	}
}

// RespondOK writes a 200 JSON response.
func RespondOK(w http.ResponseWriter, v any) {
	Respond(w, http.StatusOK, v)
}

// RespondCreated writes a 201 JSON response.
func RespondCreated(w http.ResponseWriter, v any) {
	Respond(w, http.StatusCreated, v)
}

// RespondNoContent writes a 204 No Content response.
func RespondNoContent(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
}
