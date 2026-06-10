# Follow + Timeline — техническая спецификация

> Сгенерировано AI из бизнес-требований (шаг 1).
> Человек проверяет архитектуру до того, как AI пишет код.

---

## 1. Доменная модель

**`domain/timeline/follow.go`**:

```go
type Follow struct {
    FollowerID string  // кто подписался
    FolloweeID string  // на кого подписался
    CreatedAt  time.Time
}
```

Ограничения:
- FollowerID != FolloweeID — нельзя на себя
- Follow уникален: один пользователь может подписаться на другого только один раз

**`domain/timeline/entry.go`**:

```go
type Entry struct {
    RecipientID string    // кому показываем
    TweetID     string
    AuthorID    string
    ScoredAt    time.Time
}
```

Entry — это элемент домашней ленты. Не твит, а **ссылка** на твит в контексте получателя.

## 2. Новые эндпоинты

### POST /api/v1/users/{id}/follow

Подписаться на пользователя.

```
🔒 requires JWT
```

| Path param | Описание |
|-----------|----------|
| id | UUID пользователя, на которого подписываемся |

**Response 204:** No Content

**Side effects:** Событие `user.followed` → уведомление target пользователю.

### DELETE /api/v1/users/{id}/follow

Отписаться.

```
🔒 requires JWT
```

**Response 204:** No Content

### GET /api/v1/users/{id}/followers

Список подписчиков.

```
🌐 public
```

| Query | Type | Default | Max |
|-------|------|:-------:|:---:|
| limit | int | 20 | 50 |
| cursor | string | "" | — |

**Response 200:**

```json
{
  "data": [{"id": "uuid (follower)", "username": "alice", "created_at": "..."}],
  "next_cursor": "uuid",
  "has_more": false,
  "total": 42
}
```

### GET /api/v1/users/{id}/following

Список подписок.

```
🌐 public
```

**Response 200:** Аналогично followers, но `id` — followee.

### GET /api/v1/timeline/home

Домашняя лента.

```
🔒 requires JWT
```

| Query | Type | Default | Max |
|-------|------|:-------:|:---:|
| limit | int | 20 | 50 |
| cursor | string (tweet_id) | "" | — |

**Response 200:**

```json
{
  "data": [
    {"tweet_id": "uuid", "author_id": "uuid", "scored_at": "2025-06-10T12:00:00Z"}
  ],
  "next_cursor": "uuid",
  "has_more": false
}
```

## 3. Use Case'ы

### FollowUseCase

```
1. followerID == followeeID? → ErrCannotFollowSelf
2. UserRepo.GetByID(followeeID) — проверить, что пользователь существует
3. FollowRepo.Follow(followerID, followeeID) — сохранить
4. EventBus.Publish("user.followed", {actor_id, target_user_id})
```

### UnfollowUseCase

```
1. FollowRepo.Unfollow(followerID, followeeID)
```

### ListFollowersUseCase

```
1. FollowRepo.ListFollowers(userID, limit, cursor)
2. FollowRepo.CountFollowers(userID) — total count
3. Вернуть follows + cursor + total
```

### ListFollowingUseCase

```
1. FollowRepo.ListFollowing(userID, limit, cursor)
2. FollowRepo.CountFollowing(userID)
3. Вернуть follows + cursor + total
```

### FanOutUseCase (вызывается при создании твита)

```
1. FollowRepo.ListFollowers(authorID, 100000, "") — ВСЕ подписчики
2. Для каждого подписчика:
     TimelineRepo.AddEntry({RecipientID, TweetID, AuthorID, ScoredAt: now})
```

### GetHomeTimelineUseCase

```
1. TimelineRepo.GetHomeTimeline(userID, limit, cursor)
2. Вернуть entries + next_cursor
```

## 4. Интерфейсы (порты)

```go
type FollowRepository interface {
    Follow(ctx, followerID, followeeID string) error
    Unfollow(ctx, followerID, followeeID string) error
    IsFollowing(ctx, followerID, followeeID string) (bool, error)
    ListFollowers(ctx, userID string, limit int, cursor string) ([]*Follow, string, error)
    ListFollowing(ctx, userID string, limit int, cursor string) ([]*Follow, string, error)
    CountFollowers(ctx, userID string) (int, error)
    CountFollowing(ctx, userID string) (int, error)
}

type TimelineRepository interface {
    AddEntry(ctx, entry *Entry) error
    GetHomeTimeline(ctx, userID string, limit int, cursor string) ([]*Entry, string, error)
}
```

## 5. Архитектурное решение: fan-out on write

**Почему не fan-out on read:**

| Стратегия | Чтение ленты | Запись твита |
|-----------|:------------:|:------------:|
| Fan-out on read | N запросов (подписки → твиты → сортировка) | 1 запрос |
| Fan-out on write | 1 быстрый запрос | N записей (по числу подписчиков) |

Выбрали fan-out on write — чтение ленты происходит в 10-100 раз чаще, чем запись твита.

**Когда сломается:** у пользователя с 1M+ подписчиков fan-out будет слишком долгим.
Решение для будущего: гибрид — fan-out on write для обычных, fan-out on read для знаменитостей.

## 6. Схема БД

### follows

```sql
CREATE TABLE follows (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    followee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (follower_id, followee_id)
);

CREATE INDEX idx_follows_follower ON follows(follower_id);  -- чьи подписчики
CREATE INDEX idx_follows_followee ON follows(followee_id);  -- на кого подписан
```

### timeline

```sql
CREATE TABLE timeline (
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tweet_id     UUID NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    author_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    scored_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (recipient_id, tweet_id)
);

CREATE INDEX idx_timeline_recipient ON timeline(recipient_id, scored_at DESC);
```

## 7. Ошибки

| Domain Error | HTTP | Detail |
|-------------|:----:|--------|
| ErrCannotFollowSelf | 400 | cannot follow yourself |
| user not found | 404 | user not found |
| ErrInvalidCredentials | 401 | — |
| — | 401 | missing authorization header |

---

**Конец шага 2.** Спецификация готова. Человек проверяет 5 минут:
есть ли забытые кейсы, правильный ли выбор fan-out стратегии,
нужен ли total count в каждом ответе.
