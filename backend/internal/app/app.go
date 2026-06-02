package app

import (
	"context"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	httpSwagger "github.com/swaggo/http-swagger"

	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/postgres"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/redis"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
	"github.com/nikitakovalevtaverz/chirp/internal/transport"
	appmw "github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	usecaseTweet "github.com/nikitakovalevtaverz/chirp/internal/usecase/tweet"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// App is the main application struct that holds the HTTP server
// and all dependencies.
type App struct {
	server   *http.Server
	pgPool   *postgres.Pool
	redisCli *redis.Client
}

// New creates a new App with all dependencies wired up.
func New(cfg *config.Config) (*App, error) {
	// --- Adapters (PG or memory) ---
	var (
		userRepo  port.UserRepository
		tweetRepo port.TweetRepository
		pgPool    *postgres.Pool
	)

	if cfg.DatabaseURL != "" {
		var err error
		pgPool, err = postgres.NewPool(context.Background(), cfg.DatabaseURL)
		if err != nil {
			return nil, err
		}
		userRepo = postgres.NewUserRepo(pgPool)
		tweetRepo = postgres.NewTweetRepo(pgPool)
	} else {
		slog.Warn("DATABASE_URL not set — using in-memory storage (data lost on restart)")
		userRepo = memory.NewUserRepo()
		tweetRepo = memory.NewTweetRepo()
	}

	// --- Redis (optional) ---
	var redisCli *redis.Client
	if cfg.RedisURL != "" {
		var err error
		redisCli, err = redis.NewClient(context.Background(), cfg.RedisURL, "", 0)
		if err != nil {
			slog.Warn("failed to connect to Redis, continuing without it", "error", err)
		}
	} else {
		slog.Warn("REDIS_URL not set — Redis disabled")
	}

	// --- Adapters ---
	passwordHasher := memory.NewPasswordHasher(10)
	authSvc, err := memory.NewAuthService(cfg.AccessTokenSecret, cfg.RefreshTokenSecret)
	if err != nil {
		return nil, err
	}

	// --- Use Cases ---
	registerUC := usecaseUser.NewRegisterUseCase(userRepo, passwordHasher, authSvc)
	loginUC := usecaseUser.NewLoginUseCase(userRepo, passwordHasher, authSvc)
	getProfileUC := usecaseUser.NewGetProfileUseCase(userRepo)

	createTweetUC := usecaseTweet.NewCreateUseCase(tweetRepo)
	getTweetUC := usecaseTweet.NewGetByIDUseCase(tweetRepo)
	listTweetsUC := usecaseTweet.NewListByUserUseCase(tweetRepo)
	deleteTweetUC := usecaseTweet.NewDeleteUseCase(tweetRepo)

	// --- Transport ---
	authHandler := transport.NewAuthHandler(registerUC, loginUC)
	userHandler := transport.NewUserHandler(getProfileUC)
	tweetHandler := transport.NewTweetHandler(createTweetUC, getTweetUC, listTweetsUC, deleteTweetUC)

	// --- Middleware ---
	authGuard := appmw.NewAuthGuard(authSvc)

	// --- Router ---
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)

	// API v1
	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/health", healthHandler)
		r.Get("/hello", helloHandler)

		r.Route("/auth", func(r chi.Router) {
			r.Post("/register", authHandler.Register)
			r.Post("/login", authHandler.Login)
		})

		r.Get("/tweets/{id}", tweetHandler.Get)
		r.Get("/users/{id}/tweets", tweetHandler.ListByUser)

		r.Group(func(r chi.Router) {
			r.Use(authGuard.Middleware)
			r.Get("/users/me", userHandler.Me)
			r.Post("/tweets", tweetHandler.Create)
			r.Delete("/tweets/{id}", tweetHandler.Delete)
		})
	})

	r.Get("/swagger/*", httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"),
	))

	return &App{
		server: &http.Server{
			Addr:    ":" + cfg.HTTPPort,
			Handler: r,
		},
		pgPool:   pgPool,
		redisCli: redisCli,
	}, nil
}

func (a *App) ListenAndServe() error {
	return a.server.ListenAndServe()
}

func (a *App) Shutdown(ctx context.Context) error {
	if a.redisCli != nil {
		a.redisCli.Close()
	}
	if a.pgPool != nil {
		a.pgPool.Close()
	}
	return a.server.Shutdown(ctx)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	api.RespondOK(w, map[string]string{"message": "hello world"})
}
