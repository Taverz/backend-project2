package port

import "context"

// TokenPair holds access and refresh tokens.
type TokenPair struct {
	AccessToken  string
	RefreshToken string
}

// AuthService issues and validates tokens.
type AuthService interface {
	IssueTokenPair(ctx context.Context, userID string) (*TokenPair, error)
	ValidateAccessToken(ctx context.Context, tokenString string) (string, error) // returns userID
}
