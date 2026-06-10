# Auth — архитектура (sequence, data flow, screen flow, model structure)

> Описание без кода. На основе этой документации AI генерирует код
> для каждой платформы — Flutter, Android, iOS, Web, Backend.

---

## 1. Sequence diagram — Login flow

```
User          LoginScreen      AuthService/ApiClient      Backend
 │                 │                    │                    │
 │  tap "Log in"   │                    │                    │
 │────────────────►│                    │                    │
 │                 │                    │                    │
 │              [validate form]         │                    │
 │              email? password?        │                    │
 │              show errors ← invalid   │                    │
 │                 │                    │                    │
 │              [start loading]         │                    │
 │              button disabled         │                    │
 │              show spinner            │                    │
 │                 │                    │                    │
 │                 │  POST /auth/login  │                    │
 │                 │───────────────────►│                    │
 │                 │                    │  POST /auth/login  │
 │                 │                    │───────────────────►│
 │                 │                    │                    │
 │                 │                    │              [validate credentials]
 │                 │                    │              [issue JWT pair]
 │                 │                    │                    │
 │                 │                    │  200 + tokens      │
 │                 │                    │◄───────────────────│
 │                 │                    │                    │
 │                 │           [save tokens to secure storage]
 │                 │           [update auth state → authenticated]
 │                 │                    │                    │
 │                 │  success callback  │                    │
 │                 │◄───────────────────│                    │
 │                 │                    │                    │
 │              [navigate to /home]     │                    │
 │                 │                    │                    │
 │◄────────────────│                    │                    │
 │   sees Home     │                    │                    │
```

**Ключевые моменты:**
- Форма валидируется ДО отправки запроса (client-side)
- Ошибка валидации — inline под полем
- Ошибка 401 от сервера — toast/alert "Invalid email or password"
- Ошибка 500 — "Something went wrong" + Retry
- После успеха — replace navigation (не push, чтобы нельзя было вернуться назад)

---

## 2. Sequence diagram — Register flow

```
User         RegisterScreen     AuthService/ApiClient     Backend
 │                 │                    │                    │
 │  tap "Sign up"  │                    │                    │
 │────────────────►│                    │                    │
 │                 │                    │                    │
 │              [validate all fields]   │                    │
 │              username: 3-30, a-z0-9_ │                    │
 │              email: valid format     │                    │
 │              password: 8-72 chars    │                    │
 │              show inline errors      │                    │
 │                 │                    │                    │
 │                 │  POST /auth/register                   │
 │                 │───────────────────►│                    │
 │                 │                    │  POST /auth/register
 │                 │                    │───────────────────►│
 │                 │                    │                    │
 │                 │                    │            [check unique email]
 │                 │                    │            [check unique username]
 │                 │                    │            [bcrypt hash]
 │                 │                    │            [save user]
 │                 │                    │            [issue JWT]
 │                 │                    │                    │
 │                 │                    │  201 + user+tokens │
 │                 │                    │◄───────────────────│
 │                 │                    │                    │
 │  [409]          │  "email taken"     │                    │
 │  ← highlight    │◄───────────────────│                    │
 │  email field    │                    │                    │
 │                 │                    │                    │
 │  [201]          │  save tokens       │                    │
 │                 │  navigate /home    │                    │
 │                 │◄───────────────────│                    │
```

**Ошибки 400 — inline под соответствующим полем:**
- `username: must be at least 3 characters` → под username
- `email: invalid format` → под email
- `password: must be at least 8 characters` → под password

**Ошибки 409 — highlight поля + сообщение:**
- `email already registered` → красная рамка на email
- `username already taken` → красная рамка на username

---

## 3. Sequence diagram — Token refresh (401 → retry)

