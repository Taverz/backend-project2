# Chirp Backend — API Design

> Полная спецификация API: эндпоинты, request/response схемы, ошибки, события.
> Подходит для воспроизведения бэкенда на любом языке/стеке.

---

## 1. Общие конвенции

### 1.1 Базовый URL

```
/api/v1/
```

### 1.2 Формат ответов

Успешные: JSON с HTTP 200/201/204.

Ошибки: RFC 7807 Problem Details:

```json
{
  "type": "about:blank",
  "title": "Not Found",
  "status": 404,
  "detail": "tweet not found"
}
```

Content-Type: `application/problem+json`

### 1.3 Пагинация

Cursor-based. Параметры:

| Параметр | Тип | Дефолт | Max | Описание |
|----------|-----|--------|-----|----------|
| `limit` | int | 20 | 50 | Количество элементов на странице |
| `cursor` | string | "" | — | ID последнего элемента предыдущей страницы (твита, пользователя, уведомления) |

Ответ:

```json
{
  "data": [{...}, {...}],
  "next_cursor": "uuid-string",
  "has_more": true,
  "total": 42
}
```

`next_cursor` пустой → данных больше нет. `total` только для списков подписчиков.

### 1.4 Аутентификация

JWT Bearer token в заголовке:

```
Authorization: Bearer <access_token>
```

Access token: 15 минут. Refresh token: 7 дней. HS256.

### 1.5 Стандартные ошибки

| HTTP | Когда | Тело |
|------|-------|------|
| 400 | Валидация входных данных | ProblemDetail: title="Bad Request" |
| 401 | Отсутствует / невалидный JWT | ProblemDetail: title="Unauthorized" |
| 403 | Не владелец ресурса | ProblemDetail: title="Forbidden" |
| 404 | Ресурс не найден | ProblemDetail: title="Not Found" |
| 409 | Конфликт (дубликат email/username) | ProblemDetail: title="Conflict" |
| 413 | Тело запроса > 1 MB | ProblemDetail: title="Payload Too Large" |
| 500 | Внутренняя ошибка | ProblemDetail: title="Internal Server Error" |

---

## 2. Эндпоинты

### 2.1 System

#### GET /health

Health check.

```
🌐 public
```

**Response 200:**
```
Content-Type: text/plain
ok
```

#### GET /hello

Приветствие.

```
🌐 public
```

**Response 200:**
```json
{"message": "hello world"}
```

---

### 2.2 Auth

#### POST /auth/register

Регистрация нового пользователя.

```
🌐 public
Content-Type: application/json
```

**Request:**
```json
{
  "username": "alice",
  "email": "alice@example.com",
  "password": "secret123"
}
```

**Поля:**
| Поле | Тип | Ограничения |
|------|-----|------------|
| username | string | 3-30 символов, a-z, 0-9, _, lowercase |
| email | string | Валидный email, trim + lowercase |
| password | string | 8-72 символа |

**Response 201:**
```json
{
  "user": {
    "id": "uuid",
    "username": "alice",
    "email": "alice@example.com",
    "display_name": "",
    "bio": "",
    "created_at": "2025-06-10T12:00:00Z"
  },
  "access_token": "jwt...",
  "refresh_token": "jwt..."
}
```

**Ошибки:**
| Status | Detail |
|--------|--------|
| 400 | username: must be at least 3 characters |
| 400 | email: invalid format |
| 400 | password: must be at least 8 characters |
| 409 | email already registered |
| 409 | username already taken |

#### POST /auth/login

Аутентификация.

```
🌐 public
Content-Type: application/json
```

**Request:**
```json
{
  "email": "alice@example.com",
  "password": "secret123"
}
```

**Response 200:**
```json
{
  "user": { "...полный UserResponse..." },
  "access_token": "jwt...",
  "refresh_token": "jwt..."
}
```

**Ошибки:**
| Status | Detail |
|--------|--------|
| 400 | email: invalid format |
| 401 | invalid email or password |

---

### 2.3 Users

#### GET /users/me

