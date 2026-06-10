# Create Tweet Flow

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

### Шаги

1. **Transport** — AuthGuard — validate JWT → userID
2. **Transport** — Decode JSON → CreateTweetRequest
3. **UseCase** — NewBody() — validate 1-280 chars
4. **UseCase** — If parent_id: repo.GetByID(parent) — verify exists
5. **UseCase** — repo.Create(tweet) — save
6. **FanOut** — repo.ListFollowers(authorID) — get all followers
7. **FanOut** — For each follower: timelineRepo.AddEntry(...)
8. **Search** — searchEngine.IndexTweet(tweet) — index for search
9. **Transport** — Respond 201 + tweet

### Ошибки

| Шаг | Ошибка | HTTP |
|-----|--------|:----:|
| 1 | Invalid JWT | 401 |
| 3 | Body too long/empty | 400 |
| 4 | Parent not found | 400 |
