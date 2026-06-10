# Registration Flow

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

### Шаги

1. **Transport** — Decode JSON → RegisterInput
2. **UseCase** — Validate username (3-30 chars, a-z0-9_)
3. **UseCase** — Validate email (mail.ParseAddress, trim, lowercase)
4. **UseCase** — Validate password (8-72 chars)
5. **UseCase** — Check unique: `repo.GetByEmail()`
6. **UseCase** — Check unique: `repo.GetByUsername()`
7. **UseCase** — `hasher.Hash(password)` — bcrypt cost=10
8. **UseCase** — `repo.Create(user)` — save to DB/memory
9. **UseCase** — `auth.IssueTokenPair(userID)` — JWT HS256
10. **Transport** — Respond 201 + {user, access_token, refresh_token}

### Ошибки

| Шаг | Ошибка | HTTP |
|-----|--------|:----:|
| 2-4 | Validation | 400 |
| 5 | email already registered | 409 |
| 6 | username already taken | 409 |