```
App              ApiClient          AuthService           Backend
 │                    │                    │                    │
 │  request /tweets   │                    │                    │
 │───────────────────►│                    │                    │
 │                    │  GET /tweets       │                    │
 │                    │  Authorization:    │                    │
 │                    │  Bearer <access>   │───────────────────►│
 │                    │                    │                    │
 │                    │              401 Unauthorized          │
 │                    │◄───────────────────────────────────────│
 │                    │                    │                    │
 │                    │  refresh_token?    │                    │
 │                    │──────────────────►│                    │
 │                    │                    │  POST /auth/refresh│
 │                    │                    │───────────────────►│
 │                    │                    │                    │
 │                    │                    │  200 + new tokens  │
 │                    │                    │◄───────────────────│
 │                    │  save new tokens   │                    │
 │                    │◄───────────────────│                    │
 │                    │                    │                    │
 │                    │  RETRY GET /tweets │                    │
 │                    │  Bearer <new>      │───────────────────►│
 │                    │                    │                    │
 │                    │  200 + tweets      │                    │
 │                    │◄───────────────────│                    │
 │◄───────────────────│                    │                    │
```

**Критическое правило:** refresh должен вызываться только ОДИН раз для пачки параллельных 401. Если 3 запроса получили 401 одновременно — только один делает refresh, остальные ждут.

```
3 параллельных запроса → все получают 401
  → первый: делает POST /auth/refresh
  → второй и третий: ждут (pending queue)
  → первый получил новые токены → сохранил
  → второй и третий: retry с новым токеном
```

**Если refresh тоже 401:** очистить токены, redirect на /login.

---

## 4. Model structure

### Data models (from API)

```
┌─────────────────────────────────────┐
│            AuthResponse              │
├─────────────────────────────────────┤
│ + user: User                        │
│ + access_token: string              │
│ + refresh_token: string             │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│              User                    │
├─────────────────────────────────────┤
│ + id: string (UUID)                 │
│ + username: string (3-30, a-z0-9_)  │
│ + email: string (valid format)      │
│ + display_name: string              │
│ + bio: string                       │
│ + created_at: datetime (ISO 8601)   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│          LoginRequest                │
├─────────────────────────────────────┤
│ + email: string                     │
│ + password: string                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         RegisterRequest              │
├─────────────────────────────────────┤
│ + username: string                  │
│ + email: string                     │
│ + password: string                  │
└─────────────────────────────────────┘
```

### UI State models

```
┌─────────────────────────────────────┐
│         AuthState (sealed)           │
├─────────────────────────────────────┤
│ - AuthState.unauthenticated()       │
│ - AuthState.loading()               │
│ - AuthState.authenticated(user)     │
│ - AuthState.error(message)          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│       AuthFormState (sealed)         │
├─────────────────────────────────────┤
│ - AuthFormState.idle()              │
│ - AuthFormState.validating()        │
│ - AuthFormState.submitting()        │
│ - AuthFormState.fieldError(         │
│     field, message)                 │
│ - AuthFormState.serverError(message)│
│ - AuthFormState.success()           │
└─────────────────────────────────────┘
```

### Token models

```
┌─────────────────────────────────────┐
│           TokenPair                  │
├─────────────────────────────────────┤
│ + access_token: string              │
│   └─ формат: JWT HS256              │
│   └─ payload: {sub, iat, exp}       │
│   └─ TTL: 15 минут                  │
│ + refresh_token: string             │
│   └─ TTL: 7 дней                    │
└─────────────────────────────────────┘
```

### Relationship diagram

```
AuthResponse
  ├── содержит User (профиль)
  └── содержит TokenPair (access + refresh)

TokenPair
  ├── access → хранится в SecureStorage/Keychain
  ├── refresh → хранится в SecureStorage/Keychain
  └── access → expires → refresh → new TokenPair

AuthState
  ├── unauthenticated → LoginScreen показан
  ├── authenticated → HomeScreen показан
  ├── loading → спиннер
  └── error → ErrorView + Retry
```

---

## 5. Screen flow (navigation graph)

