// Package main is the entry point for Chirp backend.
//
// @title           Chirp API
// @version         1.0.0
// @description     Twitter clone backend API.
// @contact.name    Chirp Team
// @contact.email   dev@chirp.local
// @license.name    MIT
// @host            localhost:8080
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/nikitakovalevtaverz/chirp/docs"

	"github.com/nikitakovalevtaverz/chirp/internal/app"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	application, err := app.New(cfg)
	if err != nil {
		log.Fatalf("failed to create app: %v", err)
	}

	serverErr := make(chan error, 1)
	go func() {
		addr := fmt.Sprintf(":%s", cfg.HTTPPort)
		fmt.Printf("server listening on http://localhost%s\n", addr)
		if err := application.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			serverErr <- err
		}
	}()

	select {
	case err := <-serverErr:
		log.Fatalf("server error: %v", err)
	case <-ctx.Done():
		fmt.Println("\nshutting down...")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := application.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("shutdown error: %v", err)
	}

	fmt.Println("bye.")
}
