# Screen → API Data Mapping

> Какие данные нужны каждому экрану, какие поля API их отдают.
> Если поля нет — UI должен или получить его из другого запроса,
> или API должен быть расширен.
>
> Правило: UI не должен делать N+1 запрос для отрисовки одного списка.

---

## 1. LoginScreen

| Endpoint | Response field | UI element | Required |
|----------|---------------|------------|:--------:|
| POST /auth/login | user.id | — (store in state) | ✅ |
| | user.username | — (store in state) | ✅ |
| | user.email | — (store in state) | ❌ |
| | user.display_name | — (store in state) | ❌ |
| | user.bio | — (store in state) | ❌ |
| | user.created_at | — (store in state) | ❌ |
| | access_token | SecureStorage | ✅ |
| | refresh_token | SecureStorage | ✅ |

**Итого:** 2 обязательных поля из 7. Остальные хранятся для AuthState и ProfileScreen.

**Проблем:** ❌ Нет

---

## 2. RegisterScreen

| Endpoint | Response field | UI element | Required |
|----------|---------------|------------|:--------:|
| POST /auth/register | user.id | — (store in state) | ✅ |
| | user.username | — (store in state) | ✅ |
| | user.email | — (store in state) | ❌ |
| | access_token | SecureStorage | ✅ |
| | refresh_token | SecureStorage | ✅ |

**Итого:** То же что Login.

**Проблем:** ❌ Нет

---

## 3. HomeScreen (Timeline)

### GET /timeline/home

**Текущий ответ API:**
```json
{"data": [{"tweet_id": "uuid", "author_id": "uuid", "scored_at": "..."}], "next_cursor": "..."}
```

**Что UI реально показывает:**

```
┌──────────────────────────────────────────┐
│ [Avatar]  username                        │  ← avatar: ❌ нет, username: ❌ нет
│           · 2m ago                        │  ← timestamp: есть (scored_at)
│                                          │
│   Tweet body text (1-280 chars)           │  ← body: ❌ нет
│                                          │
│   ♥ 5    💬 2                            │  ← like_count: ❌ нет, liked_by_me: ❌ нет
└──────────────────────────────────────────┘
```

**Проблема:** Из 7 полей на карточке API отдаёт ТОЛЬКО 1 (`scored_at`).

**Что нужно:**

| Нужное поле | Откуда взять | Варианты решения |
|------------|-------------|-----------------|
| tweet.body | N+1 запросов (GET /tweets/{id} × N) | **Добавить в timeline response** |
| tweet.author_id | ✅ уже есть | — |
| author.username | N+1 запросов (GET /users/{id} × N) | **Добавить в timeline response** |
| author.avatar | N+1 запросов | Добавить или использовать initials |
| like_count | N запросов | Добавить в response |
| liked_by_me | N запросов | Добавить в response |
| scored_at | ✅ уже есть | — |

**Решение: расширить ответ /timeline/home:**

```json
{
  "data": [
    {
      "tweet_id": "uuid",
      "body": "текст твита",
      "author_id": "uuid",
      "author_username": "alice",
      "author_display_name": "Alice",
      "like_count": 5,
      "liked_by_me": false,
      "reply_count": 2,
      "scored_at": "2025-06-10T12:00:00Z"
    }
  ],
  "next_cursor": "uuid",
  "has_more": false
}
```

**Результат:** 1 запрос → 1 экран. Без N+1.

---

## 4. TweetDetailScreen

### GET /tweets/{id}

**Текущий ответ API:**
```json
{"id": "uuid", "author_id": "uuid", "body": "...", "parent_id": "", "created_at": "..."}
```

**Что UI реально показывает:**

| UI элемент | Поле | Есть? |
|-----------|------|:-----:|
| Avatar | author avatar | ❌ |
| Username | author.username | ❌ |
| Body | body | ✅ |
| Timestamp | created_at | ✅ |
| Like count | — | ❌ |
| Like status | — | ❌ |
| Reply count | — | ❌ |
| Replies list | GET /tweets/search?parent_id= | ❌ отдельный запрос |

**Проблемы:**
- Нет username автора (UI должен знать author_id → GET /users/{id})
- Нет like count и liked_by_me
- Нет replies — отдельный эндпоинт

**Решение: расширить ответ:**

```json
{
  "id": "uuid",
  "body": "текст твита",
  "author_id": "uuid",
  "author_username": "alice",
  "author_display_name": "Alice",
  "parent_id": "",
  "created_at": "2025-06-10T12:00:00Z",
  "like_count": 12,
  "liked_by_me": false,
  "reply_count": 3
}
```

---

## 5. ProfileScreen

### GET /users/me или GET /users/{id}

**Текущий ответ API:**
```json
{"id": "uuid", "username": "alice", "email": "...", "display_name": "", "bio": "", "created_at": "..."}
```

| UI элемент | Поле | Есть? |
|-----------|------|:-----:|
| Username | username | ✅ |
| Display name | display_name | ✅ |
| Bio | bio | ✅ |
| Avatar | — | ❌ (no avatar in MVP) |
| Followers count | — | ❌ (нужен отдельный GET /users/{id}/followers + total) |
| Following count | — | ❌ |
| Tweets count | — | ❌ (нужен отдельный GET /users/{id}/tweets + pagination) |
| Joined date | created_at | ✅ |

**Проблемы:**
- 3 виджета на экране требуют 3 дополнительных запроса
- Статистика (followers, following, tweets) — каждый отдельный запрос

**Решение: добавить статистику в ответ:**

```json
{
  "id": "uuid",
  "username": "alice",
  "display_name": "Alice",
  "bio": "Just chirping",
  "created_at": "2025-01-01T00:00:00Z",
  "followers_count": 42,
  "following_count": 15,
  "tweets_count": 128
}
```

