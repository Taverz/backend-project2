package testutil

import (
	"testing"

	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
)

func TestNewEmail_Valid(t *testing.T) {
	email, err := domainUser.NewEmail("test@example.com")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if string(email) != "test@example.com" {
		t.Fatalf("expected test@example.com, got %s", email)
	}
}

func TestNewEmail_TrimAndLower(t *testing.T) {
	email, err := domainUser.NewEmail("  User@Example.COM  ")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if string(email) != "user@example.com" {
		t.Fatalf("expected user@example.com, got %s", email)
	}
}

func TestNewEmail_Invalid(t *testing.T) {
	_, err := domainUser.NewEmail("not-an-email")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestNewEmail_Empty(t *testing.T) {
	_, err := domainUser.NewEmail("")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestNewUsername_Valid(t *testing.T) {
	uname, err := domainUser.NewUsername("john_doe")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if string(uname) != "john_doe" {
		t.Fatalf("expected john_doe, got %s", uname)
	}
}

func TestNewUsername_TooShort(t *testing.T) {
	_, err := domainUser.NewUsername("ab")
	if err == nil {
		t.Fatal("expected error for short username")
	}
}

func TestNewUsername_TooLong(t *testing.T) {
	long := "abcdefghijklmnopqrstuvwxyz1234567890"
	_, err := domainUser.NewUsername(long)
	if err == nil {
		t.Fatal("expected error for long username")
	}
}

func TestNewUsername_InvalidChars(t *testing.T) {
	_, err := domainUser.NewUsername("user name!")
	if err == nil {
		t.Fatal("expected error for invalid chars")
	}
}

func TestNewUsername_Lowercased(t *testing.T) {
	uname, _ := domainUser.NewUsername("JohnDoe")
	if string(uname) != "johndoe" {
		t.Fatalf("expected johndoe, got %s", uname)
	}
}

func TestNewPassword_Valid(t *testing.T) {
	pwd, err := domainUser.NewPassword("secret123")
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if string(pwd) != "secret123" {
		t.Fatalf("expected secret123, got %s", pwd)
	}
}

func TestNewPassword_TooShort(t *testing.T) {
	_, err := domainUser.NewPassword("1234567")
	if err == nil {
		t.Fatal("expected error for short password")
	}
}

func TestNewPassword_TooLong(t *testing.T) {
	long := make([]byte, 73)
	for i := range long {
		long[i] = 'a'
	}
	_, err := domainUser.NewPassword(string(long))
	if err == nil {
		t.Fatal("expected error for long password")
	}
}
