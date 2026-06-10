package app

import (
	"context"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	httpSwagger "github.com/swaggo/http-swagger"

	"github.com/nikitakovalevtaverz/chirp/internal/adapter/memory"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/postgres"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/redis"
	"github.com/nikitakovalevtaverz/chirp/internal/adapter/es"
	"github.com/nikitakovalevtaverz/chirp/internal/config"
	"github.com/nikitakovalevtaverz/chirp/internal/port"
	"github.com/nikitakovalevtaverz/chirp/internal/transport"
	appmw "github.com/nikitakovalevtaverz/chirp/internal/transport/middleware"
	usecaseNotif "github.com/nikitakovalevtaverz/chirp/internal/usecase/notification"
	usecaseSearch "github.com/nikitakovalevtaverz/chirp/internal/usecase/search"
	usecaseTL "github.com/nikitakovalevtaverz/chirp/internal/usecase/timeline"
	usecaseTweet "github.com/nikitakovalevtaverz/chirp/internal/usecase/tweet"
	usecaseUser "github.com/nikitakovalevtaverz/chirp/internal/usecase/user"
	"github.com/nikitakovalevtaverz/chirp/pkg/api"
)

// App is the main application struct that holds the HTTP server
// and all dependencies.
type App struct {
	Server   *http.Server
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
		pgCtx, pgCancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer pgCancel()
		pgPool, err = postgres.NewPool(pgCtx, cfg.DatabaseURL)
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
		redisCtx, redisCancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer redisCancel()
		redisCli, err = redis.NewClient(redisCtx, cfg.RedisURL, "", 0)
		if err != nil {
			slog.Warn("failed to connect to Redis, continuing without it", "error", err)
		}
	} else {
		slog.Warn("REDIS_URL not set — Redis disabled")
	}

	// --- Adapters (always in-memory for phase 2) ---
	followRepo := memory.NewFollowRepo()
	likeRepo := memory.NewLikeRepo()
	timelineRepo := memory.NewTimelineRepo()
	passwordHasher := memory.NewPasswordHasher(10)
	authSvc, err := memory.NewAuthService(cfg.AccessTokenSecret, cfg.RefreshTokenSecret)

	// --- Event Bus (memory or Kafka) ---
	eventBus := memory.NewEventBus()

	// --- Search Engine (memory or Elasticsearch) ---
	var searchEngine port.SearchEngine
	if cfg.ElasticsearchURL != "" {
		se, err := es.NewSearchEngine([]string{cfg.ElasticsearchURL})
		if err != nil {
			return nil, err
		}
		searchEngine = se
	} else {
		searchEngine = memory.NewSearchEngine()
	}

	// --- Notifications ---
	notifRepo := memory.NewNotificationRepo()
	if err != nil {
		return nil, err
	}
	registerUC := usecaseUser.NewRegisterUseCase(userRepo, passwordHasher, authSvc)
	loginUC := usecaseUser.NewLoginUseCase(userRepo, passwordHasher, authSvc)
	getProfileUC := usecaseUser.NewGetProfileUseCase(userRepo)

	createTweetUC := usecaseTweet.NewCreateUseCase(tweetRepo)
	getTweetUC := usecaseTweet.NewGetByIDUseCase(tweetRepo)
	listTweetsUC := usecaseTweet.NewListByUserUseCase(tweetRepo)
	deleteTweetUC := usecaseTweet.NewDeleteUseCase(tweetRepo)

	followUC := usecaseTL.NewFollowUseCase(followRepo, userRepo)
	unfollowUC := usecaseTL.NewUnfollowUseCase(followRepo)
	listFollowersUC := usecaseTL.NewListFollowersUseCase(followRepo)
	listFollowingUC := usecaseTL.NewListFollowingUseCase(followRepo)

	likeUC := usecaseTweet.NewLikeUseCase(likeRepo)
	unlikeUC := usecaseTweet.NewUnlikeUseCase(likeRepo)

	fanOutUC := usecaseTL.NewFanOutUseCase(timelineRepo, followRepo)
	homeTimelineUC := usecaseTL.NewGetHomeTimelineUseCase(timelineRepo)

	searchTweetUC := usecaseSearch.NewSearchTweetsUseCase(searchEngine)
	notifListUC := usecaseNotif.NewListUseCase(notifRepo)
	notifCountUC := usecaseNotif.NewCountUnreadUseCase(notifRepo)
	notifMarkReadUC := usecaseNotif.NewMarkReadUseCase(notifRepo)

	// --- Transport ---
	authHandler := transport.NewAuthHandler(registerUC, loginUC)
	userHandler := transport.NewUserHandler(getProfileUC)
	tweetHandler := transport.NewTweetHandler(createTweetUC, getTweetUC, listTweetsUC, deleteTweetUC, fanOutUC, searchEngine)
	followHandler := transport.NewFollowHandler(followUC, unfollowUC, listFollowersUC, listFollowingUC)
	searchHandler := transport.NewSearchHandler(searchTweetUC)
	notifHandler := transport.NewNotificationHandler(notifListUC, notifCountUC, notifMarkReadUC)

	// --- Event Subscribers ---
	transport.SetupNotificationSubscribers(eventBus, notifRepo)

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
		r.Get("/tweets/search", searchHandler.Search)
		r.Get("/users/{id}/tweets", tweetHandler.ListByUser)
		r.Get("/users/{id}/followers", followHandler.Followers)
		r.Get("/users/{id}/following", followHandler.Following)

		r.Route("/timeline", func(r chi.Router) {
			r.Use(authGuard.Middleware)
			r.Get("/home", timelineHandler(homeTimelineUC))
		})

		// Protected
		r.Group(func(r chi.Router) {
			r.Use(authGuard.Middleware)
			r.Get("/users/me", userHandler.Me)
			r.Post("/tweets", tweetHandler.Create)
			r.Delete("/tweets/{id}", tweetHandler.Delete)
			r.Post("/users/{id}/follow", followHandler.Follow)
			r.Delete("/users/{id}/follow", followHandler.Unfollow)
			r.Post("/tweets/{id}/like", likeHandler(likeUC, tweetRepo, eventBus))
			r.Delete("/tweets/{id}/like", unlikeHandler(unlikeUC))
			r.Get("/notifications", notifHandler.List)
			r.Post("/notifications/{id}/read", notifHandler.MarkRead)
		})
	})

	r.Get("/swagger/*", httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"),
	))

	return &App{
		Server: &http.Server{
			Addr:    ":" + cfg.HTTPPort,
			Handler: r,
		},
		pgPool:   pgPool,
		redisCli: redisCli,
	}, nil
}

