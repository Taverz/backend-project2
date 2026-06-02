package api

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strings"
)

// MaxBodySize limits request bodies to 1 MB.
const MaxBodySize = 1 << 20

// Decode reads and decodes JSON from r.Body into v.
// It enforces a maximum body size and rejects unknown fields.
func Decode(w http.ResponseWriter, r *http.Request, v any) error {
	r.Body = http.MaxBytesReader(w, r.Body, MaxBodySize)

	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()

	if err := dec.Decode(v); err != nil {
		var syntaxErr *json.SyntaxError
		var unmarshalTypeErr *json.UnmarshalTypeError

		switch {
		case errors.As(err, &syntaxErr):
			BadRequest(w, "invalid JSON syntax")
		case errors.As(err, &unmarshalTypeErr):
			BadRequest(w, "invalid type for field "+unmarshalTypeErr.Field)
		case strings.HasPrefix(err.Error(), "json: unknown field"):
			BadRequest(w, "unknown field in request body")
		case errors.Is(err, io.EOF):
			BadRequest(w, "request body is empty")
		case err.Error() == "http: request body too large":
			Error(w, http.StatusRequestEntityTooLarge, "Payload Too Large", "request body exceeds 1 MB")
		default:
			BadRequest(w, "invalid request body")
		}
		return err
	}

	if dec.More() {
		BadRequest(w, "request body must contain a single JSON object")
		return errors.New("multiple JSON values")
	}

	return nil
}

// DecodeStrict is an alias for Decode (disallows unknown fields).
func DecodeStrict(w http.ResponseWriter, r *http.Request, v any) error {
	return Decode(w, r, v)
}