Текущий пользователь.

```
🔒 requires JWT
```

**Response 200:**
```json
{
  "id": "uuid",
  "username": "alice",
  "email": "alice@example.com",
  "display_name": "",
  "bio": "",
  "created_at": "2025-06-10T12:00:00Z"
}
```

**Ошибки:**
| Status | Detail |
|--------|--------|
| 401 | missing authorization header |
| 404 | user not found |

---

### 2.4 Tweets

#### POST /tweets

Создать твит.

```
🔒 requires JWT
Content-Type: application/json
```

**Request:**
```json
{
  "body": "текст твита",
  "parent_id": "uuid (опционально, для ответа на твит)"
}
```

**Поля:**
| Поле | Тип | Ограничения |
|------|-----|------------|
| body | string | 1-280 символов |
| parent_id | string | UUID существующего твита (опционально) |

**Response 201:**
```json
{
  "id": "uuid",
  "author_id": "uuid",
  "body": "текст твита",
  "parent_id": "",
  "created_at": "2025-06-10T12:00:00Z"
}
```

**Side effects:**
- Fan-out: твит рассылается подписчикам автора (добавляется в их home timeline)
- Search indexing: твит индексируется для полнотекстового поиска

**Ошибки:**
| Status | Detail |
|--------|--------|
| 400 | tweet body: must not be empty |
| 400 | tweet body: must be at most 280 characters |
| 401 | not authenticated |

#### GET /tweets/{id}

Получить твит по ID.

```
🌐 public
```

**Path params:** `id` — UUID твита.

**Response 200:**
```json
{
  "id": "uuid",
  "author_id": "uuid",
  "body": "текст твита",
  "parent_id": "",
  "created_at": "2025-06-10T12:00:00Z"
}
```

**Ошибки:**
| Status | Detail |
|--------|--------|
| 404 | tweet not found |

#### DELETE /tweets/{id}

Удалить твит (только автор).

```
🔒 requires JWT
```

**Path params:** `id` — UUID твита.

**Response 204:** No Content

**Ошибки:**
| Status | Detail |
|--------|--------|
| 403 | you can only delete your own tweets |
| 404 | tweet not found |

#### GET /users/{id}/tweets

Список твитов пользователя (пагинированный).

```
🌐 public
```

**Path params:** `id` — UUID пользователя.

**Query params:** `limit`, `cursor` (см. пагинацию).

**Response 200:**
```json
{
  "data": [{...TweetResponse...}, {...}],
  "next_cursor": "uuid",
  "has_more": true
}
```

#### POST /tweets/{id}/like

Лайкнуть твит.

```
🔒 requires JWT
```

**Path params:** `id` — UUID твита.

**Response 204:** No Content

**Side effects:**
- Событие `tweet.liked` → уведомление автору твита (если лайк не от автора)

#### DELETE /tweets/{id}/like

Убрать лайк.

```
🔒 requires JWT
```

**Path params:** `id` — UUID твита.

**Response 204:** No Content

#### GET /tweets/search?q=...

Поиск твитов по тексту.

```
🌐 public
```

**Query params:**
| Параметр | Тип | Обязательный | Описание |
|----------|-----|:------------:|----------|
| q | string | ✅ | Поисковый запрос (case-insensitive substring) |
| limit | int | ❌ | Default 20, max 50 |
| cursor | string | ❌ | Пагинация |

**Response 200:**
```json
{
  "data": [
    {
      "TweetID": "uuid",
      "AuthorID": "uuid",
      "Body": "текст твита",
      "Score": 0.0,
      "CreatedAt": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false
}
```

**Ошибки:**
| Status | Detail |
|--------|--------|
| 400 | query parameter 'q' is required |

---

### 2.5 Follows

#### POST /users/{id}/follow

Подписаться на пользователя.

```
🔒 requires JWT
```

**Path params:** `id` — UUID пользователя, на которого подписываются.

**Response 204:** No Content

**Side effects:**
- Событие `user.followed` → уведомление подписанному пользователю

