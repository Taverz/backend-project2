# Code Review Report — Phase 2 Complete (3-Stream)

**Date:** 2025-06-03
**Reviewers:** 3 parallel CodeWhale sub-agents
**Scope:** All Phase 1 + Phase 2 code (user, auth, tweet, timeline, follow, likes)

---

## Methodology

Three independent agents reviewed the codebase in parallel:

| Stream | Agent | Focus |
|--------|-------|-------|
| **A** | `review-arch` | Architecture & Patterns (clean arch, dependency direction, module structure) |
| **B** | `review-bugs` | Correctness & Bugs (null pointers, race conditions, resource leaks, edge cases) |
| **C** | `review-fresh` | Fresh Eyes (no checklists — security, intuition, naming, inconsistency) |

Each agent reviewed ALL Go files independently. Findings were consolidated and de-duplicated.

---

## Findings

### 🔴 Critical

| # | Finding | Source | File:Line |
|---|---------|--------|-----------|
| **CR1** | **Delete оставляет зомби-запись в byUser** — твит удаляется из `tweets`, но не из `byUser[authorID]`. ListByAuthor вернёт nil-pointer. | B (bugs) | `memory/tweet_repo.go:71-76` |
| **CR2** | **Data race: sort.Slice под RLock** — `GetHomeTimeline` делает `sort.Slice` под `RLock`, мутируя слайс. Параллельный `AddEntry` — гонка. | B (bugs) | `memory/timeline_repo.go:38` |
| **CR3** | **config.Load() импортирует adapter/memory** — обратная зависимость: config → adapter. Нарушение clean architecture. | C (fresh) | `config/config.go:5` |
| **CR4** | **JWT не проверяет aud/iss claims** — токен, выпущенный для одного сервиса, валиден в любом контексте. | C (fresh) | `memory/auth.go:80` |

### 🟠 Major

| # | Finding | Source | File:Line |
|---|---------|--------|-----------|
| **MJ1** | **FanOutUseCase: хардкод limit=100000** — пользователь с 10M фолловеров → OOM. Нужен cursor-loop или Kafka. | A+B+C | `usecase/timeline/fanout.go:30` |
| **MJ2** | **register.go игнорирует ошибки GetByEmail/GetByUsername** — `existing, _ := ...` — БД упала → молчаливо пропустили. | B (bugs) | `usecase/user/register.go:48` |
| **MJ3** | **Ошибка fan-out молча дропается** — `_ = h.fanOut.Execute(...)`, ни лога, ни алерта. | B (bugs) | `transport/tweet_handler.go:94` |
| **MJ4** | **Нет проверки существования пользователя перед follow** — можно подписаться на несуществующий UUID. | B (bugs) | `transport/follow_handler.go:44` |
| **MJ5** | **Нет rate limiting** — брутфорс логина, спам регистраций без ограничений. | C (fresh) | — |
| **MJ6** | **HS256 вместо RS256** — симметричный ключ требует полный секрет для каждой валидации. | C (fresh) | `memory/auth.go` |

### ⚠️ Minor

| # | Finding | Source | File:Line |
|---|---------|--------|-----------|
| **MN1** | **FollowRepository — 7 методов** (guideline: 1-3). Можно разделить при переходе на PG. | A (arch) | `port/follow_repo.go:10-18` |
| **MN2** | **created_at всегда zero-value в memory-адаптерах** — `0001-01-01T00:00:00Z`. | B (bugs) | все memory-репо |
| **MN3** | **like/unlike handler'ы игнорируют ok из UserIDFromContext** — если не авторизован, просто передаёт пустую строку. | B (bugs) | `app.go:209` |
| **MN4** | **follow_handler.go — 90% дубликат кода** в Followers/Following. | B (bugs) | `transport/follow_handler.go` |
| **MN5** | **AddEntry мутирует входной Entry.ScoredAt** — побочный эффект, нарушение контракта. | C (fresh) | `memory/timeline_repo.go:24` |
| **MN6** | **Авто-генерация JWT-секретов в проде** — если `APP_ENV` не задан. | C (fresh) | `config/config.go:25` |
| **MN7** | **GenerateSecret в пакете memory** — криптография не должна быть в memory. | C (fresh) | `memory/auth.go:102` |
| **MN8** | **app.go — God Object: 264 строки** — wiring + routing + 4 inline-хендлера в одном файле. | C (fresh) | `app/app.go` |
| **MN9** | **ListFollowers/ListFollowing всегда возвращают nextCursor=""** — порт обещает cursor, но memory не реализует. | C (fresh) | `memory/follow_repo.go:65` |
| **MN10** | **Email валидация: `mail.ParseAddress` требует `<angle@brackets>`?** — проверить, работает ли без скобок. | C (fresh) | `domain/user/email.go:14` |

### ℹ️ Info

| # | Finding | Source |
|---|---------|--------|
| **I1** | FollowRepository: 7 методов — можно разбить на Reader + Writer | A |
| **I2** | LikeRepository: 5 методов — аналогично | A |
| **I3** | Создание твита делает 2 запроса для проверки parent вместо 1 | C |
| **I4** | UseCase возвращает `*domain.Tweet` вместо DTO — нарушение слоя | C |
| **I5** | Refresh-токены живут 7 дней без возможности отзыва | C |
| **I6** | Нет аудит-лога неудачных аутентификаций | C |
| **I7** | `Password` тип — `string`, при логировании утечёт plaintext | C |
| **I8** | HTTP без TLS — ок для dev, проблема для prod | C |

---

## Stream Comparison

| Метрика | A (Arch) | B (Bugs) | C (Fresh) |
|---------|:--------:|:--------:|:---------:|
| Critical | 0 | 2 | 2 |
| Major | 0 | 4 | 2 |
| Minor | 2 | 2 | 5 |
| Info | 2 | 0 | 4 |
| **Total** | **4** | **8** | **13** |

**Анализ:**
- Stream A (Arch) — поверхностный: не нашёл config→adapter обратную зависимость
- Stream B (Bugs) — самый плотный: 2 critical + 4 major, все подтверждены
- Stream C (Fresh) — самый широкий: 2 critical + 7 minor/info, нашёл то, что A пропустил

**Лучшие находки:**
- B: Data race в timeline (CR2) + зомби-запись в byUser (CR1)
- C: Обратная зависимость config→adapter (CR3) + email-валидация под вопросом (MN10)
- A: Раздутые интерфейсы (I1, I2) — минорно, но архитектурно важно

---

## Recommended Fixes (priority)

1. **CR1** — Fix zombie entry in byUser on delete
2. **CR2** — Copy slice before sort in timeline
3. **CR3** — Move GenerateSecret out of adapter/memory
4. **MJ2** — Don't ignore GetByEmail errors in register
5. **MJ3** — Log fan-out errors, don't silent-drop
6. **MJ4** — Check user existence before follow
7. **CR4** — Add aud/iss validation to JWT
8. **MN1-MN10** — Address during Phase 3 refactoring
