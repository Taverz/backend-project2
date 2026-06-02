package api

import (
	"net/http"
)

// Handler is a generic HTTP handler that:
//  1. Decodes the request body into In
//  2. Calls Fn with the decoded value
//  3. Responds with 200 and the returned Out
//
// If Decode or Fn returns an error, the error is propagated to the caller
// (the caller is responsible for writing the error response).
type Handler[In any, Out any] struct {
	Fn func(r *http.Request, in In) (Out, error)
}

// ServeHTTP implements http.Handler.
func (h Handler[In, Out]) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var in In
	if err := Decode(w, r, &in); err != nil {
		return // Decode already wrote the error
	}

	out, err := h.Fn(r, in)
	if err != nil {
		// Let the caller's middleware or the usecase handle domain errors.
		// For now, return 500.
		InternalError(w, err.Error())
		return
	}

	RespondOK(w, out)
}
