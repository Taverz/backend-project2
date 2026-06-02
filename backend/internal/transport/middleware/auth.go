package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/nikitakovalevtaverz/chirp/internal/port"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// AuthGuard is an HTTP middleware that validates JWT access tokens.
type AuthGuard struct {
	authSvc port.AuthService
}

// NewAuthGuard creates an AuthGuard.
func NewAuthGuard(authSvc port.AuthService) *AuthGuard {
	return &AuthGuard{authSvc: authSvc}
}

// Middleware returns an HTTP middleware handler.
func (g *AuthGuard) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if header == "" {
			api.Unauthorized(w, "missing authorization header")
			return
		}

		if !strings.HasPrefix(header, "Bearer ") {
			api.Unauthorized(w, "authorization header must be Bearer <token>")
			return
		}

		token := strings.TrimPrefix(header, "Bearer ")
		userID, err := g.authSvc.ValidateAccessToken(r.Context(), token)
		if err != nil {
			api.Unauthorized(w, "invalid or expired token")
			return
		}

		ctx := context.WithValue(r.Context(), UserIDKey, userID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
