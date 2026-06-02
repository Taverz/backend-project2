package user

import (
	"errors"
	"strings"
	"unicode/utf8"
)

// Validation errors.
var (
	ErrUsernameTooShort = errors.New("username: must be at least 3 characters")
	ErrUsernameTooLong  = errors.New("username: must be at most 30 characters")
	ErrUsernameInvalid  = errors.New("username: only letters, digits, and underscores allowed")
	ErrEmailEmpty       = errors.New("email: must not be empty")
	ErrEmailInvalid     = errors.New("email: invalid format")
	ErrPasswordTooShort = errors.New("password: must be at least 8 characters")
	ErrPasswordTooLong  = errors.New("password: must be at most 72 characters")
)

// Username validates and normalises a raw username string.
type Username string

// NewUsername creates a validated Username.
func NewUsername(raw string) (Username, error) {
	raw = strings.TrimSpace(raw)
	switch {
	case utf8.RuneCountInString(raw) < 3:
		return "", ErrUsernameTooShort
	case utf8.RuneCountInString(raw) > 30:
		return "", ErrUsernameTooLong
	case !isAlphanumericUnderscore(raw):
		return "", ErrUsernameInvalid
	}
	return Username(strings.ToLower(raw)), nil
}

func isAlphanumericUnderscore(s string) bool {
	for _, r := range s {
		if !((r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') || r == '_') {
			return false
		}
	}
	return true
}
