# Chirp Backend — Design Document

> Архитектура, структура, потоки данных и API-дизайн Go-бэкенда.

---

## 1. Общая архитектура

```
┌──────────────────────────────────────────────────────┐
│                    Chi Router                        │
│  ┌──────────────────────────────────────────────┐    │
│  │              Middleware Stack                 │    │
│  │  Logger · Recoverer · RequestID · RealIP     │    │
│  │         ↓ AuthGuard (JWT validation)         │    │
│  └──────────────────┬───────────────────────────┘    │
│                     │                                │
│  ┌──────────────────▼───────────────────────────┐    │
│  │         HTTP Handlers (Transport)            │    │
│  │  Auth · User · Tweet · Follow · Timeline    │    │
│  └──────────────────┬───────────────────────────┘    │
│                     │                                │
│  ┌──────────────────▼───────────────────────────┐    │
│  │              Use Cases (Biz Logic)           │    │
│  │  Управляет транзакциями, валидирует бизнес-  │    │
│  │  правила, вызывает порты для сохранения      │    │
│  └──────┬─────────────────────┬─────────────────┘    │
│         │                     │                      │
│  ┌──────▼──────┐       ┌──────▼──────┐              │
│  │   Ports     │       │   Ports     │              │
│  │ (Interfaces)│       │ (Interfaces)│              │
│  └──────┬──────┘       └──────┬──────┘              │
│         │                     │                      │
│  ┌──────▼──────────┐  ┌──────▼──────────┐          │
│  │ Memory Adapter  │  │ PostgreSQL      │          │
│  │  (dev / test)   │  │  Adapter (prod) │          │
│  └─────────────────┘  └─────────────────┘          │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │         Domain Entities (Pure Go)           │    │
│  │  User · Tweet · Like · Follow · Timeline    │    │
│  │  Value Objects: Email, Username, Password   │    │
│  └─────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────┘
```

### 1.1 Dependency direction (строгая)

```
transport → usecase → port ← adapter
               ↓
            domain
```

- **domain**: zero dependencies on the project. Pure Go types + stdlib.
- **usecase**: depends on `domain` + `port` (interfaces only).
- **adapter**: depends on `port` and `domain`.
- **transport**: depends on `usecase` and `domain`.
- **port** (interfaces): depends on `domain`.

### 1.2 Почему модульный монолит

Одно приложение, один бинарник, одно развёртывание. Модули изолированы на уровне Go-пакетов, но вызывают друг друга напрямую через интерфейсы.

**Когда выносить в микросервис:** когда модуль требует независимого масштабирования или другого стека. Границы уже есть — нужно реализовать transport для выбранного протокола (gRPC, HTTP, Kafka).

---

## 2. Структура директорий