```
                        ┌─────────────┐
                        │   /splash   │
                        └──────┬──────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
              has token?             no token?
                    │                     │
                    ▼                     ▼
            ┌──────────────┐    ┌───────────────────┐
            │   /home      │    │    /login         │
            │  (protected) │    │                   │
            └──────────────┘    │  "Sign up" link    │
                    │           └────────┬──────────┘
                    │                    │ tap
                    │           ┌────────▼──────────┐
                    │           │    /register      │
                    │           │                   │
                    │           │  "Log in" link    │
                    │           └────────┬──────────┘
                    │                    │
                    │           ┌────────▼──────────┐
                    │           │  регистрация      │
                    │           │  успешна          │
                    │           └────────┬──────────┘
                    │                    │
                    ◄────────────────────┘
                    │  (replace, не push)
                    │
                    ▼
            ┌──────────────┐
            │   /home      │
            │              │
            │ Logout →     │──────► /login (clear stack)
            └──────────────┘
```

**Правила навигации:**
- `/login` и `/register` — НЕТ bottom navigation, НЕТ back button (это отдельный flow)
- После login/register — replace `/home` (нельзя вернуться назад к форме)
- Logout — clear весь navigation stack → `/login`
- При 401 + неудачный refresh — принудительный redirect на `/login` из любого экрана
- `/splash` — временный экран, пока проверяется JWT

---

## 6. Data flow — Login (полный пример)

```
Layer               Что происходит
─────────────────────────────────────────────────────────
1. User Input       User вводит email + password
                    tap "Log in"
                    
2. Form             Client-side validation:
                    - email: не пустой, содержит @ и домен
                    - password: не пустой, >= 8 символов
                    Если ошибка → показать inline под полем, STOP
                    Если OK → formState = submitting

3. ViewModel /      Создать LoginRequest {email, password}
   Provider         Вызвать ApiClient.post('/auth/login', body)
                    State = loading (кнопка disabled + spinner)

4. ApiClient        Взять заголовки:
                    Content-Type: application/json
                    (без Authorization — это публичный endpoint)
                    POST http://localhost:8080/api/v1/auth/login

5. Backend          Получить запрос
                    Провалидировать email
                    Найти пользователя по email
                    Сравнить bcrypt(password, hash)
                    Если не совпало → 401
                    Если совпало → сгенерировать JWT pair
                    Вернуть 200 + {user, access_token, refresh_token}

6. ApiClient        Получить 200 OK
                    Распарсить JSON → AuthResponse
                    Вернуть в Provider

7. Provider /       Получить AuthResponse
   ViewModel        Вызвать AuthService.saveTokens(access, refresh)
                    AuthService → сохранить access в SecureStorage
                    AuthService → сохранить refresh в SecureStorage
                    Обновить AuthState = authenticated(user)
                    Вернуть success

8. Screen           Получить success callback
                    Navigate.replace('/home')
                    
9. HomeScreen       GoRouter видит: state = authenticated, path = /home
                    AuthGuard: OK, есть токен → показать HomeScreen

─────────────────────────────────────────────────────────
Если на шаге 5 → 401:
    6'. Provider получает ошибку
    7'. AuthState = error("Invalid email or password")
    8'. Screen показывает toast/alert с ошибкой
    9'. FormState = idle (кнопка активна, можно повторить)

Если на шаге 5 → 500 / network error:
    6'. Provider получает ошибку
    7'. AuthState = error("Something went wrong")
    8'. Screen показывает ErrorView + Retry button
    9'. Tap Retry → повтор с шага 3
```

---

## 7. Auth state machine

