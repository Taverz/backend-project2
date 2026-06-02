package port

// PasswordHasher hashes and compares passwords.
type PasswordHasher interface {
	Hash(password string) (string, error)
	Compare(hash, password string) error
}