**Ошибки:**
| Status | Detail |
|--------|--------|
| 400 | cannot follow yourself |

#### DELETE /users/{id}/follow

Отписаться от пользователя.

```
🔒 requires JWT
```

**Path params:** `id` — UUID пользователя.

**Response 204:** No Content

#### GET /users/{id}/followers

Список подписчиков.

```
🌐 public
```

**Path params:** `id` — UUID пользователя.

**Query params:** `limit`, `cursor` (пагинация).

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid (follower)",
      "username": "",
      "created_at": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false,
  "total": 42
}
```

#### GET /users/{id}/following

Список подписок пользователя.

```
🌐 public
```

**Path params:** `id` — UUID пользователя.

**Query params:** `limit`, `cursor` (пагинация).

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid (followee)",
      "username": "",
      "created_at": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false,
  "total": 42
}
```

---

### 2.6 Timeline

#### GET /timeline/home

Домашняя лента — твиты от пользователей, на которых подписан.

```
🔒 requires JWT
```

**Query params:** `limit`, `cursor` (пагинация).

**Response 200:**
```json
{
  "data": [
    {
      "tweet_id": "uuid",
      "author_id": "uuid",
      "scored_at": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false
}
```

**Принцип:** fan-out on write. При создании твита он сразу записывается в ленту каждого подписчика.

---

### 2.7 Notifications

#### GET /notifications

Список уведомлений текущего пользователя.

```
🔒 requires JWT
```

**Query params:** `limit`, `cursor` (пагинация).

**Response 200:**
```json
{
  "data": [
    {
      "ID": "uuid",
      "UserID": "uuid",
      "Type": "like",
      "ActorID": "uuid (кто совершил действие)",
      "TweetID": "uuid",
      "Read": false,
      "CreatedAt": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false,
  "unread": 5
}
```

**Типы уведомлений:**
| Type | Когда |
|------|-------|
| `like` | Кто-то лайкнул твой твит |
| `follow` | Кто-то подписался на тебя |
| `reply` | Кто-то ответил на твой твит |

#### POST /notifications/{id}/read

Отметить уведомление как прочитанное.

```
🔒 requires JWT
```

**Path params:** `id` — UUID уведомления.

**Response 204:** No Content

---

## 3. Событийная модель (Event Bus)

### 3.1 Формат события

```go
type Event struct {
    Type string
    Data map[string]string
}
```

### 3.2 События

#### tweet.liked

Публикуется: POST /tweets/{id}/like

```json
{
  "type": "tweet.liked",
  "data": {
    "tweet_id": "uuid",
    "actor_id": "uuid (кто лайкнул)",
    "tweet_author_id": "uuid (автор твита)"
  }
}
```

Потребители:
- Notification service: создать уведомление типа "like" для автора (если actor != author)

#### user.followed

Публикуется: POST /users/{id}/follow

```json
{
  "type": "user.followed",
  "data": {
    "actor_id": "uuid (кто подписался)",
    "target_user_id": "uuid (на кого подписались)"
  }
}
```

Потребители:
- Notification service: создать уведомление типа "follow" для target (если actor != target)

### 3.3 Реализация

По умолчанию — in-memory bus (goroutines). Для production — Kafka:
- Топики: `chirp.tweets`, `chirp.likes`, `chirp.follows`
- Каждое событие — JSON-сообщение

---

## 4. База данных (PostgreSQL)

### 4.1 Таблицы

#### users

```sql
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
```

#### tweets

```sql
CREATE TABLE tweets (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body       VARCHAR(280) NOT NULL,
    parent_id  UUID REFERENCES tweets(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
```

### 4.2 Индексы

```
users:      idx_users_email (email), idx_users_username (username)
tweets:     idx_tweets_author_id (author_id), idx_tweets_created_at (created_at DESC)
```

### 4.3 Адаптеры

```
DATABASE_URL задан     → PostgreSQL (pgx/v5 pool)
DATABASE_URL не задан  → In-memory (разработка)
```

---

## 5. Доменные ошибки (маппинг)