func (a *App) ListenAndServe() error {
	return a.Server.ListenAndServe()
}

func (a *App) Shutdown(ctx context.Context) error {
	if a.redisCli != nil {
		a.redisCli.Close()
	}
	if a.pgPool != nil {
		a.pgPool.Close()
	}
	return a.Server.Shutdown(ctx)
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

func likeHandler(uc *usecaseTweet.LikeUseCase, tweetRepo port.TweetRepository, bus port.EventBus) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, _ := appmw.UserIDFromContext(r.Context())
		id := chi.URLParam(r, "id")
		if err := uc.Execute(r.Context(), userID, id); err != nil {
			api.InternalError(w, "internal server error")
			return
		}
		// Publish event for notifications
		t, _ := tweetRepo.GetByID(r.Context(), id)
		if t != nil {
			bus.Publish(r.Context(), "tweet.liked", port.Event{
				Type: "tweet.liked",
				Data: map[string]string{
					"tweet_id":        id,
					"actor_id":        userID,
					"tweet_author_id": t.AuthorID,
				},
			})
		}
		api.RespondNoContent(w)
	}
}

func unlikeHandler(uc *usecaseTweet.UnlikeUseCase) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, _ := appmw.UserIDFromContext(r.Context())
		id := chi.URLParam(r, "id")
		if err := uc.Execute(r.Context(), userID, id); err != nil {
			api.InternalError(w, "internal server error")
			return
		}
		api.RespondNoContent(w)
	}
}

func timelineHandler(uc *usecaseTL.GetHomeTimelineUseCase) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, _ := appmw.UserIDFromContext(r.Context())
		limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
		limit = api.DefaultLimit(limit, 20, 50)
		cursor := r.URL.Query().Get("cursor")

		entries, nextCursor, err := uc.Execute(r.Context(), userID, limit, cursor)
		if err != nil {
			api.InternalError(w, "internal server error")
			return
		}

		type item struct {
			TweetID  string `json:"tweet_id"`
			AuthorID string `json:"author_id"`
			ScoredAt string `json:"scored_at"`
		}
		items := make([]item, len(entries))
		for i, e := range entries {
			items[i] = item{
				TweetID:  e.TweetID,
				AuthorID: e.AuthorID,
				ScoredAt: e.ScoredAt.Format("2006-01-02T15:04:05Z"),
			}
		}

		api.RespondOK(w, map[string]any{
			"data":        items,
			"next_cursor": nextCursor,
			"has_more":    nextCursor != "",
		})
	}
}
