# SOUL.md — Chirp

> Единый источник правды о проекте. Архитектура, решения, модули, API.
> Обновляется после каждой завершённой фазы.

---

## 1. Идентичность

**Chirp** — Twitter-клон: платформа коротких сообщений с подписками, лентами, лайками, поиском и уведомлениями.

| Свойство | Значение |
|----------|----------|
| Тип | Социальная платформа (аналог Twitter) |
| Архитектура backend | Модульный монолит (clean architecture) |
| Frontend | Flutter (web + mobile) — позже |
| Язык backend | Go 1.23+ |
| Модель аудитории | Тысячи → миллионы пользователей |
| Статус | **Фаза 2 завершена** — социальные механики работают |

---

## 2. Архитектурные решения (и почему)

### 2.1 Модульный монолит, не микросервисы

**Причина:** команда 1-3 человека, один деплой, ACID-транзакции, простота отладки.

| Критерий | Микросервисы | Монолит |
|----------|-------------|---------|
| Сложность деплоя | 5+ сервисов | 1 бинарник |
| Транзакции | Saga (сложно) | Локальные ACID |
| Отладка | Распределённая трассировка | Один процесс |
| Переход к микросервисам | — | Модуль → сервис при необходимости |

### 2.2 Clean Architecture (порты и адаптеры)

```
transport → usecase → port ← adapter
               ↓
            domain
```

**Правила:**
- `domain` не импортирует ничего из проекта (чистый Go)
- `usecase` импортирует `domain` и `port` (интерфейсы)
- `adapter` импортирует `port` и `domain`
- `transport` импортирует `usecase` и `domain`
- Циклические импорты запрещены

**Почему:** замена PostgreSQL на MongoDB — меняем adapter, всё остальное не трогаем.

### 2.3 Адаптеры с авто-фолбеком

```
DATABASE_URL задан     → PostgreSQL (персистентность)
DATABASE_URL не задан  → In-memory (dev, данные теряются)
REDIS_URL задан        → Redis
REDIS_URL не задан     → Redis отключён (варнинг)
```

### 2.4 Fan-out on write (timeline)

Твит при создании рассылается в ленты всех подписчиков.
- **Плюс:** чтение ленты — один быстрый запрос
- **Минус:** запись дорогая для популярных авторов
- **Оптимизация (будущее):** гибридный подход (fan-out on write для обычных пользователей, fan-out on read для знаменитостей)

---

## 3. Стек технологий

| Слой | Выбор | Почему |
|------|-------|--------|
| Язык | Go 1.23+ | Производительность, горутины, статика |
| HTTP-роутер | Chi v5 | Идиоматичный, middleware-friendly |
| База данных | PostgreSQL 16 | ACID, JSONB, индексы |
| Драйвер БД | pgx/v5 | Производительность, пул соединений |
| Кэш | Redis 7 | Sorted sets для лент, сессии |
| Драйвер Redis | go-redis/v9 | Стандарт |
| JWT | golang-jwt/v5 | HS256, access 15min / refresh 7d |
| Пароли | x/crypto/bcrypt | Cost=10 |
| UUID | google/uuid | Генерация ID |
| Swagger | swaggo/swag + http-swagger | Аннотации → OpenAPI 2.0 |
| Миграции | golang-migrate | SQL-файлы, CLI |
| Конфигурация | env-переменные | 12-factor app |
| Логирование | log/slog | Стандартная библиотека |
| Очередь (план) | Kafka / Redpanda | Асинхронная индексация |
| Поиск (план) | Elasticsearch 8 | Полнотекстовый поиск |
| Файлы (план) | MinIO (S3) | Совместимость с облаком |
| Метрики (план) | Prometheus + Grafana | Стандарт индустрии |
| Тесты (план) | testify + testcontainers-go | Удобные ассерты, настоящие БД |

---

## 4. Доменные модули

### 4.1 Текущие (реализованы)

| Модуль | Сущности | UseCase'ы | API |
|--------|----------|-----------|-----|
| **user** | User, Profile, Username, Email, Password | Register, Login, GetProfile | 3 эндпоинта |
| **tweet** | Tweet, Like, Body | Create, GetByID, ListByUser, Delete, Like, Unlike | 8 эндпоинтов |
| **timeline** | Follow, Entry | Follow, Unfollow, ListFollowers, ListFollowing, FanOut, GetHomeTimeline | 5 эндпоинтов |

### 4.2 Запланированы

| Модуль | Назначение | Фаза |
|--------|-----------|------|
| **search** | Полнотекстовый поиск через Elasticsearch | 3 |
| **notification** | Уведомления о лайках/подписках/реплаях | 3 |
| **media** | Загрузка и хранение изображений/видео | 4 |
| **trend** | Тренды, хештеги, агрегации | 4 |

### 4.3 Data Model (ключевые таблицы)