| Domain Error | HTTP Status | HTTP Detail |
|-------------|:-----------:|-------------|
| ErrUserNotFound | 404 | user not found |
| ErrUsernameTaken | 409 | username already taken |
| ErrEmailTaken | 409 | email already registered |
| ErrInvalidCredentials | 401 | invalid email or password |
| ErrUsernameTooShort | 400 | username: must be at least 3 characters |
| ErrUsernameTooLong | 400 | username: must be at most 30 characters |
| ErrUsernameInvalid | 400 | username: only letters, digits, and underscores allowed |
| ErrEmailEmpty | 400 | email: must not be empty |
| ErrEmailInvalid | 400 | email: invalid format |
| ErrPasswordTooShort | 400 | password: must be at least 8 characters |
| ErrPasswordTooLong | 400 | password: must be at most 72 characters |
| ErrTweetNotFound | 404 | tweet not found |
| ErrBodyTooLong | 400 | tweet body: must be at most 280 characters |
| ErrBodyEmpty | 400 | tweet body: must not be empty |
| ErrNotOwner | 403 | you can only delete your own tweets |
| ErrCannotFollowSelf | 400 | cannot follow yourself |

---

## 6. Use Case'ы (шаги)

### 6.1 RegisterUseCase

```
1. Validate username (3-30 chars, alphanumeric + _)
2. Validate email (mail.ParseAddress, trim, lowercase)
3. Validate password (8-72 chars)
4. Check uniqueness: GetByEmail — если найден → ErrEmailTaken
5. Check uniqueness: GetByUsername — если найден → ErrUsernameTaken
6. Hash password (bcrypt cost=10)
7. UserRepo.Create(user) — сохранить
8. AuthService.IssueTokenPair(userID) — JWT access + refresh
9. Return {user, access_token, refresh_token}
```

### 6.2 LoginUseCase

```
1. Validate email
2. GetByEmail — если не найден → ErrInvalidCredentials (timing-safe)
3. PasswordHasher.Compare(hash, password) — не совпало → ErrInvalidCredentials
4. IssueTokenPair(userID)
5. Return {user, access_token, refresh_token}
```

### 6.3 CreateTweetUseCase

```
1. Validate body (1-280 chars)
2. Если parent_id указан — GetByID(parent) — если не найден → error
3. Generate UUID
4. TweetRepo.Create(tweet)
5. Return tweet
```

### 6.4 DeleteTweetUseCase

```
1. GetByID(id) — если не найден → ErrTweetNotFound
2. If tweet.AuthorID != requesterID → ErrNotOwner
3. TweetRepo.Delete(id)
```

### 6.5 FollowUseCase

```
1. If followerID == followeeID → ErrCannotFollowSelf
2. UserRepo.GetByID(followeeID) — если не найден → "user not found"
3. FollowRepo.Follow(followerID, followeeID)
4. Publish event "user.followed"
```

### 6.6 FanOutUseCase (при создании твита)

```
1. FollowRepo.ListFollowers(authorID) — получить всех подписчиков
2. Для каждого подписчика:
     TimelineRepo.AddEntry({RecipientID, TweetID, AuthorID, ScoredAt})
```

---

## 7. Архитектурные слои (dependency direction)

```
transport → usecase → port ← adapter
               ↓
            domain
```

- **domain**: чистые Go-типы, zero зависимостей от проекта
- **usecase**: зависит от domain + port (интерфейсы). Содержит бизнес-логику
- **port**: интерфейсы (контракты между слоями)
- **adapter**: реализует port. Знает про инфраструктуру (БД, HTTP, брокеры)
- **transport**: HTTP-хендлеры. Валидирует ввод, вызывает usecase, маппит ошибки в HTTP

### Разрешённые импорты

| Слой | Импортирует |
|------|------------|
| domain | только stdlib |
| usecase | domain + port |
| port | domain |
| adapter | port + domain |
| transport | usecase + domain |

---

## 8. Sequence Diagrams

### 8.1 Регистрация пользователя

