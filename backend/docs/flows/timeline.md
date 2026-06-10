# Home Timeline Flow

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

### Шаги

1. **Transport** — AuthGuard — validate JWT → userID
2. **Transport** — Parse query params: limit, cursor
3. **UseCase** — `timelineRepo.GetHomeTimeline(userID, limit, cursor)`
4. **Repo** — Copy slice (safe for concurrent writes)
5. **Repo** — Sort by scored_at DESC, tweet_id DESC
6. **Repo** — Slice with cursor pagination
7. **Transport** — Respond 200 + {data, next_cursor, has_more}

### Принцип: fan-out on write

Твиты не читаются из базы при запросе ленты. Они уже лежат в timeline каждого пользователя:

```
Alice пишет твит
  → ListFollowers(Alice) → [Bob, Charlie]
  → AddEntry(Bob, tweetID, authorID, now)
  → AddEntry(Charlie, tweetID, authorID, now)

Bob запрашивает GET /timeline/home
  → GetHomeTimeline(Bob)
  → Возвращает entries (отсортированные по времени)
```

### Пагинация

| Параметр | Тип | Default | Max |
|----------|-----|:-------:|:---:|
| limit | int | 20 | 50 |
| cursor | string (tweet_id) | "" | — |

### Ошибки

| Шаг | Ошибка | HTTP |
|-----|--------|:----:|
| 1 | Invalid JWT | 401 |
