package memory

import (
	"golang.org/x/crypto/bcrypt"
)

// PasswordHasher hashes passwords with bcrypt.
type PasswordHasher struct {
	cost int
}

// NewPasswordHasher creates a PasswordHasher with the given bcrypt cost.
func NewPasswordHasher(cost int) *PasswordHasher {
	if cost < bcrypt.MinCost {
		cost = bcrypt.DefaultCost
	}
	return &PasswordHasher{cost: cost}
}

func (h *PasswordHasher) Hash(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), h.cost)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

func (h *PasswordHasher) Compare(hash, password string) error {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
}