```sql
users        (id UUID PK, username, email, password_hash, display_name, bio, created_at, updated_at)
tweets       (id UUID PK, author_id FK→users, body VARCHAR(280), parent_id FK→tweets, created_at, updated_at)
follows      (follower_id FK→users, followee_id FK→users, created_at) — composite PK
likes        (user_id FK→users, tweet_id FK→tweets, created_at) — composite PK
timeline     (recipient_id FK→users, tweet_id FK→tweets, author_id FK→users, scored_at)
notifications (id UUID PK, user_id FK→users, type, actor_id FK→users, tweet_id FK→tweets, read BOOL, created_at)
```

---

## 5. API Surface

### 5.1 Эндпоинты (текущие)

```
🌐 = публичный, 🔒 = требует JWT

System:
  GET    /health                      🌐 → "ok"
  GET    /hello                       🌐 → {"message":"hello world"}
  GET    /swagger/*                   🌐 → Swagger UI

Auth:
  POST   /api/v1/auth/register        🌐 → 201 + user + JWT
  POST   /api/v1/auth/login           🌐 → 200 + user + JWT

Users:
  GET    /api/v1/users/me             🔒 → 200 + профиль

Tweets:
  POST   /api/v1/tweets               🔒 → 201 + твит
  GET    /api/v1/tweets/{id}          🌐 → 200 + твит
  DELETE /api/v1/tweets/{id}          🔒 → 204 (только автор)
  GET    /api/v1/users/{id}/tweets    🌐 → 200 + PageResponse (cursor)
  POST   /api/v1/tweets/{id}/like     🔒 → 204
  DELETE /api/v1/tweets/{id}/like     🔒 → 204

Follows:
  POST   /api/v1/users/{id}/follow    🔒 → 204
  DELETE /api/v1/users/{id}/follow    🔒 → 204
  GET    /api/v1/users/{id}/followers 🌐 → 200 + data, total, cursor
  GET    /api/v1/users/{id}/following 🌐 → 200 + data, total, cursor

Timeline:
  GET    /api/v1/timeline/home        🔒 → 200 + entries (cursor)
```

### 5.2 Конвенции

- Все ответы — JSON
- Ошибки — RFC 7807 Problem Details (`application/problem+json`)
- Пагинация — cursor-based (tweet ID как курсор)
- JWT — `Authorization: Bearer <token>`
- Валидация — на уровне transport до вызова usecase

---

## 6. Потоки данных

### 6.1 Публикация твита

```
POST /tweets
  → TweetHandler.Create()
    → CreateUseCase.Execute()
      → TweetRepo.Create(tweet)
      → FanOutUseCase.Execute()
        → FollowRepo.ListFollowers(author)
        → для каждого фолловера: TimelineRepo.AddEntry(entry)
      → возврат твита
```

### 6.2 Чтение домашней ленты

```
GET /timeline/home
  → TimelineHandler
    → GetHomeTimelineUseCase.Execute(userID, limit, cursor)
      → TimelineRepo.GetHomeTimeline(userID, limit, cursor)
      → возврат entries
```

### 6.3 Регистрация

```
POST /auth/register
  → AuthHandler.Register()
    → RegisterUseCase.Execute()
      → валидация Username, Email, Password (value objects)
      → проверка уникальности (GetByEmail, GetByUsername)
      → bcrypt хеширование
      → UserRepo.Create(user)
      → AuthService.IssueTokenPair(userID)
      → возврат user + tokens
```

---

## 7. Структура проекта

```
backend/
├── cmd/server/main.go           # Точка входа, graceful shutdown
├── internal/
│   ├── app/app.go               # Bootstrap, DI, роутинг, все wiring
│   ├── config/config.go         # Конфигурация из env-переменных
│   ├── domain/                  # Чистые доменные сущности (без зависимостей)
│   │   ├── user/                # User, Profile, Username, Email, Password
│   │   ├── tweet/               # Tweet, Like, Body
│   │   └── timeline/            # Follow, Entry
│   ├── usecase/                 # Бизнес-логика (зависит от port, не от adapter)
│   │   ├── user/                # Register, Login, GetProfile
│   │   ├── tweet/               # Create, GetByID, ListByUser, Delete, Like, Unlike
│   │   └── timeline/            # Follow, Unfollow, ListFollowers, ListFollowing, FanOut, HomeTimeline
│   ├── port/                    # Интерфейсы
│   │   ├── user.go              # UserRepository
│   │   ├── tweet_repo.go        # TweetRepository
│   │   ├── like_repo.go         # LikeRepository
│   │   ├── follow_repo.go       # FollowRepository
│   │   ├── timeline_repo.go     # TimelineRepository
│   │   ├── password.go          # PasswordHasher
│   │   └── auth.go              # AuthService
│   ├── adapter/                 # Реализации портов
│   │   ├── memory/              # In-memory (dev)
│   │   │   ├── user_repo.go
│   │   │   ├── tweet_repo.go
│   │   │   ├── like_repo.go
│   │   │   ├── follow_repo.go
│   │   │   ├── timeline_repo.go
│   │   │   ├── password.go      # bcrypt
│   │   │   └── auth.go          # JWT HS256
│   │   ├── postgres/            # PostgreSQL (production)
│   │   │   ├── conn.go
│   │   │   ├── user_repo.go
│   │   │   └── tweet_repo.go
│   │   └── redis/conn.go        # Redis client
│   └── transport/               # HTTP-хендлеры
│       ├── auth_handler.go
│       ├── user_handler.go
│       ├── tweet_handler.go
│       ├── follow_handler.go
│       └── middleware/          # AuthGuard (JWT), context keys
├── pkg/api/                     # Переиспользуемые HTTP-утилиты
│   ├── response.go              # RespondOK, RespondCreated, RespondNoContent
│   ├── error.go                 # RFC 7807 ProblemDetail
│   ├── decode.go                # JSON-декодинг с валидацией
│   ├── pagination.go            # PageRequest, PageResponse[T]
│   └── handler.go               # Generic Handler[In, Out]
├── migrations/                  # SQL-миграции
│   ├── 000001_create_users.up.sql
│   ├── 000001_create_users.down.sql
│   ├── 000002_create_tweets.up.sql
│   └── 000002_create_tweets.down.sql
├── docs/                        # Swagger (генерируется)
├── bin/chirp                    # Собранный бинарник
├── go.mod / go.sum
└── Makefile
```