```
Client                  Transport              UseCase                   Repo              Auth
  │                        │                      │                       │                 │
  │ POST /auth/register    │                      │                       │                 │
  │────────────────────────►                      │                       │                 │
  │                        │ Decode JSON          │                       │                 │
  │                        │────────────────────► │                       │                 │
  │                        │                      │ NewUsername()          │                 │
  │                        │                      │ NewEmail()             │                 │
  │                        │                      │ NewPassword()          │                 │
  │                        │                      │ GetByEmail()           │                 │
  │                        │                      │───────────────────────►│                 │
  │                        │                      │◄───────────────────────│                 │
  │                        │                      │ GetByUsername()        │                 │
  │                        │                      │───────────────────────►│                 │
  │                        │                      │◄───────────────────────│                 │
  │                        │                      │ Hash(password)         │                 │
  │                        │                      │ Create(user)           │                 │
  │                        │                      │───────────────────────►│                 │
  │                        │                      │ IssueTokenPair(userID) │                 │
  │                        │                      │─────────────────────────────────────────►│
  │                        │◄────────────────────►│                       │                 │
  │ 201 + user + tokens    │                      │                       │                 │
  │◄────────────────────────│                      │                       │                 │
```

### 8.2 Создание твита (с fan-out и индексацией)

```
Client                  Transport              UseCase              Repo/Timeline          Search
  │                        │                      │                     │                    │
  │ POST /tweets           │                      │                     │                    │
  │────────────────────────►                      │                     │                    │
  │                        │ AuthGuard (JWT→ID)   │                     │                    │
  │                        │ Decode JSON          │                     │                    │
  │                        │────────────────────► │                     │                    │
  │                        │                      │ NewBody()           │                    │
  │                        │                      │ repo.Create(tweet)  │                    │
  │                        │                      │────────────────────►│                    │
  │                        │                      │◄────────────────────│                    │
  │                        │                      │                     │                    │
  │                        │  ─── Fan-out ───     │                     │                    │
  │                        │                      │ ListFollowers(user) │                    │
  │                        │                      │────────────────────►│                    │
  │                        │                      │◄────────────────────│                    │
  │                        │                      │ AddEntry×N          │                    │
  │                        │                      │────────────────────►│                    │
  │                        │                      │                     │                    │
  │                        │  ─── Search ────     │                     │                    │
  │                        │                      │ IndexTweet(tweet)   │                    │
  │                        │                      │─────────────────────────────────────────►│
  │                        │◄────────────────────►│                     │                    │
  │ 201 + tweet            │                      │                     │                    │
  │◄────────────────────────│                      │                     │                    │
```

### 8.3 Лайк твита (с событием → уведомлением)

```
Client                  Transport              UseCase              Repo               EventBus
  │                        │                      │                     │                  │
  │ POST /tweets/{id}/like │                      │                     │                  │
  │────────────────────────►                      │                     │                  │
  │                        │ AuthGuard (JWT→ID)   │                     │                  │
  │                        │──────► LikeUseCase   │                     │                  │
  │                        │                      │ repo.Like(user,tweet)│                  │
  │                        │                      │────────────────────►│                  │
  │                        │                      │◄────────────────────│                  │
  │                        │                      │                     │                  │
  │                        │  ─── Publish ───     │                     │                  │
  │                        │                      │ Publish("tweet.liked")                │
  │                        │                      │──────────────────────────────────────►│
  │                        │                      │                     │                  │
  │                        │  ─── Consumer ──     │                     │  Notification     │
  │                        │                      │                     │◄─────────────────│
  │                        │                      │                     │ notifRepo.Create()│
  │ 204                    │                      │                     │                  │
  │◄────────────────────────│                      │                     │                  │
```

### 8.4 Подписка на пользователя

