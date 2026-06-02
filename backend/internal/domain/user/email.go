package user

import (
	"net/mail"
	"strings"
)

// Email is a validated email address.
type Email string

// NewEmail creates a validated Email.
func NewEmail(raw string) (Email, error) {
	raw = strings.TrimSpace(strings.ToLower(raw))
	if raw == "" {
		return "", ErrEmailEmpty
	}
	addr, err := mail.ParseAddress(raw)
	if err != nil {
		return "", ErrEmailInvalid
	}
	return Email(addr.Address), nil
}
