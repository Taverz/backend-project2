# Like Tweet Flow

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
  │                        │                      │ Publish("tweet.liked")                 │
  │                        │                      │──────────────────────────────────────►│
  │                        │                      │                     │                  │
  │                        │  ─── Consumer ──     │                     │  Notification     │
  │                        │                      │                     │◄─────────────────│
  │                        │                      │                     │ notifRepo.Create()│
  │ 204                    │                      │                     │                  │
  │◄────────────────────────│                      │                     │                  │
```

### Шаги

1. **Transport** — AuthGuard — validate JWT → userID
2. **Transport** — Extract tweet ID from URL param
3. **UseCase** — `repo.Like(userID, tweetID)` — idempotent
4. **Transport** — Get tweet by ID to find author
5. **Transport** — Publish event `tweet.liked` with {tweet_id, actor_id, tweet_author_id}
6. **Consumer** (async) — If actor != author → `notifRepo.Create()` with type="like"
7. **Transport** — Respond 204

### Self-like check

Consumer фильтрует: `if event.Data["tweet_author_id"] == event.Data["actor_id"]` → не создавать уведомление.

### Ошибки

| Шаг | Ошибка | HTTP |
|-----|--------|:----:|
| 1 | Invalid JWT | 401 |
