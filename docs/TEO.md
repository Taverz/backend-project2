# ТЭО — Twitter-клон (Go-бэкенд)

> **⚠️ Исторический документ.** Исходное техобоснование от 2025-06-02.
> Актуальная архитектура, модули и roadmap — в `SOUL.md`.

## 1. Назначение продукта

Социальная платформа публикации коротких сообщений: посты (твиты), реплаи,
репосты, цитаты, лайки, подписки, поиск, уведомления. Аудитория — от тысяч
до миллионов пользователей. Frontend: Flutter (web + mobile). Backend: Go.

## 2. Архитектурный выбор: модульный монолит

### Почему не микросервисы

| Критерий | Микросервисы | Модульный монолит |
|----------|-------------|-------------------|
| Сложность деплоя | 5+ сервисов, оркестрация | 1 бинарник |
| Сетевое взаимодействие | RPC/очереди между сервисами | Вызовы функций |
| Транзакции | Распределённые (Saga) | Локальные ACID |
| Отладка | Распределённая трассировка | Один процесс |
| Команда 1-3 чел. | Переусложнено | Оптимально |
| Переход к микроcервисам | — | Модуль → сервис (шлифовка границы) |

**Решение:** модульный монолит. Домены изолированы на уровне кода
(`internal/domain/user`, `internal/domain/tweet`, ...). Разбивка на
микросервисы возможна позже — когда появится нагрузка, требующая
независимого масштабирования отдельного модуля.

### Принципы модуляции

- **Чистая архитектура** (порты и адаптеры): домен не зависит от БД,
  HTTP-фреймворка, брокеров.
- **Dependency injection** через интерфейсы — usecase получает реализации
  через конструктор, не импортирует postgres/kafka напрямую.
- **Public API модуля** — юзкейсы, доступные извне; внутренняя реализация скрыта.
- **Общие типы** (`internal/domain/user/entity.go`) переиспользуются
  другими модулями; циклических зависимостей нет (один модуль может
  ссылаться на сущности другого, но не на usecase напрямую — через порты).

## 3. Стек технологий

| Слой | Выбор | Обоснование |
|------|-------|------------|
| Язык | Go 1.23+ | Производительность, статика, горутины, экосистема |
| HTTP-роутер | Chi | Идиоматичный, совместим с net/http, middlware-friendly |
| База данных | PostgreSQL 16 | ACID, JSONB, полнотекстовый поиск (промежут.), зрелость |
| Драйвер БД | pgx + sqlc | Производительность + кодогенерация запросов |
| Кэш / сессии | Redis 7 | Скорость, структуры данных (sorted sets для ленты) |
| Очередь событий | Kafka / Redpanda | Асинхронная индексация, fan-out, уведомления |
| Поиск | Elasticsearch 8 | Полнотекстовый поиск, агрегации, тренды |
| Файлы | MinIO (S3) | Совместимость с S3, локальная и облачная установка |
| Миграции | golang-migrate | Простота, SQL-файлы, CLI |
| Конфигурация | env → struct (envconfig) | 12-factor app, простота |
| Логирование | log/slog | Стандартная библиотека Go |
| Метрики | Prometheus + Grafana | Стандарт индустрии |
| Трейсинг | OpenTelemetry | Бесплатно, стандарт, Jaeger-совместимо |
| Тесты | testify + testcontainers-go | Удобные ассерты, настоящие БД в тестах |
| CI/CD | GitHub Actions | Бесплатно для публичных репо |

## 4. Доменные модули

| Модуль | Ответственность | Ключевые сущности |
|--------|----------------|-------------------|
| **user** | Регистрация, профиль, подписки | User, Profile, Follow |
| **auth** | JWT-токены, refresh, сессии | TokenPair, Session |
| **tweet** | CRUD постов, реплаи, репосты, лайки | Tweet, Reply, Repost, Like |
| **timeline** | Home-лента (fan-out on write) | Timeline, FeedItem |
| **search** | Полнотекстовый поиск, индексация | SearchQuery, IndexedTweet |
| **notification** | Уведомления о событиях | Notification, NotificationSetting |
| **media** | Загрузка, ресайз, хранение файлов | Media, Upload |
| **trend** | Тренды, хештеги, агрегации | Trend, Hashtag |

### Поток данных (публикация твита)

```
POST /api/v1/tweets
  → tweet.usecase.Create()
    → postgres: INSERT tweet
    → kafka: event "tweet.created"
      ├→ consumer: elasticsearch.Index(tweet)
      ├→ consumer: timeline.FanOut(tweet) → redis/postgres
      └→ consumer: notification.Create(tweet)
```

## 5. Data Model (ключевые таблицы)

```sql
users        (id, username, email, password_hash, ...)
follows      (follower_id, followee_id)
tweets       (id, author_id, body, parent_id, type, ...)
likes        (user_id, tweet_id)
timeline     (user_id, tweet_id, author_id, scored_at)
notifications (id, user_id, type, actor_id, tweet_id, read)
```

## 6. API-принципы

- RESTful JSON API с префиксом `/api/v1/`
- Версионирование в URL
- JWT-аутентификация через `Authorization: Bearer <token>`
- Пагинация: cursor-based (Tweet.id как курсор)
- Ошибки: RFC 7807 Problem Details
- Rate limiting: token bucket per user

## 7. План развития (MVP → Production)

### Фаза 1: Ядро (сейчас)
- Структура проекта, конфигурация, Makefile
- Hello world HTTP
- Модули: user, auth, tweet (CRUD)
- PostgreSQL, Redis (локально без Docker — или через Makefile-цели)

### Фаза 2: Социальные механики
- Timeline fan-out
- Лайки, реплаи, репосты
- Подписки

### Фаза 3: Поиск и уведомления
- Elasticsearch-индексация
- Kafka-продакшены/консьюмеры
- Уведомления

### Фаза 4: Медиа и production-ready
- MinIO / S3 для файлов
- Мониторинг и метрики
- Нагрузочное тестирование
- CI/CD

## 8. Структура проекта

```
backend/
├── cmd/server/main.go
├── internal/
│   ├── app/          # Bootstrap, DI, lifecycle
│   ├── config/       # Конфигурация
│   ├── domain/       # Доменные сущности
│   │   ├── user/
│   │   ├── tweet/
│   │   ├── timeline/
│   │   ├── search/
│   │   └── notification/
│   ├── usecase/      # Use-cases (бизнес-логика)
│   │   ├── user/
│   │   ├── tweet/
│   │   └── ...
│   ├── adapter/      # Реализации портов
│   │   ├── postgres/
│   │   ├── redis/
│   │   ├── kafka/
│   │   └── es/
│   ├── port/         # Интерфейсы
│   └── transport/    # HTTP-хендлеры
│       └── middleware/
├── migrations/       # SQL-миграции
├── docs/             # Документация
├── Makefile
├── Dockerfile
└── go.mod
```

## 9. Почему этот подход выигрывает

1. **Один бинарник** — деплой на любую VPS или Kubernetes без оркестрации
2. **Чистые границы** — модули можно вынести в микроcервисы без переписывания
3. **Локальные транзакции** — ACID, никаких распределённых саг
4. **Быстрый фидбек** — тесты без сетевых вызовов (mocks для портов)
5. **Стандартный Go** — без магии, без кодогенераторов кроме sqlc