```
backend/
├── cmd/server/main.go           Точка входа, graceful shutdown
├── internal/
│   ├── app/app.go               DI-контейнер, wiring, роутинг
│   ├── config/config.go         Конфигурация из env-переменных
│   ├── domain/                   Доменные сущности
│   │   ├── user/                User, Profile, Email, Username, Password
│   │   ├── tweet/               Tweet, Like, Body
│   │   └── timeline/            Follow, Entry
│   ├── usecase/                  Бизнес-логика
│   │   ├── user/                Register, Login, GetProfile
│   │   ├── tweet/               Create, GetByID, ListByUser, Delete, Like, Unlike
│   │   └── timeline/            Follow, Unfollow, ListFollowers, ListFollowing,
│   │                            FanOut, GetHomeTimeline
│   ├── port/                     Интерфейсы (контракты между слоями)
│   │   ├── user.go              UserRepository (Create, GetByID, GetByEmail, GetByUsername)
│   │   ├── tweet_repo.go        TweetRepository
│   │   ├── like_repo.go         LikeRepository
│   │   ├── follow_repo.go       FollowRepository
│   │   ├── timeline_repo.go     TimelineRepository
│   │   ├── password.go          PasswordHasher (Hash, Compare)
│   │   └── auth.go              AuthService (IssueTokenPair, ValidateAccessToken)
│   ├── adapter/                  Реализации портов
│   │   ├── memory/              In-memory (development / тесты без БД)
│   │   │   ├── user_repo.go
│   │   │   ├── tweet_repo.go
│   │   │   ├── like_repo.go
│   │   │   ├── follow_repo.go
│   │   │   ├── timeline_repo.go
│   │   │   ├── password.go      bcrypt hasher
│   │   │   └── auth.go          JWT HS256
│   │   ├── postgres/            PostgreSQL (production)
│   │   │   ├── conn.go          pgxpool
│   │   │   ├── user_repo.go
│   │   │   └── tweet_repo.go
│   │   └── redis/conn.go        go-redis client
│   └── transport/                HTTP-хендлеры
│       ├── auth_handler.go      Register, Login
│       ├── user_handler.go      GetProfile
│       ├── tweet_handler.go     Create, Get, List, Delete, FanOut
│       ├── follow_handler.go    Follow, Unfollow, Followers, Following
│       └── middleware/
│           ├── auth.go          JWT AuthGuard middleware
│           └── ctx.go           Context key definitions
├── pkg/api/                     Переиспользуемые HTTP-утилиты
│   ├── response.go              Respond, RespondOK, RespondCreated
│   ├── error.go                 ProblemDetail (RFC 7807)
│   ├── decode.go                JSON body decoder with size/unknown-field limits
│   ├── pagination.go            PageRequest, PageResponse[T], Cursor
│   └── handler.go               Generic Handler[In, Out]
├── migrations/                  SQL-миграции (golang-migrate)
│   ├── 000001_create_users.up.sql / .down.sql
│   └── 000002_create_tweets.up.sql / .down.sql
├── docs/                        Swagger (генерируется `make swagger`)
├── bin/chirp                    Бинарник
├── go.mod / go.sum
└── Makefile
```

---

## 3. Модули и их ответственность

### 3.1 User
| Компонент | Файл | Ответственность |
|-----------|------|-----------------|
| Entity | `domain/user/entity.go` | User (ID, Username, Email, PasswordHash, DisplayName, Bio, timestamps) |
| VO | `domain/user/email.go` | Email validation via `net/mail.ParseAddress` |
| VO | `domain/user/username.go` | Username: 3-30 chars, alphanumeric + underscore, lowercase |
| VO | `domain/user/password.go` | Password: 8-72 chars (bcrypt limit) |
| Errors | `domain/user/errors.go` | ErrUserNotFound, ErrEmailTaken, ErrUsernameTaken, ErrInvalidCredentials |
| Port | `port/user.go` | UserRepository {Create, GetByID, GetByEmail, GetByUsername} |
| UseCase | `usecase/user/register.go` | Validate → check unique → bcrypt → save → JWT |
| UseCase | `usecase/user/login.go` | Find by email → compare password → JWT |
| UseCase | `usecase/user/get_profile.go` | GetByID → return public profile |

### 3.2 Auth
| Компонент | Файл | Ответственность |
|-----------|------|-----------------|
| Port | `port/auth.go` | AuthService {IssueTokenPair, ValidateAccessToken} |
| Port | `port/password.go` | PasswordHasher {Hash, Compare} |
| Adapter | `adapter/memory/auth.go` | JWT HS256, access 15min, refresh 7d |
| Adapter | `adapter/memory/password.go` | bcrypt cost 10 |

### 3.3 Tweet
| Компонент | Файл | Ответственность |
|-----------|------|-----------------|
| Entity | `domain/tweet/entity.go` | Tweet (ID, AuthorID, Body, ParentID, timestamps) |
| VO | `domain/tweet/errors.go` | Body: 1-280 chars. Errors: ErrTweetNotFound, ErrBodyTooLong, ErrBodyEmpty, ErrNotOwner |
| Entity | `domain/tweet/like.go` | Like (UserID, TweetID) |
| Port | `port/tweet_repo.go` | TweetRepository {Create, GetByID, ListByAuthor, Delete} |
| Port | `port/like_repo.go` | LikeRepository {Like, Unlike, IsLiked, Count, ListUsers} |
| UseCase | `usecase/tweet/create.go` | Validate body → check parent → save → return tweet |
| UseCase | `usecase/tweet/get_by_id.go` | GetByID or error |
| UseCase | `usecase/tweet/list_by_user.go` | Paginated list by author |
| UseCase | `usecase/tweet/delete.go` | Owner check → Delete |
| UseCase | `usecase/tweet/like.go` | Like tweet (idempotent) |
| UseCase | `usecase/tweet/unlike.go` | Unlike tweet |

