package config

import (
	"os"

	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
)

// Config holds all configuration for the application.
type Config struct {
	HTTPPort string
	AppEnv   string

	// JWT secrets (hex-encoded)
	AccessTokenSecret  string
	RefreshTokenSecret string
}

// Load reads configuration from environment variables with sensible defaults.
func Load() (*Config, error) {
	accessSecret := getEnv("JWT_ACCESS_SECRET", "")
	refreshSecret := getEnv("JWT_REFRESH_SECRET", "")

	// Auto-generate secrets in development
	if accessSecret == "" && getEnv("APP_ENV", "development") == "development" {
		var err error
		accessSecret, err = memory.GenerateSecret()
		if err != nil {
			return nil, err
		}
		refreshSecret, err = memory.GenerateSecret()
		if err != nil {
			return nil, err
		}
	}

	return &Config{
		HTTPPort:           getEnv("HTTP_PORT", "8080"),
		AppEnv:             getEnv("APP_ENV", "development"),
		AccessTokenSecret:  accessSecret,
		RefreshTokenSecret: refreshSecret,
	}, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
