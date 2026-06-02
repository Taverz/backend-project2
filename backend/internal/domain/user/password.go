package user

// Password is a raw (unhashed) password.
type Password string

// NewPassword creates a validated Password.
func NewPassword(raw string) (Password, error) {
	switch {
	case len(raw) < 8:
		return "", ErrPasswordTooShort
	case len(raw) > 72: // bcrypt limit
		return "", ErrPasswordTooLong
	}
	return Password(raw), nil
}
