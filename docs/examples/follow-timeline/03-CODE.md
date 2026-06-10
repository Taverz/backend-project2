# Follow + Timeline — код

> AI генерирует код по одному файлу за раз.
> Порядок: domain → port → usecase → transport → adapter → wiring → migration.
> После каждого файла — `go build`. После всех — `go test ./...`.

---

## 1. Domain (2 файла)

**`backend/internal/domain/timeline/follow.go`** — сущность Follow
**`backend/internal/domain/timeline/entry.go`** — сущность Entry (лемента ленты)

Чистые Go-структуры, zero зависимостей от проекта.

```go
type Follow struct {
    FollowerID string
    FolloweeID string
    CreatedAt  time.Time
}

type Entry struct {
    RecipientID string
    TweetID     string
    AuthorID    string
    ScoredAt    time.Time
}
```

**`backend/internal/usecase/timeline/errors.go`** — ErrCannotFollowSelf

## 2. Port (2 файла)

**`backend/internal/port/follow_repo.go`** — FollowRepository (7 методов)
**`backend/internal/port/timeline_repo.go`** — TimelineRepository (2 метода)

Чистые интерфейсы. Адаптеры реализуют их.

## 3. UseCase (6 файлов)

| Файл | Что делает |
|------|-----------|
| `usecase/timeline/follow.go` | FollowUseCase — проверка self + exists + Follow |
| `usecase/timeline/unfollow.go` | UnfollowUseCase — Unfollow |
| `usecase/timeline/list_followers.go` | ListFollowersUseCase — ListFollowers + Count |
| `usecase/timeline/list_following.go` | ListFollowingUseCase — ListFollowing + Count |
| `usecase/timeline/fanout.go` | FanOutUseCase — всех подписчиков → AddEntry |
| `usecase/timeline/home_timeline.go` | GetHomeTimelineUseCase — пагинация из репо |

**Ключевой код — FanOutUseCase:**

```go
func (uc *FanOutUseCase) Execute(ctx, tweetID, authorID string) error {
    follows, _, _ := uc.followRepo.ListFollowers(ctx, authorID, 100000, "")
    for _, f := range follows {
        uc.timelineRepo.AddEntry(ctx, &Entry{
            RecipientID: f.FollowerID,
            TweetID:     tweetID,
            AuthorID:    authorID,
            ScoredAt:    time.Now().UTC(),
        })
    }
    return nil
}
```

**Почему limit=100000:** fan-out должен затронуть ВСЕХ подписчиков.
Пагинация для этого не подходит. Для MVP достаточно, для production — Kafka.

## 4. Transport (1 файл)

**`backend/internal/transport/follow_handler.go`**:

```go
FollowHandler struct {
    follow    *FollowUseCase
    unfollow  *UnfollowUseCase
    followers *ListFollowersUseCase
    following *ListFollowingUseCase
}
```

4 хендлера: Follow, Unfollow, Followers, Following.

**Особенности:**
- Followers/Following возвращают `total` (count), остальные эндпоинты — нет
- Follow/Unfollow → 204 No Content
- Followers/Following → 200 + PageResponse

## 5. Adapters (2 файла)

### In-memory

**`adapter/memory/follow_repo.go`**:

```go
type FollowRepo struct {
    mu        sync.RWMutex
    followers map[string]map[string]bool // userID → set of followerIDs
    following map[string]map[string]bool // userID → set of followeeIDs
}
```

**`adapter/memory/timeline_repo.go`**:

```go
type TimelineRepo struct {
    mu      sync.RWMutex
    entries map[string][]*Entry // userID → entries
}
```

Используется когда `DATABASE_URL` не задан (dev-режим).

### PostgreSQL (в планах)

Аналогичные структуры с SQL-запросами и pgx-пулом.

## 6. Wiring (app.go)

```go
followRepo := memory.NewFollowRepo()
timelineRepo := memory.NewTimelineRepo()

followUC := timeline.NewFollowUseCase(followRepo, userRepo)
unfollowUC := timeline.NewUnfollowUseCase(followRepo)
listFollowersUC := timeline.NewListFollowersUseCase(followRepo)
listFollowingUC := timeline.NewListFollowingUseCase(followRepo)
fanOutUC := timeline.NewFanOutUseCase(timelineRepo, followRepo)
homeTimelineUC := timeline.NewGetHomeTimelineUseCase(timelineRepo)

followHandler := transport.NewFollowHandler(followUC, unfollowUC, listFollowersUC, listFollowingUC)

r.Post("/users/{id}/follow", followHandler.Follow)
r.Delete("/users/{id}/follow", followHandler.Unfollow)
r.Get("/users/{id}/followers", followHandler.Followers)
r.Get("/users/{id}/following", followHandler.Following)
r.Get("/timeline/home", timelineHandler.Home)
```

FanOut вызывается из CreateTweetUseCase после сохранения твита.

## 7. Миграции (4 файла)

```
000003_create_follows.up.sql    → follows table + indexes
000003_create_follows.down.sql
000005_create_timeline.up.sql   → timeline table + indexes
000005_create_timeline.down.sql
```

---

## Порядок генерации

```
1. domain/timeline/follow.go         → go build
2. domain/timeline/entry.go          → go build
3. port/follow_repo.go               → go build
4. port/timeline_repo.go             → go build
5. usecase/timeline/errors.go        → go build
6. usecase/timeline/follow.go        → go build
7. usecase/timeline/unfollow.go      → go build
8. usecase/timeline/list_followers.go → go build
9. usecase/timeline/list_following.go → go build
10. usecase/timeline/fanout.go        → go build
11. usecase/timeline/home_timeline.go → go build
12. adapter/memory/follow_repo.go     → go build
13. adapter/memory/timeline_repo.go   → go build
14. transport/follow_handler.go       → go build
15. app.go (wiring)                   → go build
16. миграции                         → go build
17. go test ./...
```

15 файлов, ~400 строк кода. AI генерирует за 2-3 минуты,
проверяя каждый файл компиляцией.
