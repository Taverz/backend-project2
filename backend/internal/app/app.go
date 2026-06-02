package app

import (
	"context"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	httpSwagger "github.com/swaggo/http-swagger"

	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
	"github.com/nikitakovalevtaverz/chirp/internal/transport"
	appmw "github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	usecaseTweet "github.com/nikitakovalevtaverz/chirp/internal/usecase/tweet"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// App is the main application struct that holds the HTTP server
// and all dependencies.
type App struct {
	server *http.Server
}

// New creates a new App with all dependencies wired up.
func New(cfg *config.Config) (*App, error) {
	// --- Adapters ---
	userRepo := memory.NewUserRepo()
	passwordHasher := memory.NewPasswordHasher(10)
	authSvc, err := memory.NewAuthService(cfg.AccessTokenSecret, cfg.RefreshTokenSecret)
	if err != nil {
		return nil, err
	}

	// --- Adapters ---
	tweetRepo := memory.NewTweetRepo()

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
		// Public
		r.Get("/health", healthHandler)
		r.Get("/hello", helloHandler)

		r.Route("/auth", func(r chi.Router) {
			r.Post("/register", authHandler.Register)
			r.Post("/login", authHandler.Login)
		})

		// Tweets (public read)
		r.Get("/tweets/{id}", tweetHandler.Get)
		r.Get("/users/{id}/tweets", tweetHandler.ListByUser)

		// Protected
		r.Group(func(r chi.Router) {
			r.Use(authGuard.Middleware)
			r.Get("/users/me", userHandler.Me)
			r.Post("/tweets", tweetHandler.Create)
			r.Delete("/tweets/{id}", tweetHandler.Delete)
		})
	})

	// Swagger UI
	r.Get("/swagger/*", httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"),
	))

	return &App{
		server: &http.Server{
			Addr:    ":" + cfg.HTTPPort,
			Handler: r,
		},
	}, nil
}

// ListenAndServe starts the HTTP server.
func (a *App) ListenAndServe() error {
	return a.server.ListenAndServe()
}

// Shutdown gracefully shuts down the HTTP server.
func (a *App) Shutdown(ctx context.Context) error {
	return a.server.Shutdown(ctx)
}

// healthHandler responds with service status.
//
//	@Summary		Health check
//	@Description	Returns service health status.
//	@Tags			system
//	@Produce		plain
//	@Success		200	{string}	string	"ok"
//	@Router			/health [get]
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))
}

// helloHandler responds with a greeting.
//
//	@Summary		Hello world
//	@Description	Returns a hello world JSON message.
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	map[string]string
//	@Router			/hello [get]
func helloHandler(w http.ResponseWriter, r *http.Request) {
	api.RespondOK(w, map[string]string{"message": "hello world"})
}