```
          [app launch]
               │
               ▼
      ┌────────────────┐
      │  UNKNOWN        │───► проверка токена в storage
      └────────────────┘
               │
      ┌────────┴────────┐
      │                 │
   token found      no token
      │                 │
      ▼                 ▼
┌────────────────┐ ┌────────────────┐
│ AUTHENTICATED   │ │ UNAUTHENTICATED │
│ user, tokens    │ │ null            │
│ → /home         │ │ → /login        │
└───────┬────────┘ └────────┬────────┘
        │                   │
        │  logout           │  login/register
        │  clear tokens     │  save tokens
        └───────────────────┘
                │
                ▼
        ┌────────────────┐
        │  LOADING       │──► валидация → API call
        └────────────────┘
                │
        ┌───────┴───────┐
        │               │
     success          error
        │               │
        ▼               ▼
  ┌─────────┐   ┌──────────────┐
  │ AUTH    │   │ ERROR        │
  │ ENTERED │   │ show message │
  │→ /home  │   │ retry → LOAD │
  └─────────┘   └──────────────┘
```

**Переходы:**
- `UNKNOWN → UNAUTHENTICATED` — нет токена при старте
- `UNKNOWN → AUTHENTICATED` — есть живой токен при старте
- `UNAUTHENTICATED → LOADING` — пользователь tap "Log in" или "Sign up"
- `LOADING → AUTHENTICATED` — API вернул 200 + tokens
- `LOADING → ERROR` — API вернул 400/401/409/500
- `ERROR → LOADING` — пользователь tap Retry или исправил поле
- `AUTHENTICATED → UNAUTHENTICATED` — logout или expired refresh
- `AUTHENTICATED → LOADING` — 401 → refresh (background, не видно пользователю)

---

## 8. Screen widget tree (без кода)

### LoginScreen

```
LoginScreen
├── SafeArea
│   └── SingleChildScrollView
│       └── Column, centered
│           ├── Logo/Header: "Welcome to Chirp"
│           ├── LoginForm
│           │   ├── EmailField
│           │   │   ├── TextInput (email keyboard)
│           │   │   ├── Placeholder: "Email"
│           │   │   └── ErrorText (inline, conditional)
│           │   ├── PasswordField
│           │   │   ├── TextInput (obscured)
│           │   │   ├── Placeholder: "Password"
│           │   │   └── ErrorText (inline, conditional)
│           │   └── PrimaryButton
│           │       ├── States: enabled, disabled (loading), error
│           │       ├── Label: "Log in" / spinner
│           │       └── OnTap: submit form
│           └── LinkRow
│               ├── Text: "Don't have an account?"
│               └── LinkButton: "Sign up" → /register
```

### RegisterScreen

```
RegisterScreen
├── SafeArea
│   └── SingleChildScrollView
│       └── Column, centered
│           ├── Header: "Create your account"
│           ├── RegisterForm
│           │   ├── UsernameField
│           │   │   ├── TextInput (regular keyboard)
│           │   │   ├── Counter: "3/30" (show current length)
│           │   │   └── ErrorText (conditional)
│           │   ├── EmailField (same as login)
│           │   ├── PasswordField
│           │   │   ├── TextInput (obscured)
│           │   │   ├── StrengthIndicator (optional: weak/medium/strong)
│           │   │   └── ErrorText (conditional)
│           │   └── PrimaryButton
│           │       └── Label: "Sign up"
│           └── LinkRow
│               └── "Already have an account? Log in" → /login
```

### AuthGuard (wrapper, невидим)

```
AuthGuard
├── [no token] → Navigate.replace(/login)
└── [has token] → child screen (HomeScreen и т.д.)
```

### State → Widget mapping

| State | LoginScreen | RegisterScreen |
|-------|-------------|----------------|
| Idle | Empty form, button enabled | Empty form, button enabled |
| Field error | Подсвеченное поле + текст ошибки | Подсвеченное поле + текст ошибки |
| Server error (400) | Toast/alert под формой | Toast/alert + поле подсвечено |
| Server error (401) | Toast "Invalid email or password" | — |
| Server error (409) | — | Подсветка email или username |
| Server error (500) | ErrorView + Retry | ErrorView + Retry |
| Loading | Button disabled + spinner | Button disabled + spinner |
| Success | Redirect /home | Redirect /home |