### 3.4 Timeline
| Компонент | Файл | Ответственность |
|-----------|------|-----------------|
| Entity | `domain/timeline/follow.go` | Follow (FollowerID, FolloweeID) |
| Entity | `domain/timeline/entry.go` | Entry (RecipientID, TweetID, AuthorID, ScoredAt) |
| Port | `port/follow_repo.go` | FollowRepository {Follow, Unfollow, IsFollowing, ListFollowers, ListFollowing, CountFollowers, CountFollowing} |
| Port | `port/timeline_repo.go` | TimelineRepository {AddEntry, GetHomeTimeline} |
| UseCase | `usecase/timeline/follow.go` | Self-check → user exists → Follow |
| UseCase | `usecase/timeline/unfollow.go` | Unfollow |
| UseCase | `usecase/timeline/list_followers.go` | Paginated followers |
| UseCase | `usecase/timeline/list_following.go` | Paginated following |
| UseCase | `usecase/timeline/home_timeline.go` | Get paginated home timeline entries |
| UseCase | `usecase/timeline/fanout.go` | Distribute tweet to all followers' timelines |

---

## 4. Потоки данных

### 4.1 Регистрация пользователя

```
Client                              Server
  │                                    │
  │  POST /api/v1/auth/register       │
  │  {username, email, password}      │
  │ ──────────────────────────────►   │
  │                                    │
  │                        AuthHandler.Register()
  │                          ├─ Decode JSON → RegisterRequest
  │                          ├─ RegisterUseCase.Execute()
  │                          │   ├─ NewUsername()       валидация
  │                          │   ├─ NewEmail()          валидация
  │                          │   ├─ NewPassword()       валидация
  │                          │   ├─ GetByEmail()        уникальность
  │                          │   ├─ GetByUsername()     уникальность
  │                          │   ├─ hasher.Hash()       bcrypt
  │                          │   ├─ repo.Create()       сохранить
  │                          │   └─ authSvc.Issue()    JWT
  │                          └─ RespondCreated()
  │                                    │
  │  201 {user, access_token,         │
  │       refresh_token}              │
  │ ◄────────────────────────────      │
```

### 4.2 Публикация твита (с fan-out)

```
Client                              Server
  │                                    │
  │  POST /api/v1/tweets              │
  │  Authorization: Bearer <token>    │
  │  {body, parent_id?}               │
  │ ──────────────────────────────►   │
  │                                    │
  │                        AuthGuard (JWT → user_id)
  │                        TweetHandler.Create()
  │                          ├─ CreateUseCase.Execute()
  │                          │   ├─ NewBody()          валидация
  │                          │   ├─ GetByID(parent)    проверка parent
  │                          │   └─ repo.Create()      сохранение
  │                          │
  │                          ├─ FanOutUseCase.Execute()
  │                          │   ├─ ListFollowers(authorID)
  │                          │   └─ для каждого фолловера:
  │                          │       AddEntry(RecipientID, TweetID)
  │                          │
  │                          └─ RespondCreated(tweet)
  │                                    │
  │  201 {id, author_id, body,        │
  │       created_at}                  │
  │ ◄────────────────────────────      │
```

### 4.3 Чтение домашней ленты

```
Client                              Server
  │                                    │
  │  GET /api/v1/timeline/home        │
  │  Authorization: Bearer <token>    │
  │  ?limit=20&cursor=<tweet_id>      │
  │ ──────────────────────────────►   │
  │                                    │
  │                        AuthGuard (JWT → user_id)
  │                        TimelineHandler()
  │                          ├─ GetHomeTimelineUseCase()
  │                          │   └─ TimelineRepo.GetHomeTimeline()
  │                          │       Copy → Sort → Slice → Cursor
  │                          └─ RespondOK({data, next_cursor, has_more})
  │                                    │
  │  200 {data: [...],                │
  │       next_cursor, has_more}      │
  │ ◄────────────────────────────      │
```

