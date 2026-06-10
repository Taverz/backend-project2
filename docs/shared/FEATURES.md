# Chirp Features

> Что делает каждая фича. Acceptance criteria для всех платформ.

---

## Feature: User Registration

**Описание:** Новый пользователь может создать аккаунт.

**Acceptance Criteria:**

- [ ] POST /auth/register с валидными данными → 201 + user + tokens
- [ ] username длиной < 3 → 400
- [ ] username длиной > 30 → 400
- [ ] username содержит символы кроме a-z, 0-9, _ → 400
- [ ] email невалидный → 400
- [ ] password < 8 символов → 400
- [ ] password > 72 символов → 400
- [ ] email уже зарегистрирован → 409
- [ ] username уже занят → 409
- [ ] После регистрации пользователь существует в системе

**Data Flow:** Client → POST /auth/register → Backend: validate → check unique → bcrypt → save → JWT → Response

---

## Feature: Login

**Описание:** Зарегистрированный пользователь может войти.

**Acceptance Criteria:**

- [ ] POST /auth/login с верными email/password → 200 + user + tokens
- [ ] Неверный email → 401
- [ ] Неверный password → 401 (timing-safe, одинаковое время ответа)
- [ ] После логина access_token работает для запросов 🔒

---

## Feature: Create Tweet

**Описание:** Авторизованный пользователь может опубликовать твит.

**Acceptance Criteria:**

- [ ] POST /tweets с валидным body → 201 + tweet
- [ ] Без JWT → 401
- [ ] body пустой → 400
- [ ] body > 280 символов → 400
- [ ] parent_id указывает на несуществующий твит → 400
- [ ] parent_id валидный → reply создан
- [ ] После создания твит появляется в ленте подписчиков (fan-out)
- [ ] После создания твит индексируется для поиска

**Side effects:** Fan-out to followers, search indexing.

---

## Feature: Delete Tweet

**Описание:** Автор может удалить свой твит.

**Acceptance Criteria:**

- [ ] DELETE /tweets/{id} автором → 204
- [ ] DELETE /tweets/{id} не автором → 403
- [ ] DELETE несуществующего твита → 404
- [ ] Без JWT → 401

---

## Feature: Get Tweet

**Описание:** Любой пользователь (в т.ч. неавторизованный) может посмотреть твит.

**Acceptance Criteria:**

- [ ] GET /tweets/{id} существующего твита → 200 + tweet
- [ ] GET /tweets/{id} несуществующего твита → 404

---

## Feature: List User Tweets

**Описание:** Любой может посмотреть твиты пользователя с пагинацией.

**Acceptance Criteria:**

- [ ] GET /users/{id}/tweets → 200 + data, next_cursor, has_more
- [ ] limit=5 → 5 твитов
- [ ] limit=0 → 20 (default)
- [ ] limit=100 → 50 (max)
- [ ] cursor работает корректно

---

## Feature: Like Tweet

**Описание:** Авторизованный пользователь может лайкнуть твит.

**Acceptance Criteria:**

- [ ] POST /tweets/{id}/like → 204
- [ ] Повторный POST /tweets/{id}/like → 204 (idempotent)
- [ ] Без JWT → 401
- [ ] Автор твита получает уведомление о лайке (если лайк не от автора)

---

## Feature: Unlike Tweet

**Описание:** Авторизованный пользователь может убрать лайк.

**Acceptance Criteria:**

- [ ] DELETE /tweets/{id}/like → 204
- [ ] DELETE без предварительного лайка → 204 (idempotent)

---

## Feature: Follow User

**Описание:** Авторизованный пользователь может подписаться на другого.

**Acceptance Criteria:**

- [ ] POST /users/{id}/follow → 204
- [ ] Подписка на себя → 400 "cannot follow yourself"
- [ ] Подписка на несуществующего пользователя → 404
- [ ] Повторная подписка → 204 (idempotent)
- [ ] После подписки кнопка меняется с "Follow" на "Following"
- [ ] После подписки твиты пользователя появляются в ленте
- [ ] Целевой пользователь получает уведомление (если подписался не он сам)

---

## Feature: Unfollow User

**Описание:** Авторизованный пользователь может отписаться.

**Acceptance Criteria:**

- [ ] DELETE /users/{id}/follow → 204
- [ ] DELETE без подписки → 204 (idempotent)

---

## Feature: List Followers

**Описание:** Любой может посмотреть подписчиков пользователя.

**Acceptance Criteria:**

- [ ] GET /users/{id}/followers → 200 + data (with username), next_cursor, has_more, total
- [ ] Пагинация работает (limit, cursor)
- [ ] total показывает общее количество подписчиков

---

## Feature: List Following

**Описание:** Любой может посмотреть подписки пользователя.

**Acceptance Criteria:**

- [ ] GET /users/{id}/following → 200 + data, next_cursor, has_more, total

---

## Feature: Home Timeline

**Описание:** Авторизованный пользователь видит ленту твитов от тех, на кого подписан.

**Acceptance Criteria:**

- [ ] GET /timeline/home → 200 + data (tweet_id, author_id, scored_at), next_cursor, has_more
- [ ] Лента отсортирована по времени (новые сверху)
- [ ] После создания твита подписчиком, твит появляется в ленте
- [ ] Pull-to-refresh обновляет ленту
- [ ] Scroll to bottom загружает следующую страницу
- [ ] Без JWT → 401

---

## Feature: Search Tweets

**Описание:** Любой может искать твиты по тексту.

**Acceptance Criteria:**

- [ ] GET /tweets/search?q=... → 200 + data, next_cursor, has_more
- [ ] Без q → 400
- [ ] Результаты содержат твиты, где body содержит поисковый запрос

---

## Feature: List Notifications

**Описание:** Авторизованный пользователь видит уведомления.

**Acceptance Criteria:**

- [ ] GET /notifications → 200 + data, next_cursor, has_more, unread
- [ ] Лайк твита → уведомление типа "like" автору
- [ ] Подписка → уведомление типа "follow" target'у
- [ ] Не уведомлять о своих действиях (self-like, self-follow)

---

## Feature: Mark Notification Read

**Описание:** Пользователь может отметить уведомление прочитанным.

**Acceptance Criteria:**

- [ ] POST /notifications/{id}/read → 204
- [ ] unread count уменьшается
