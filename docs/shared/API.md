# Chirp API — Contract

> Единственный контракт между backend и всеми клиентами.
> Все эндпоинты, request/response схемы, пагинация, аутентификация.

---

## 1. General

| Свойство | Значение |
|----------|----------|
| Base URL | `/api/v1/` |
| Формат | JSON |
| Ошибки | RFC 7807 Problem Details (`application/problem+json`) |
| Пагинация | Cursor-based (limit + cursor) |
| Auth | JWT Bearer (`Authorization: Bearer <token>`) |

### Pagination

| Param | Type | Default | Max | Description |
|-------|------|:-------:|:---:|-------------|
| `limit` | int | 20 | 50 | Items per page |
| `cursor` | string | "" | — | Last item ID from previous page (tweet, user, or notification ID) |

Response:

```json
{
  "data": [{...}, {...}],
  "next_cursor": "uuid-string",
  "has_more": true,
  "total": 42
}
```

`next_cursor` empty → no more data. `total` only in follower/following lists.

### Auth

JWT Bearer token:

```
Authorization: Bearer <access_token>
```

| Token | Lifetime | Algorithm |
|-------|----------|-----------|
| Access | 15 minutes | HS256 |
| Refresh | 7 days | HS256 |

---

## 2. System

### GET /health

Public. Health check.

Response 200: `text/plain` → `ok`

### GET /hello

Public. Greeting.

Response 200:
```json
{"message": "hello world"}
```

---

## 3. Auth

### POST /auth/register

Public. Register new user.

**Request:**
```json
{
  "username": "alice",
  "email": "alice@example.com",
  "password": "secret123"
}
```

| Field | Type | Constraints |
|-------|------|-------------|
| username | string | 3-30 chars, a-z, 0-9, _, lowercase |
| email | string | Valid email, trim + lowercase |
| password | string | 8-72 chars |

**Response 201:**
```json
{
  "user": {
    "id": "uuid", "username": "alice", "email": "alice@example.com",
    "display_name": "", "bio": "", "created_at": "2025-06-10T12:00:00Z"
  },
  "access_token": "jwt...",
  "refresh_token": "jwt..."
}
```

**Errors:** 400 (validation), 409 (email/username taken)

### POST /auth/login

Public.

**Request:**
```json
{"email": "alice@example.com", "password": "secret123"}
```

**Response 200:** Same body as register (user + tokens).

**Errors:** 400 (validation), 401 (invalid email or password)

---

## 4. Users

### GET /users/me

**🔒 Requires JWT.** Current user profile.

**Response 200:**
```json
{
  "id": "uuid", "username": "alice", "email": "alice@example.com",
  "display_name": "", "bio": "", "created_at": "2025-06-10T12:00:00Z"
}
```

**Errors:** 401, 404

---

## 5. Tweets

### POST /tweets

**🔒 Requires JWT.** Create a tweet.

**Request:**
```json
{
  "body": "текст твита",
  "parent_id": "uuid (optional, for replies)"
}
```

| Field | Type | Constraints |
|-------|------|-------------|
| body | string | 1-280 chars |
| parent_id | string (UUID) | Optional, existing tweet |

**Response 201:**
```json
{
  "id": "uuid", "author_id": "uuid", "body": "текст твита",
  "parent_id": "", "created_at": "2025-06-10T12:00:00Z"
}
```

**Side effects:** Fan-out to followers' timelines. Index for search.

**Errors:** 400 (body validation, parent not found), 401

### GET /tweets/{id}

Public. Get tweet by ID.

**Response 200:** Tweet as above.
**Errors:** 404

### DELETE /tweets/{id}

**🔒 Requires JWT.** Delete own tweet.

**Response 204:** No Content.
**Errors:** 403 (not owner), 404

### GET /users/{id}/tweets

Public. Paginated tweets by user.

**Query:** `limit`, `cursor`
**Response 200:**
```json
{"data": [{...Tweet...}], "next_cursor": "uuid", "has_more": false}
```

### POST /tweets/{id}/like

**🔒 Requires JWT.** Like a tweet. Idempotent.

**Response 204.** Side effect: event `tweet.liked` → notification to author.

### DELETE /tweets/{id}/like

**🔒 Requires JWT.** Unlike.

**Response 204.**

### GET /tweets/search?q=...

Public. Full-text search.

| Query | Type | Required | Description |
|-------|------|:--------:|-------------|
| q | string | ✅ | Search query (case-insensitive substring) |
| limit | int | ❌ | Default 20, max 50 |
| cursor | string | ❌ | Pagination |

**Response 200:**
```json
{
  "data": [{"TweetID": "uuid", "AuthorID": "uuid", "Body": "...", "Score": 0.0, "CreatedAt": "..."}],
  "next_cursor": "uuid", "has_more": false
}
```

**Errors:** 400 (q required)

---

## 6. Follows

### POST /users/{id}/follow

**🔒 Requires JWT.** Follow a user.

**Response 204.**
**Side effect:** Event `user.followed` → notification.
**Errors:** 400 (self-follow)

### DELETE /users/{id}/follow

**🔒 Requires JWT.** Unfollow.

**Response 204.**

### GET /users/{id}/followers

Public. Paginated followers.

**Query:** `limit`, `cursor`

**Response 200:**
```json
{
  "data": [{"id": "uuid (follower)", "username": "", "created_at": "..."}],
  "next_cursor": "uuid", "has_more": false, "total": 42
}
```

### GET /users/{id}/following

Public. Paginated following.

**Response 200:** Same structure, `id` = followee.

---

## 7. Timeline

### GET /timeline/home

**🔒 Requires JWT.** Home feed — tweets from followed users.

**Query:** `limit`, `cursor`

**Response 200:**
```json
{
  "data": [{"tweet_id": "uuid", "author_id": "uuid", "scored_at": "2025-06-10T12:00:00Z"}],
  "next_cursor": "uuid", "has_more": false
}
```

**Principle:** Fan-out on write. Tweets are pre-distributed to followers' timelines on creation.

---

## 8. Notifications

### GET /notifications

**🔒 Requires JWT.** List notifications.

**Query:** `limit`, `cursor`

**Response 200:**
```json
{
  "data": [
    {"ID": "uuid", "UserID": "uuid", "Type": "like", "ActorID": "uuid",
     "TweetID": "uuid", "Read": false, "CreatedAt": "2025-06-10T12:00:00Z"}
  ],
  "next_cursor": "uuid", "has_more": false, "unread": 5
}
```

**Types:** `like` (someone liked your tweet), `follow` (someone followed you), `reply` (someone replied to your tweet)

### POST /notifications/{id}/read

**🔒 Requires JWT.** Mark as read.

**Response 204.**

---

## 9. Event Bus

### Events

| Event | Published by | Data | Consumed by |
|-------|-------------|------|-------------|
| `tweet.liked` | POST /tweets/{id}/like | tweet_id, actor_id, tweet_author_id | Notification service |
| `user.followed` | POST /users/{id}/follow | actor_id, target_user_id | Notification service |

### Format

```json
{"type": "tweet.liked", "data": {"tweet_id": "uuid", "actor_id": "uuid", "tweet_author_id": "uuid"}}
```

Default: in-memory bus. Production: Kafka topics `chirp.likes`, `chirp.follows`.