### 4.4 Подписка на пользователя

```
Client                              Server
  │                                    │
  │  POST /api/v1/users/{id}/follow   │
  │  Authorization: Bearer <token>    │
  │ ──────────────────────────────►   │
  │                                    │
  │                        AuthGuard (JWT → user_id)
  │                        FollowHandler.Follow()
  │                          ├─ FollowUseCase.Execute()
  │                          │   ├─ self? → ErrCannotFollowSelf
  │                          │   ├─ userRepo.GetByID() → exists?
  │                          │   ├─ repo.Follow()
  │                          └─ RespondNoContent()
  │                                    │
  │  204                              │
  │ ◄────────────────────────────      │
```

---

## 5. API Reference

### 5.1 Formaт ошибок (RFC 7807)

```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "username: must be at least 3 characters"
}
```

| HTTP Status | Content-Type | Usage |
|-------------|-------------|-------|
| 400 | `application/problem+json` | Validation errors |
| 401 | `application/problem+json` | Missing/invalid JWT |
| 403 | `application/problem+json` | Not owner (delete tweet) |
| 404 | `application/problem+json` | Not found |
| 409 | `application/problem+json` | Conflict (duplicate email/username) |

### 5.2 Формат пагинации

```json
{
  "data": [{...}, {...}],
  "next_cursor": "uuid-string",
  "has_more": true,
  "total": 42
}
```

Cursor-based (tweet ID или user ID). `next_cursor` пустой → данных больше нет.

### 5.3 Полный список эндпоинтов

```
🌐 = public, 🔒 = requires JWT

System:
  GET    /health                      🌐 → plain "ok"
  GET    /swagger/index.html          🌐 → Swagger UI
  GET    /swagger/doc.json            🌐 → OpenAPI spec

Auth:
  POST   /api/v1/auth/register        🌐 → 201 + {user, access_token, refresh_token}
  POST   /api/v1/auth/login           🌐 → 200 + {user, access_token, refresh_token}

Users:
  GET    /api/v1/users/me             🔒 → 200 + {id, username, email, ...}

Tweets:
  POST   /api/v1/tweets               🔒 → 201 + {id, author_id, body, parent_id, created_at}
  GET    /api/v1/tweets/{id}          🌐 → 200 + tweet
  DELETE /api/v1/tweets/{id}          🔒 → 204 (only author)
  GET    /api/v1/users/{id}/tweets    🌐 → 200 + Page[Tweet]
  POST   /api/v1/tweets/{id}/like     🔒 → 204
  DELETE /api/v1/tweets/{id}/like     🔒 → 204

Follows:
  POST   /api/v1/users/{id}/follow    🔒 → 204 | 400 (self)
  DELETE /api/v1/users/{id}/follow    🔒 → 204
  GET    /api/v1/users/{id}/followers 🌐 → 200 + Page[User] + total
  GET    /api/v1/users/{id}/following 🌐 → 200 + Page[User] + total

Timeline:
  GET    /api/v1/timeline/home        🔒 → 200 + Page[{tweet_id, author_id, scored_at}]
```

---

## 6. База данных

### 6.1 Схема (PostgreSQL)

```sql
-- +migrate Up
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username      VARCHAR(30)  NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    display_name  VARCHAR(100) NOT NULL DEFAULT '',
    bio           TEXT         NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

CREATE TABLE tweets (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id  UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body       VARCHAR(280) NOT NULL,
    parent_id  UUID         REFERENCES tweets(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_tweets_author_id ON tweets(author_id);
CREATE INDEX idx_tweets_created_at ON tweets(created_at DESC);
```

### 6.2 Планируемые таблицы