---

## 9. Token lifecycle

```
[Register/Login]
  ├── Backend создаёт TokenPair (access + refresh)
  ├── Клиент получает в JSON
  ├── access → SecureStorage (ключ: "access_token")
  └── refresh → SecureStorage (ключ: "refresh_token")

[Каждый запрос к 🔒 API]
  ├── ApiClient читает access_token из SecureStorage
  └── Добавляет заголовок: Authorization: Bearer <access>

[access_token expires → 401]
  ├── ApiClient перехватывает 401
  ├── Проверяет: refresh_token существует?
  │     ├── Нет → AuthState = unauthenticated → /login
  │     └── Да → POST /auth/refresh {refresh_token}
  │           ├── 200 → save новые tokens, retry original request
  │           └── 401/error → clear tokens → /login
  (Race condition: concurrent 401 → queue, один refresh)

[Logout]
  ├── Clear SecureStorage (access + refresh)
  └── AuthState = unauthenticated → /login

[App restart]
  ├── Проверить SecureStorage
  ├── access_token есть?
  │     ├── Нет → /login
  │     └── Да → попробовать GET /users/me с токеном
  │           ├── 200 → /home
  │           └── 401 → попробовать refresh → если нет → /login
```

---

## 10. Error propagation

```
                    Backend error
                         │
                         ▼
                    HTTP response
                    (400/401/409/500)
                         │
                         ▼
                   ApiClient
                    ┌──────────────┐
                    │ parse JSON   │
                    │ ProblemDetail│
                    └──────┬───────┘
                           │
                    ┌──────┴──────┐
                    │             │
                   401          400/409/500
                    │             │
                    ▼             ▼
            ┌────────────┐ ┌──────────────┐
            │ try refresh│ │ throw error  │
            │ success?   │ │              │
            │  ┌────┐    │ │ message =    │
            │  │retry│   │ │ detail field │
            │  └────┘    │ └──────┬───────┘
            │     │      │        │
            │  ┌──┴──┐   │        ▼
            │  │fail │   │  Provider/ViewModel
            │  └─────┘   │  ┌──────────────┐
            │     │      │  │ map error →  │
            │     ▼      │  │ user message │
            │  /login    │  └──────┬───────┘
            └────────────┘         │
                                   ▼
                              Screen widget
                              ┌──────────────┐
                              │ show toast / │
                              │ inline error │
                              │ ErrorView    │
                              └──────────────┘
```

**Правила маппинга ошибок:**
- `400 Bad Request` → detail содержит имя поля + причина → inline под полем
- `401 Unauthorized` → refresh queue → если не вышло → /login
- `403 Forbidden` → скрыть элемент, вызвавший ошибку
- `404 Not Found` → показать "Not found" экран
- `409 Conflict` → подсветить поле (email/username) + сообщение
- `413 Payload Too Large` → показать ограничение размера
- `429 Too Many Requests` → toast "Please slow down" + retry через N сек
- `5xx / network error` → ErrorView + Retry button

---

## 11. Что ещё нужно для полной картины

На уровне **всего приложения** (не только auth) не хватает:

| Чего не хватает | Где должно быть |
|----------------|----------------|
| **Navigation graph всего приложения** (не только auth → home) | shared/SCREENS.md (дополнить) |
| **Component tree всего приложения** (какие экраны из каких виджетов состоят) | shared/SCREENS.md — уже есть частично |
| **Data flow каждой фичи** (create tweet, follow, like — так же как здесь для auth) | В соответствующих flow-документах |
| **Глобальная обработка ошибок** (401 → refresh → retry описана, а network timeout? offline mode?) | shared/ERRORS.md |
| **Race conditions** (два лайка одновременно, double tap на Follow) | В каждом flow |
| **Offline/loading priority** (показать кэш пока грузится? или skeleton обязательно?) | shared/SCREENS.md (states) |
