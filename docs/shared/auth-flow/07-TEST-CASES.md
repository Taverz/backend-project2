# Auth — Test Cases (без кода)

> Описание тестовых сценариев. Без конкретного кода.
> AI читает → генерирует тесты на языке платформы.

---

## 1. Registration

### TC-REG-01: Успешная регистрация

**Precondition:** Пользователь не существует (email и username уникальны).

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть /register | Поля пустые, кнопка "Sign up" активна |
| 2 | Ввести username = "alice", email = "alice@test.com", password = "12345678" | Поля заполнены, кнопка активна |
| 3 | Tap "Sign up" | Кнопка меняется на spinner, поля disabled |
| 4 | — | Ответ 201 |
| 5 | — | Токены сохранены в SecureStorage |
| 6 | — | Redirect на /home |
| 7 | Проверить GET /users/me с access_token | 200, username = "alice" |

### TC-REG-02: Username слишком короткий

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть /register | — |
| 2 | Ввести username = "ab" | — |
| 3 | Перейти к полю email (onBlur) | Inline error: "Username must be 3-30 characters" |
| 4 | Tap "Sign up" | Кнопка НЕ отправляет запрос, форма показывает ошибку |

### TC-REG-03: Username слишком длинный

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть /register | — |
| 2 | Ввести username = 31 символ | Поле не принимает больше 30 (или показывает ошибку) |
| 3 | Tap "Sign up" | Ошибка валидации, запрос не отправлен |

### TC-REG-04: Username с недопустимыми символами

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести username = "Alice!" | — |
| 2 | onBlur / tap Submit | Inline error: "Only letters, digits, and underscores" |

### TC-REG-05: Email невалидный

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести email = "not-an-email" | — |
| 2 | onBlur | Inline error: "Enter a valid email address" |

### TC-REG-06: Password слишком короткий

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести password = "123" | — |
| 2 | onBlur / tap Submit | Inline error: "Password must be at least 8 characters" |

### TC-REG-07: Email уже зарегистрирован

**Precondition:** Пользователь с email = "alice@test.com" уже существует.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести username = "bob", email = "alice@test.com", password = "12345678" | — |
| 2 | Tap "Sign up" | Spinner → кнопка активна |
| 3 | — | Поле email подсвечено красным |
| 4 | — | Inline error: "Email already registered" |

### TC-REG-08: Username уже занят

**Precondition:** Пользователь с username = "alice" уже существует.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести username = "alice", email = "bob@test.com", password = "12345678" | — |
| 2 | Tap "Sign up" | Поле username подсвечено: "Username already taken" |

### TC-REG-09: Серверная ошибка

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Заполнить форму валидными данными | — |
| 2 | Tap "Sign up" | — |
| 3 | Backend отвечает 500 | ErrorView: "Something went wrong" + Retry |
| 4 | Tap Retry | Повторный запрос |

### TC-REG-10: Сетевой таймаут

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Заполнить форму | — |
| 2 | Отключить интернет | — |
| 3 | Tap "Sign up" | Toast: "No internet connection. Check your network." |
| 4 | Включить интернет | — |
| 5 | Tap "Sign up" | Успешная регистрация |

---

## 2. Login

### TC-LGN-01: Успешный вход

**Precondition:** Пользователь зарегистрирован.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть /login | Поля пустые, кнопка "Log in" активна |
| 2 | Ввести email = "alice@test.com", password = "12345678" | — |
| 3 | Tap "Log in" | Spinner, поля disabled |
| 4 | — | Ответ 200 |
| 5 | — | Токены сохранены |
| 6 | — | Redirect /home |
| 7 | Проверить /users/me с токеном | 200 |

### TC-LGN-02: Неверный пароль

**Precondition:** Пользователь зарегистрирован.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести email = "alice@test.com", password = "wrong" | — |
| 2 | Tap "Log in" | — |
| 3 | — | Toast: "Invalid email or password" |
| 4 | — | Поля НЕ очищены, кнопка активна |

### TC-LGN-03: Неверный email

**Precondition:** Пользователь НЕ зарегистрирован.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести email = "noone@test.com", password = "12345678" | — |
| 2 | Tap "Log in" | Toast: "Invalid email or password" |

### TC-LGN-04: Email невалидный (client-side)

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести email = "abc" | — |
| 2 | Tap "Log in" | Inline error, запрос НЕ отправлен |

### TC-LGN-05: Rate limiting

**Precondition:** Слишком много попыток за короткое время.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Ввести правильные данные | — |
| 2 | Tap "Log in" 5+ раз подряд | — |
| 3 | — | Toast: "Too many attempts. Try again in 30 seconds." |
| 4 | — | Кнопка disabled, показывает таймер |

### TC-LGN-06: Вход после регистрации (full flow)