---

## 8. План развития

### Фаза 1 — Ядро ✅
- [x] Структура проекта
- [x] Hello world HTTP
- [x] User + Auth (регистрация, логин, JWT)
- [x] Tweet CRUD
- [x] PostgreSQL + Redis адаптеры (авто-фолбек)

### Фаза 2 — Социальные механики ✅
- [x] Подписки (follow/unfollow)
- [x] Лайки
- [x] Timeline fan-out (fan-out on write)

### Фаза 3 — Поиск и уведомления ⬜
- [ ] Elasticsearch-индексация
- [ ] Полнотекстовый поиск
- [ ] Kafka/RabbitMQ — продюсеры событий
- [ ] Асинхронная индексация
- [ ] Уведомления (лайки, подписки, реплаи)

### Фаза 4 — Медиа и production-ready ⬜
- [ ] MinIO / S3 для файлов
- [ ] Загрузка изображений/видео
- [ ] Prometheus + Grafana (метрики)
- [ ] OpenTelemetry (трассировка)
- [ ] Нагрузочное тестирование
- [ ] CI/CD (GitHub Actions)
- [ ] Flutter frontend

---

## 9. Development Workflow

```bash
make run              # Запуск dev-сервера (memory-фолбек)
make test             # Все тесты с race detector
make lint             # golangci-lint
make build            # Сборка бинарника
make swagger          # Генерация OpenAPI-документации
make migrate-up       # Применить миграции
make migrate-down     # Откатить миграцию
```

Для запуска с PostgreSQL:
```bash
DATABASE_URL=postgres://user:pass@localhost:5432/chirp make run
```

---

## 10. Архитектурные инварианты

1. **domain не импортирует adapter** — проверяется `check-arch.sh`
2. **usecase не импортирует adapter** — принимает `port`-интерфейсы через конструктор
3. **Циклических импортов нет** — `go vet` проверяет
4. **Graceful shutdown** — HTTP + PG pool + Redis закрываются при SIGTERM
5. **Ошибки типизированы** — `errors.Is()` для domain-ошибок
6. **RFC 7807** — все HTTP-ошибки в формате Problem Details
7. **Никаких фреймворков** — только stdlib + Chi + pgx

---

## 11. AI Collaboration

### 11.1 Инструкции для AI
Файл `.codewhale/instructions.md` содержит правила кодирования, структуру модулей, фазовый трекинг и session hygiene.

### 11.2 Логирование сессий
После каждой сессии:
- Запись в `docs/AI-LOG.md`: задача, метрики, ошибки, acceptance rate
- Сырые метрики в `docs/metrics/YYYY-MM-DD_session-ID.json`
- Оценка стоимости (~$0.40 за среднюю сессию)

### 11.3 Code Review
- Файл: `docs/code-review-2025-06-03.md`
- Метод: инструмент `review` + ручной deep-dive
- Результат: 12 находок, 7 исправлено, 2 отложено

---

## 12. Известные компромиссы и техдолг

| # | Проблема | Почему не исправлено | Когда |
|---|----------|---------------------|-------|
| T1 | O(n) поиск в memory-репо | Dev-адаптер, не production | — |
| T2 | `AuthService`/`PasswordHasher` в пакете `memory` | Косметика, не баг | Фаза 4 |
| T3 | `created_at` = 0001-01-01 в memory-адаптере | Memory не выставляет timestamp'ы | При переходе на PG |
| T4 | Fan-out вызывает ListFollowers(100000) — нет batch-вставки | Для MVP достаточно | Фаза 3 (Kafka) |
| T5 | Нет тестов | Тесты — после стабилизации API | Фаза 4 |
| T6 | Нет rate limiting | Пока не в production | Фаза 4 |
