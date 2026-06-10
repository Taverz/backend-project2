package config

import (
	"crypto/rand"
	"encoding/hex"
	"os"
)

// Config holds all configuration for the application.
type Config struct {
	HTTPPort string
	AppEnv   string

	// PostgreSQL
	DatabaseURL string

	// Redis
	RedisURL string

	// Elasticsearch / Kafka
	ElasticsearchURL string
	KafkaBrokers     string

	// JWT secrets (hex-encoded)
	AccessTokenSecret  string
	RefreshTokenSecret string
}

// Load reads configuration from environment variables with sensible defaults.
func Load() (*Config, error) {
	accessSecret := getEnv("JWT_ACCESS_SECRET", "")
	refreshSecret := getEnv("JWT_REFRESH_SECRET", "")

	// Auto-generate secrets in development only
	if accessSecret == "" && getEnv("APP_ENV", "development") == "development" {
		var err error
		accessSecret, err = generateSecret()
		if err != nil {
			return nil, err
		}
		refreshSecret, err = generateSecret()
		if err != nil {
			return nil, err
		}
	}

	return &Config{
		HTTPPort:           getEnv("HTTP_PORT", "8080"),
		AppEnv:             getEnv("APP_ENV", "development"),
		DatabaseURL:        getEnv("DATABASE_URL", ""),
		ElasticsearchURL:   getEnv("ELASTICSEARCH_URL", ""),
		KafkaBrokers:       getEnv("KAFKA_BROKERS", ""),
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

// generateSecret returns a random 32-byte hex string for use as a JWT secret.
func generateSecret() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