```sql
-- Фаза 3
CREATE TABLE notifications (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       VARCHAR(50) NOT NULL,   -- 'like', 'follow', 'reply'
    actor_id   UUID NOT NULL REFERENCES users(id),
    tweet_id   UUID REFERENCES tweets(id),
    read       BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE media (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id),
    url        TEXT NOT NULL,
    mime_type  VARCHAR(50),
    size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 6.3 Адаптеры

```
DATABASE_URL задан     → PostgreSQL (персистентность)
DATABASE_URL не задан  → In-memory (разработка, данные теряются при перезапуске)
REDIS_URL задан        → Redis (планируется для кэша сессий и ленты)
REDIS_URL не задан     → Redis отключён (варнинг в лог)
```

---

## 7. Технологический стек

| Компонент | Библиотека | Версия | Обоснование |
|-----------|-----------|--------|-------------|
| Язык | Go | 1.23+ | Статика, горутины, быстрая компиляция |
| HTTP-роутер | chi | v5 | Идиоматичный, middleware-friendly, совместим с net/http |
| БД драйвер | pgx | v5 | Самый производительный Go-драйвер для PostgreSQL |
| Кэш | go-redis | v9 | Стандарт для Go |
| JWT | golang-jwt | v5 | HS256, гибкие claims |
| Пароли | x/crypto/bcrypt | — | Промышленный стандарт хеширования |
| UUID | google/uuid | v1 | Генерация идентификаторов |
| Swagger | swaggo/swag | v1.16 | Аннотации → OpenAPI 2.0 |
| Миграции | golang-migrate | — | SQL-файлы, CLI, CI-ready |
| Логирование | log/slog | stdlib | Структурированные логи, zero-dependency |
| Метрики (план) | Prometheus | — | OpenMetrics, стандарт |
| Трейсинг (план) | OpenTelemetry | — | Бесплатно, распределённый |
| Тесты (план) | testify + testcontainers | — | Удобные ассерты, настоящие БД в CI |
| CI/CD (план) | GitHub Actions | — | Бесплатно для публичных репо |

---

## 8. Безопасность

### 8.1 Аутентификация
- JWT HS256, access token — 15 минут, refresh token — 7 дней
- Передача: `Authorization: Bearer <access_token>`
- Секреты: 32-байтовые hex-строки, из env или авто-генерация в dev

### 8.2 Пароли
- bcrypt cost=10
- Валидация: 8-72 символа (bcrypt ограничение)
- В памяти только хеш, plaintext не хранится

### 8.3 Защита ввода
- JSON Decode: `DisallowUnknownFields`, `MaxBytesReader` (1 MB)
- Тело твита: 1-280 символов
- Username: 3-30 символов, alphanumeric + underscore
- Email: валидация через `net/mail.ParseAddress`

### 8.4 Rate limiting (план)
- Token bucket per IP / per user
- Login: 5 попыток / минуту
- Register: 3 попытки / минуту

---

## 9. Конфигурация

Все настройки — через переменные окружения (12-factor app).

| Переменная | Дефолт | Описание |
|-----------|--------|----------|
| `HTTP_PORT` | `8080` | Порт HTTP-сервера |
| `APP_ENV` | `development` | Окружение (development/production) |
| `DATABASE_URL` | `""` | PostgreSQL DSN. Пусто → in-memory |
| `REDIS_URL` | `""` | Redis URL. Пусто → Redis выключен |
| `JWT_ACCESS_SECRET` | авто-gen в dev | 32 байта hex |
| `JWT_REFRESH_SECRET` | авто-gen в dev | 32 байта hex |

---

## 10. Разработка

### 10.1 Быстрый старт

```bash
make run        # Запуск без БД (in-memory)
make build      # Сборка бинарника
make test       # Все тесты
make lint       # golangci-lint
make swagger    # Генерация OpenAPI
```

### 10.2 С PostgreSQL

```bash
# Поднять PostgreSQL (Docker пока нет — локально или Neon/Supabase)
make migrate-up    # Применить миграции
DATABASE_URL=postgres://user:pass@localhost:5432/chirp make run
```

### 10.3 VS Code

Открыть `backend/` как корень проекта. `launch.json` уже настроен:
- Run Chirp Server — запуск с дебагом

### 10.4 Принципы разработки

1. **Чистая архитектура** — домен не знает об инфраструктуре
2. **Интерфейсы — потребительские** — определяются там, где используются (usecase)
3. **Ошибки — типизированные** — `errors.Is()` для семантики
4. **Graceful shutdown** — SIGTERM → HTTP → PG pool → Redis
5. **RFC 7807** — все HTTP-ошибки Problem Details
6. **Zero framework policy** — stdlib + chi + pgx. Никаких gin/echo/fiber/beego
