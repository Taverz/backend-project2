package testutil

import (
	"context"
	"testing"

	"github.com/google/uuid"
	domainUser "github.com/nikitakovalevtaverz/chirp/internal/domain/user"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
)

func TestRegister_Success(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()
	uc := usecaseUser.NewRegisterUseCase(userRepo, hasher, authSvc)

	resp, err := uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "alice@test.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if resp.User.Username != "alice" {
		t.Fatalf("expected username alice, got %s", resp.User.Username)
	}
	if resp.User.Email != "alice@test.com" {
		t.Fatalf("expected email alice@test.com, got %s", resp.User.Email)
	}
	if resp.AccessToken == "" {
		t.Fatal("expected non-empty access token")
	}
	if resp.RefreshToken == "" {
		t.Fatal("expected non-empty refresh token")
	}
}

func TestRegister_DuplicateEmail(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()
	uc := usecaseUser.NewRegisterUseCase(userRepo, hasher, authSvc)

	// Register first user
	_, err := uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "alice@test.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("first register failed: %v", err)
	}

	// Try duplicate email
	_, err = uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "bob",
		Email:    "alice@test.com",
		Password: "password456",
	})
	if err != domainUser.ErrEmailTaken {
		t.Fatalf("expected ErrEmailTaken, got %v", err)
	}
}

func TestRegister_DuplicateUsername(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()
	uc := usecaseUser.NewRegisterUseCase(userRepo, hasher, authSvc)

	_, err := uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "alice@test.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("first register failed: %v", err)
	}

	_, err = uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "bob@test.com",
		Password: "password456",
	})
	if err != domainUser.ErrUsernameTaken {
		t.Fatalf("expected ErrUsernameTaken, got %v", err)
	}
}

func TestRegister_ShortPassword(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()
	uc := usecaseUser.NewRegisterUseCase(userRepo, hasher, authSvc)

	_, err := uc.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "alice@test.com",
		Password: "123",
	})
	if err == nil {
		t.Fatal("expected error for short password")
	}
}

func TestLogin_Success(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()

	// Pre-register
	regUC := usecaseUser.NewRegisterUseCase(userRepo, hasher, authSvc)
	_, err := regUC.Execute(context.Background(), usecaseUser.RegisterInput{
		Username: "alice",
		Email:    "alice@test.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("register failed: %v", err)
	}

	// Login
	loginUC := usecaseUser.NewLoginUseCase(userRepo, hasher, authSvc)
	resp, err := loginUC.Execute(context.Background(), usecaseUser.LoginInput{
		Email:    "alice@test.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if resp.User.Username != "alice" {
		t.Fatalf("expected alice, got %s", resp.User.Username)
	}
}

func TestLogin_InvalidCredentials(t *testing.T) {
	userRepo := NewMockUserRepo()
	hasher := NewMockPasswordHasher()
	authSvc := NewMockAuthService()

	loginUC := usecaseUser.NewLoginUseCase(userRepo, hasher, authSvc)
	_, err := loginUC.Execute(context.Background(), usecaseUser.LoginInput{
		Email:    "nonexistent@test.com",
		Password: "wrong",
	})
	if err != domainUser.ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestGetProfile_NotFound(t *testing.T) {
	userRepo := NewMockUserRepo()
	uc := usecaseUser.NewGetProfileUseCase(userRepo)

	_, err := uc.Execute(context.Background(), uuid.New().String())
	if err != domainUser.ErrUserNotFound {
		t.Fatalf("expected ErrUserNotFound, got %v", err)
	}
}
