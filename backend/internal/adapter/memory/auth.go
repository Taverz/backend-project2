package memory

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
)

// AuthService issues and validates JWT tokens.
type AuthService struct {
	accessSecret  []byte
	refreshSecret []byte
	accessTTL     time.Duration
	refreshTTL    time.Duration
}

// NewAuthService creates a JWT AuthService.
// secrets: access and refresh signing keys (hex-encoded).
func NewAuthService(accessSecretHex, refreshSecretHex string) (*AuthService, error) {
	accessSecret, err := hex.DecodeString(accessSecretHex)
	if err != nil {
		return nil, fmt.Errorf("invalid access secret: %w", err)
	}
	refreshSecret, err := hex.DecodeString(refreshSecretHex)
	if err != nil {
		return nil, fmt.Errorf("invalid refresh secret: %w", err)
	}
	return &AuthService{
		accessSecret:  accessSecret,
		refreshSecret: refreshSecret,
		accessTTL:     15 * time.Minute,
		refreshTTL:    7 * 24 * time.Hour,
	}, nil
}

func (s *AuthService) IssueTokenPair(_ context.Context, userID string) (*port.TokenPair, error) {
	now := time.Now()

	accessClaims := jwt.MapClaims{
		"sub": userID,
		"iat": now.Unix(),
		"exp": now.Add(s.accessTTL).Unix(),
	}
	accessToken, err := s.sign(accessClaims, s.accessSecret)
	if err != nil {
		return nil, fmt.Errorf("sign access token: %w", err)
	}

	refreshClaims := jwt.MapClaims{
		"sub": userID,
		"iat": now.Unix(),
		"exp": now.Add(s.refreshTTL).Unix(),
	}
	refreshToken, err := s.sign(refreshClaims, s.refreshSecret)
	if err != nil {
		return nil, fmt.Errorf("sign refresh token: %w", err)
	}

	return &port.TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}

func (s *AuthService) ValidateAccessToken(_ context.Context, tokenString string) (string, error) {
	token, err := jwt.Parse(tokenString, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return s.accessSecret, nil
	})
	if err != nil {
		return "", fmt.Errorf("parse token: %w", err)
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", fmt.Errorf("invalid token")
	}

	sub, ok := claims["sub"].(string)
	if !ok {
		return "", fmt.Errorf("sub claim missing")
	}

	return sub, nil
}

func (s *AuthService) sign(claims jwt.MapClaims, secret []byte) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secret)
}

// GenerateSecret returns a random 32-byte hex string for use as a JWT secret.
func GenerateSecret() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
