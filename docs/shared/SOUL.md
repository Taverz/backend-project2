# Chirp — SOUL (Shared Source of Truth)

> Единый источник правды. Один экземпляр для всех платформ.
> Изменяется только при архитектурных решениях.

---

## 1. Идентичность

**Chirp** — Twitter-клон: платформа коротких сообщений с подписками, лентами, лайками, поиском и уведомлениями.

| Свойство | Значение |
|----------|----------|
| Тип | Социальная платформа (аналог Twitter) |
| Модель аудитории | Тысячи → миллионы пользователей |
| Статус | Фаза 2 завершена — социальные механики работают |

### Платформы

| Платформа | Язык | Статус | Директория |
|-----------|------|--------|------------|
| Backend API | Go | ✅ Фаза 2 — ядро + социальные механики | `backend/` |
| Flutter | Dart | ⬜ Не начат | `flutter/` |
| Android | Kotlin | ⬜ Не начат | `android/` |
| iOS | Swift | ⬜ Не начат | `ios/` |
| Web | TypeScript | ⬜ Не начат | `web/` |

---

## 2. Архитектурные решения

### 2.1 Модульный монолит (backend)

Один бинарник, модули изолированы на уровне пакетов. Почему: команда 1-3 человека, ACID-транзакции, простота отладки. Переход к микросервисам — заменой модуля на сервис.

### 2.2 Clean Architecture (backend)

```
transport → usecase → port ← adapter
               ↓
            domain
```

- `domain` — чистые типы, zero зависимостей
- `usecase` — бизнес-логика, зависит от port
- `port` — интерфейсы (контракты)
- `adapter` — реализация port (PostgreSQL, in-memory)
- `transport` — HTTP-хендлеры

### 2.3 Adapter auto-fallback

```
DATABASE_URL задан → PostgreSQL
DATABASE_URL пуст  → In-memory (dev, данные теряются)
```

### 2.4 Fan-out on write (timeline)

Твит при создании рассылается в ленты всех подписчиков. Чтение ленты — один быстрый запрос. Запись дорогая для популярных авторов.

---

## 3. Доменные модули

### Реализовано (Фаза 1-2)

| Модуль | Сущности | UseCase'ы |
|--------|----------|-----------|
| **user** | User, Profile, Username, Email, Password | Register, Login, GetProfile |
| **tweet** | Tweet, Like, Body | Create, GetByID, ListByUser, Delete, Like, Unlike |
| **timeline** | Follow, Entry | Follow, Unfollow, ListFollowers, ListFollowing, FanOut, GetHomeTimeline |
| **auth** | — | IssueTokenPair, ValidateAccessToken |
| **notification** | Notification | List, CountUnread, MarkRead |

### Запланировано

| Модуль | Фаза |
|--------|------|
| search (Elasticsearch) | 3 |
| media (S3/MinIO) | 4 |
| trend (hashtags) | 4 |

---

## 4. Data Model

```
users        (id UUID PK, username, email, password_hash, display_name, bio, created_at, updated_at)
tweets       (id UUID PK, author_id FK→users, body VARCHAR(280), parent_id FK→tweets, created_at, updated_at)
follows      (follower_id FK→users, followee_id FK→users, created_at) — composite PK
likes        (user_id FK→users, tweet_id FK→tweets, created_at) — composite PK
timeline     (recipient_id FK→users, tweet_id FK→tweets, author_id FK→users, scored_at)
notifications (id UUID PK, user_id FK→users, type, actor_id FK→users, tweet_id FK→tweets, read BOOL, created_at)
```

---

## 5. План развития

| Фаза | Что | Статус |
|------|-----|--------|
| 1 — Ядро | User + Auth + Tweet CRUD + PostgreSQL/Redis adapters | ✅ |
| 2 — Социальное | Follow + Like + Timeline fan-out | ✅ |
| 3 — Поиск и уведомления | Elasticsearch, Kafka, Notifications | ⬜ |
| 4 — Media и production | MinIO, Prometheus, Flutter frontend, CI/CD | ⬜ |

---

## 6. Техдолг

| # | Проблема | Когда |
|---|----------|-------|
| T1 | In-memory адаптеры — O(n) поиск | Не для production |
| T2 | Fan-out без batch-вставки (100k подписчиков) | Фаза 3 (Kafka) |
| T3 | Нет rate limiting | Фаза 4 |