**Результат:** 1 запрос вместо 4.

---

## 6. FollowersScreen & FollowingScreen

### GET /users/{id}/followers, GET /users/{id}/following

**Текущий ответ API:**
```json
{"data": [{"id": "uuid (follower)", "username": "", "created_at": "..."}], "total": 42}
```

| UI элемент | Поле | Есть? |
|-----------|------|:-----:|
| Username | username | ✅ |
| Avatar | — | ❌ (initials fallback OK) |
| Follow button | is_following? | ❌ |

**Проблема:** Нет `is_following_by_me` — UI не знает, показывать "Follow" или "Following".

**Решение:**
```json
{"data": [{"id": "uuid", "username": "alice", "display_name": "Alice", "is_following_by_me": false, "created_at": "..."}], "total": 42}
```

---

## 7. NotificationsScreen

### GET /notifications

**Текущий ответ API:**
```json
{"data": [{"ID": "uuid", "UserID": "uuid", "Type": "like", "ActorID": "uuid", "TweetID": "uuid", "Read": false, "CreatedAt": "..."}], "unread": 5}
```

| UI элемент | Поле | Есть? |
|-----------|------|:-----:|
| Actor username | ActorID → username | ❌ |
| Tweet preview (for "liked your tweet") | tweet_id → body | ❌ |
| Timestamp | CreatedAt | ✅ |
| Read/unread | Read | ✅ |

**Проблема:** ActorID есть, но UI показывает username. TweetID есть, но UI показывает "liked your tweet" (можно без превью).

**Решение:**
```json
{
  "data": [{
    "ID": "uuid",
    "Type": "like",
    "ActorID": "uuid",
    "ActorUsername": "alice",
    "TweetID": "uuid",
    "Read": false,
    "CreatedAt": "2025-06-10T12:00:00Z"
  }],
  "unread": 5
}
```

---

## 8. SearchScreen

### GET /tweets/search?q=...

**Текущий ответ API:**
```json
{"data": [{"TweetID": "uuid", "AuthorID": "uuid", "Body": "...", "Score": 0.0, "CreatedAt": "..."}], "next_cursor": "..."}
```

| UI элемент | Поле | Есть? |
|-----------|------|:-----:|
| Body (highlighted) | Body | ✅ |
| Author username | AuthorID → username | ❌ |
| Timestamp | CreatedAt | ✅ |
| Score (relevance) | Score | ✅ |

**Проблема:** Нет username автора. UI покажет "uuid → ..." вместо имени.

**Решение:**
```json
{"data": [{"TweetID": "uuid", "AuthorID": "uuid", "AuthorUsername": "alice", "Body": "...", "Score": 0.0, "CreatedAt": "..."}]}
```

---

## 9. Сводная таблица: что нужно расширить

| Endpoint | Проблема | Пропущенные поля | UI страдает |
|----------|----------|-----------------|-------------|
| GET /timeline/home | N+1 для каждого твита | body, author_username, like_count, liked_by_me | HomeScreen — 5 доп. запросов |
| GET /tweets/{id} | Нет статистики | author_username, like_count, liked_by_me, reply_count | TweetDetailScreen |
| GET /users/{id} | Нет статистики профиля | followers_count, following_count, tweets_count | ProfileScreen |
| GET /followers, /following | Нет статуса подписки | is_following_by_me | FollowersScreen |
| GET /notifications | Нет username актора | ActorUsername | NotificationsScreen |
| GET /tweets/search | Нет username автора | AuthorUsername | SearchScreen |

---

## 10. Data flow diagram (Screen → API → Fields)

```
LoginScreen
  └── POST /auth/login → {user, access_token, refresh_token}
      └── user: {id, username, email, display_name, bio, created_at}  ← ❌ bio/display_name не используются на LoginScreen, но нужны ProfileScreen

HomeScreen
  └── GET /timeline/home → [{tweet_id, body, author_id, author_username, like_count, liked_by_me, scored_at}]
      ├── tweet_id → tap → TweetDetailScreen
      ├── body → TweetCard
      ├── author_id + author_username → Avatar + username
      ├── like_count + liked_by_me → Like button
      └── scored_at → timestamp

ProfileScreen
  └── GET /users/{id} → {id, username, display_name, bio, followers_count, following_count, tweets_count, created_at}
      ├── display_name + bio → ProfileHeader
      ├── followers_count → tap → FollowersScreen
      ├── following_count → tap → FollowingScreen
      └── tweets_count → "Tweets" tab label
```

---

## 11. Правила для API-дизайнера

1. **Один экран — один запрос.** Если для отрисовки списка нужно N+1 запросов — API спроектирован неправильно.

2. **Отдавай то, что UI показывает.** Если в TweetCard есть username — /timeline/home должен его вернуть. Не заставляй UI дёргать /users/{id} для каждого твита.

3. **Не отдавай то, что UI НЕ использует.** user.email не нужен на ProfileScreen (публичный профиль). Не отдавай.

4. **Пагинация — cursor-based.** Все списки используют одинаковый формат: `{data, next_cursor, has_more}`. total только для followers/following.

5. **Enum поля — на бэкенде.** UI не должен знать про "like", "follow", "reply" как строки. Если тип добавится — UI просто покажет новый тип.

6. **Если поле опционально — документируй default.** `display_name: ""` когда не заполнено, а не `null` и не пропущено.

7. **Даты — ISO 8601 в UTC.** Всегда `"2025-06-10T12:00:00Z"`. Не `"10.06.2025"`, не timestamp.

8. **Ошибки — Problem Details RFC 7807.** Всегда `{type, title, status, detail}`. detail должен содержать имя поля для 400/409.
