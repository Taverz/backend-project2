# Follow User Flow

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

### Шаги

1. **Transport** — AuthGuard — validate JWT → followerID
2. **Transport** — Extract target user ID from URL param
3. **UseCase** — `if followerID == followeeID` → ErrCannotFollowSelf
4. **UseCase** — `userRepo.GetByID(followeeID)` — check user exists
5. **UseCase** — `followRepo.Follow(followerID, followeeID)`
6. **UseCase** — Publish event `user.followed` with {actor_id, target_user_id}
7. **Consumer** (async) — If actor != target → `notifRepo.Create()` with type="follow"
8. **Transport** — Respond 204

### Ошибки

| Шаг | Ошибка | HTTP |
|-----|--------|:----:|
| 1 | Invalid JWT | 401 |
| 3 | cannot follow yourself | 400 |
| 4 | user not found | 404 |