**Precondition:** — 

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Register нового пользователя | 201, redirect /home |
| 2 | Logout | Redirect /login |
| 3 | Login с теми же credentials | 200, redirect /home |

---

## 3. Token refresh

### TC-RFS-01: Автоматический refresh

**Precondition:** У пользователя есть access_token и refresh_token.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Дождаться, пока access_token протухнет (15 мин) или подменить expired | — |
| 2 | Отправить запрос к 🔒 API (например GET /timeline/home) | — |
| 3 | — | ApiClient получает 401 |
| 4 | — | ApiClient отправляет POST /auth/refresh {refresh_token} |
| 5 | — | Backend возвращает 200 + новые токены |
| 6 | — | Новые токены сохранены в SecureStorage |
| 7 | — | Исходный запрос повторён с новым токеном |
| 8 | — | Исходный запрос 200 |
| 9 | — | Пользователь НЕ видит ни ошибку, ни редирект |

### TC-RFS-02: Refresh failed — logout

**Precondition:** refresh_token тоже протух (7 дней) или невалиден.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Отправить запрос к 🔒 API с expired access_token | — |
| 2 | — | 401 → POST /auth/refresh |
| 3 | — | Backend: 401 (refresh expired) |
| 4 | — | SecureStorage очищен |
| 5 | — | Redirect /login (replace) |
| 6 | — | AuthState = unauthenticated |

### TC-RFS-03: Race condition — 3 параллельных запроса

**Precondition:** access_token expires.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | 3 параллельных запроса к 🔒 API | Все получают 401 |
| 2 | — | Только 1 запрос делает POST /auth/refresh |
| 3 | — | 2 других ждут результат |
| 4 | — | Refresh ОК → все 3 retry с новым токеном |
| 5 | — | Все 3 получают 200 |

---

## 4. Auth guard

### TC-GRD-01: Без токена — редирект на login

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Очистить токены (clearTokens) | — |
| 2 | Попробовать открыть /home | Redirect /login |
| 3 | Попробовать открыть /profile | Redirect /login |
| 4 | Попробовать открыть /notifications | Redirect /login |
| 5 | Открыть /tweets/{id} (публичный) | Страница открыта (без редиректа) |

### TC-GRD-02: С токеном — редирект с login на home

**Precondition:** Есть живой access_token.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Попробовать открыть /login | Redirect /home |
| 2 | Попробовать открыть /register | Redirect /home |

### TC-GRD-03: Старт приложения без токена

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Установить приложение впервые | — |
| 2 | Открыть | Splash → проверка storage → пусто → /login |

### TC-GRD-04: Старт приложения с токеном

**Precondition:** Есть access_token.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Закрыть приложение (без logout) | — |
| 2 | Открыть | Splash → проверка storage → есть токен → /home |

### TC-GRD-05: Старт с expired токеном → refresh ОК

**Precondition:** access_token expired, refresh_token жив.

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть приложение | Splash → токен есть → проверка /users/me → 401 → refresh → 200 → /home |

---

## 5. Logout

### TC-LGT-01: Logout из профиля

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | Открыть ProfileScreen | Кнопка "Log out" видна |
| 2 | Tap "Log out" | Alert: "Are you sure?" |
| 3 | Tap "Cancel" | Alert закрыт, пользователь остался на ProfileScreen |
| 4 | Tap "Log out" | SecureStorage очищен |
| 5 | — | AuthState = unauthenticated |
| 6 | — | Redirect /login (clear stack) |
| 7 | Попробовать нажать "Back" | Не работает (стек очищен) |

---

## 6. Cross-platform: одинаковое поведение

| # | Сценарий | Flutter | Android | iOS | Web |
|---|----------|:-------:|:-------:|:---:|:---:|
| 1 | Регистрация → 201 → /home | ✅ | ✅ | ✅ | ✅ |
| 2 | Невалидный email → inline error | ✅ | ✅ | ✅ | ✅ |
| 3 | Неверный пароль → toast/alert | ✅ | ✅ | ✅ | ✅ |
| 4 | 401 → refresh → retry (без UI-артефактов) | ✅ | ✅ | ✅ | ✅ |
| 5 | Refresh failed → /login | ✅ | ✅ | ✅ | ✅ |
| 6 | Без токена → /login | ✅ | ✅ | ✅ | ✅ |
| 7 | Logout → clear tokens → /login | ✅ | ✅ | ✅ | ✅ |
| 8 | Race condition: 3 параллельных 401 → 1 refresh | ✅ | ✅ | ✅ | ✅ |
| 9 | Rate limiting → кнопка disabled + таймер | ✅ | ✅ | ✅ | ✅ |
| 10 | Network error → отдельное сообщение | ✅ | ✅ | ✅ | ✅ |