```
Client                  Transport              UseCase              UserRepo       FollowRepo   EventBus
  │                        │                      │                     │               │           │
  │ POST /users/{id}/follow│                      │                     │               │           │
  │────────────────────────►                      │                     │               │           │
  │                        │ AuthGuard (JWT→ID)   │                     │               │           │
  │                        │──────► FollowUseCase │                     │               │           │
  │                        │                      │ self?               │               │           │
  │                        │                      │ GetByID(target)     │               │           │
  │                        │                      │────────────────────►│               │           │
  │                        │                      │◄────────────────────│               │           │
  │                        │                      │ repo.Follow()       │               │           │
  │                        │                      │────────────────────────────────────►│           │
  │                        │                      │ Publish("user.followed")            │           │
  │                        │                      │──────────────────────────────────────────────►│
  │                        │◄────────────────────►│                     │               │           │
  │ 204                    │                      │                     │               │           │
  │◄────────────────────────│                      │                     │               │           │
```

### 8.5 Чтение домашней ленты

```
Client                  Transport              UseCase                TimelineRepo
  │                        │                      │                       │
  │ GET /timeline/home     │                      │                       │
  │────────────────────────►                      │                       │
  │                        │ AuthGuard (JWT→ID)   │                       │
  │                        │──────► HomeTimeline  │                       │
  │                        │                      │ GetHomeTimeline(ID)   │
  │                        │                      │──────────────────────►│
  │                        │                      │ Copy → Sort → Slice   │
  │                        │                      │◄──────────────────────│
  │                        │◄────────────────────►│                       │
  │ 200 + entries + cursor │                      │                       │
  │◄────────────────────────│                      │                       │
```

### 8.6 Поиск твитов

```
Client                  Transport              UseCase                SearchEngine
  │                        │                      │                       │
  │ GET /tweets/search?q=  │                      │                       │
  │────────────────────────►                      │                       │
  │                        │ Decode query params  │                       │
  │                        │──────► SearchTweets  │                       │
  │                        │                      │ SearchTweets(query)   │
  │                        │                      │──────────────────────►│
  │                        │                      │ (in-memory: grep,     │
  │                        │                      │  ES: fulltext query)  │
  │                        │                      │◄──────────────────────│
  │                        │◄────────────────────►│                       │
  │ 200 + results + cursor │                      │                       │
  │◄────────────────────────│                      │                       │
```

---

## 9. Конфигурация (env)

| Переменная | Тип | Дефолт | Описание |
|-----------|:---:|:------:|----------|
| `HTTP_PORT` | string | `"8080"` | Порт HTTP-сервера |
| `APP_ENV` | string | `"development"` | Окружение: development / production |
| `DATABASE_URL` | string | `""` | PostgreSQL DSN. Пусто → in-memory |
| `REDIS_URL` | string | `""` | Redis URL. Пусто → Redis отключён |
| `ELASTICSEARCH_URL` | string | `""` | Elasticsearch URL. Пусто → in-memory grep |
| `KAFKA_BROKERS` | string | `""` | Kafka brokers (csv). Пусто → in-memory event bus |
| `JWT_ACCESS_SECRET` | string | авто-generate (dev) | 32 байта hex. Access token signing |
| `JWT_REFRESH_SECRET` | string | авто-generate (dev) | 32 байта hex. Refresh token signing |

### Адаптеры (правила выбора)

```
DATABASE_URL  = "postgres://..." → PostgreSQL (pgx/v5 pool)
DATABASE_URL  = ""               → In-memory (разработка, данные теряются)

REDIS_URL     = "redis://..."    → Redis (go-redis/v9)
REDIS_URL     = ""               → Redis отключён

ELASTICSEARCH_URL = "http://..." → Elasticsearch (go-elasticsearch/v8)
ELASTICSEARCH_URL = ""           → In-memory (grep по телам твитов)

KAFKA_BROKERS = "host1:9092,..." → Kafka (kafka-go producer)
KAFKA_BROKERS = ""               → In-memory event bus (goroutine pub/sub)
```

### JWT в development

Если `APP_ENV=development` и `JWT_ACCESS_SECRET` не задан — секреты генерируются автоматически при каждом запуске. Все ранее выданные токены становятся невалидными после перезапуска.
