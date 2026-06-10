# Auth — Screen Behavior Spec

> Описание логики работы каждого экрана для человека.
> Человек читает → утверждает → AI реализует.
> Не код, не дизайн, не архитектура — чистое поведение.

---

## Screen: LoginScreen

### Pre-condition
- Пользователь не авторизован
- Нет токенов в SecureStorage
- Маршрут: `/login`

### 1. Initial load

```
Система:      Показать LoginScreen с пустыми полями
              Email: placeholder "Email"
              Password: placeholder "Password"
              Кнопка "Log in" — enabled (но ничего не делает, поля пустые)
              Ссылка "Don't have an account? Sign up"

Пользователь: Видит форму входа
```

**Business rules:**
- Если пользователь уже авторизован и каким-то образом попал на /login → редирект на /home
- Кнопка enabled, но если оба поля пустые — disabled (чтобы пользователь не тыкал в пустую форму)

### 2. User types email

```
Пользователь:  Tap на поле Email
               → Поле в фокусе, клавиатура (email keyboard)

              Печатает email

Система:      Показывает текст в поле
              Кнопка "Log in" — enabled (если оба поля не пустые)

Пользователь:  Переходит к полю Password (onBlur)

СистемА:      Валидирует email:
              ┣━ Если email пустой → ничего (ошибка не показывается на пустом поле)
              ┣━ Если email невалидный (нет @ или домена)
              ┃    → Email поле: красный border
              ┃    → Inline error под полем: "Enter a valid email address"
              ┗━ Если email валидный → ничего
```

**Business rules:**
- Ошибка показывается ТОЛЬКО после onBlur (уход с поля), не во время печати
- Пустое поле НЕ считается ошибкой на onBlur (пользователь мог ещё не ввести)
- После того как ошибка показана, пользователь начинает печатать → ошибка скрывается, border становится нейтральным

### 3. User types password

```
Пользователь:  Tap на поле Password
              → Поле в фокусе, символы скрыты (••••••)
              → Иконка "eye" справа — tap toggle show/hide

              Печатает password

Система:      Показывает •••••••• вместо символов
              Если password < 8 символов → ничего (ошибка только на onBlur или submit)

Пользователь:  Переходит к полю Email (onBlur) или Tap "Log in"

Система:      Валидирует password:
              ┣━ Если password пустой → ничего
              ┣━ Если password < 8 символов
              ┃    → Inline error: "Password must be at least 8 characters"
              ┗━ Если password >= 8 → ничего
```

### 4. User taps "Log in"

```
Пользователь:  Tap кнопка "Log in"

Система:      Валидирует ОБА поля:
              ┣━ Email невалидный
              ┃    → Email: красный border
              ┃    → Inline error: "Enter a valid email address"
              ┃    → STOP — запрос НЕ отправляется
              ┣━ Password < 8
              ┃    → Password: красный border
              ┃    → Inline error: "Password must be at least 8 characters"
              ┃    → STOP — запрос НЕ отправляется
              ┗━ Оба поля валидны → ПРОДОЛЖИТЬ

              [Оба поля валидны]
              ┣━ Кнопка: spinner вместо текста, disabled
              ┣━ Email + Password поля: disabled
              ┣━ POST /api/v1/auth/login {email, password}
              ┃
              ┃  ┣━ Response: 200 OK
              ┃  ┃   ├─ saveTokens(access_token, refresh_token) → SecureStorage
              ┃  ┃   ├─ authState → authenticated(user)
              ┃  ┃   ├─ Toast: нет (успех — без сообщения)
              ┃  ┃   └─ Navigate /home (replace, clear navigation stack)
              ┃  ┃
              ┃  ┣━ Response: 400 Bad Request
              ┃  ┃   ├─ detail содержит поле + причину
              ┃  ┃   ├─ Подсветить конкретное поле красным
              ┃  ┃   ├─ Inline error под полем
              ┃  ┃   ├─ Кнопка: enabled, текст "Log in"
              ┃  ┃   └─ Поля: enabled, значения НЕ стираются
              ┃  ┃
              ┃  ┣━ Response: 401 Unauthorized
              ┃  ┃   ├─ Toast/alert сверху: "Invalid email or password"
              ┃  ┃   ├─ Поля: НЕ подсвечиваются (это не ошибка поля)
              ┃  ┃   ├─ Кнопка: enabled, текст "Log in"
              ┃  ┃   └─ Поля: enabled, значения НЕ стираются
              ┃  ┃
              ┃  ┣━ Response: 429 Too Many Requests
              ┃  ┃   ├─ Toast: "Too many attempts. Try again in 30 seconds."
              ┃  ┃   ├─ Кнопка: disabled на 30 секунд
              ┃  ┃   ├─ Поля: enabled
              ┃  ┃   └─ Через 30 секунд: кнопка enabled автоматически
              ┃  ┃
              ┃  ┣━ Response: 5xx Server Error
              ┃  ┃   ├─ ErrorView на весь экран
              ┃  ┃   ├─ Сообщение: "Something went wrong"
              ┃  ┃   ├─ Кнопка: "Try again"
              ┃  ┃   └─ Tap "Try again" → повторный запрос
              ┃  ┃
              ┃  ┗━ Network Error (таймаут / нет интернета)
              ┃      ├─ Toast: "No internet connection. Check your network."
              ┃      ├─ Кнопка: enabled
              ┃      └─ Поля: enabled
```

### 5. User taps "Sign up"

```
Пользователь:  Tap "Don't have an account?" → "Sign up"

Система:      Navigate /register (push)
              LoginScreen остаётся в стеке (можно вернуться)
```

---

## Screen: RegisterScreen

### Pre-condition
- Пользователь не авторизован
- Маршрут: `/register`

### 1. Initial load

```
Система:      Показать RegisterScreen с пустыми полями
              Username: placeholder "Username", counter "0/30"
              Email: placeholder "Email"
              Password: placeholder "Password"
              Кнопка "Sign up" — disabled (поля пустые)
              Ссылка "Already have an account? Log in"

Пользователь:  Видит форму регистрации
```

### 2. User types username

```
Пользователь:  Tap Username → поле в фокусе
              Печатает "alice"

Система:      Показывает текст + counter "6/30" (серый)
              По мере печати:
              ┣━ 0-25 символов → counter серый
              ┣━ 26-30 → counter жёлтый/оранжевый
              ┣━ 30 → counter красный "30/30", дальше не печатается

Пользователь:  Переходит к Email (onBlur)

Система:      Валидирует username:
              ┣━ Пустой → ничего
              ┣━ < 3 символов → "Username must be 3-30 characters"
              ┣━ 3-30, но есть недопустимые символы (!, @, пробел, заглавные)
              ┃   → "Only letters, digits, and underscores" + username должен быть lowercase
              ┗━ 3-30, a-z, 0-9, _ → OK
```

### 3. User types email

```
Система:      Валидирует email (та же логика что и в LoginScreen)

              ┣━ Невалидный → "Enter a valid email address"
              ┗━ Валидный → OK
```

### 4. User types password

```
Система:      Валидирует password:
              ┣━ < 8 → "Password must be at least 8 characters"
              ┗━ >= 8 → зелёная галочка "✓ Good password"

              Password strength indicator (опционально):
              ┣━ 8-10 символов → "Weak" (жёлтый)
              ┣━ 11-15 → "Medium" (оранжевый)
              ┗━ 16+ → "Strong" (зелёный)
```

### 5. User taps "Sign up"

```
Пользователь:  Tap "Sign up"

Система:      Валидирует ВСЕ поля (username + email + password):
              ┣━ Любое невалидно → подсветить + inline error → STOP
              ┗━ Все валидны → ПРОДОЛЖИТЬ

              [Все поля валидны]
              ┣━ Кнопка: spinner, disabled
              ┣━ Поля: disabled
              ┣━ POST /api/v1/auth/register {username, email, password}
              ┃
              ┃  ┣━ Response: 201 Created
              ┃  ┃   ├─ saveTokens(access_token, refresh_token) → SecureStorage
              ┃  ┃   ├─ authState → authenticated(user)
              ┃  ┃   └─ Navigate /home (replace, clear stack)
              ┃  ┃
              ┃  ┣━ Response: 400 Bad Request (validation)
              ┃  ┃   ├─ Подсветить конкретное поле
              ┃  ┃   ├─ Inline error (возможно другое сообщение, чем на клиенте)
              ┃  ┃   └─ Кнопка enabled, поля enabled
              ┃  ┃
              ┃  ┣━ Response: 409 Conflict — email
              ┃  ┃   ├─ Email поле: красный border
              ┃  ┃   ├─ Inline: "Email already registered"
              ┃  ┃   ├─ Username поле: НЕ подсвечено (конфликт не по нему)
              ┃  ┃   └─ Кнопка enabled
              ┃  ┃
              ┃  ┣━ Response: 409 Conflict — username
              ┃  ┃   ├─ Username поле: красный border
              ┃  ┃   ├─ Inline: "Username already taken"
              ┃  ┃   └─ Кнопка enabled
              ┃  ┃
              ┃  ┣━ Response: 5xx → ErrorView + Retry
              ┃  ┗━ Network Error → Toast + форма активна
```

---

## Screen: AuthGuard (системный, невидимый)

### Pre-condition
- Любой переход на новый маршрут

### 1. Route transition logic

```
Событие:      Пользователь пытается открыть /home (или любой protected route)

Система:      Смотрит authState:
              ┣━ authState = .loading
              ┃   └─ Показать спиннер (или ничего), НЕ редиректить
              ┃
              ┣━ authState = .unauthenticated
              ┃   └─ Redirect /login (replace)
              ┃
              ┗━ authState = .authenticated
                  └─ Разрешить навигацию


Событие:      Пользователь пытается открыть /login (или /register)

Система:      Смотрит authState:
              ┣━ authState = .authenticated
              ┃   └─ Redirect /home (replace)
              ┃
              ┗━ authState = .unauthenticated или .loading
                  └─ Разрешить навигацию


Событие:      Пользователь пытается открыть публичный маршрут (/tweets/{id}, /search)

Система:      Всегда разрешить (независимо от authState)
```

**Business rules:**
- AuthGuard НЕ должен редиректить на /login при authState = .loading
  Иначе пользователь увидит вспышку LoginScreen при старте приложения,
  пока проверяется токен
- Решение: либо не рендерить ничего при loading, либо показывать splash/spinner

---

## Screen: SplashScreen (startup)

### Pre-condition
- Приложение запущено

### 1. Check token on startup

```
Система:      Показать SplashScreen (логотип + спиннер)
              Проверить SecureStorage:

              ┣━ access_token + refresh_token есть
              ┃   └─ GET /api/v1/users/me с access_token
              ┃       ┣━ 200 OK → user получен
              ┃       ┃   ├─ authState = .authenticated(user)
              ┃       ┃   └─ Navigate /home
              ┃       ┃
              ┃       ┣━ 401 (token expired)
              ┃       ┃   └─ POST /api/v1/auth/refresh {refresh_token}
              ┃       ┃       ┣━ 200 → saveTokens(newAccess, newRefresh)
              ┃       ┃       ┃        ├─ authState = .authenticated
              ┃       ┃       ┃        └─ Navigate /home
              ┃       ┃       ┃
              ┃       ┃       ┗━ error → clearTokens()
              ┃       ┃                ├─ authState = .unauthenticated
              ┃       ┃                └─ Navigate /login
              ┃       ┃
              ┃       ┗━ error (network) → Navigate /home (показать кэш, если есть)
              ┃
              ┗━ Нет токенов
                  └─ authState = .unauthenticated
                     └─ Navigate /login


Безопасность:  Если response от /users/me или /auth/refresh не пришёл за 10 секунд
              └─ Показать ErrorView: "Couldn't connect to server" + "Retry" button
                  Tap Retry → повтор с начала
```

---

## Token Refresh (background, невидимый экран)

### Pre-condition
- Пользователь авторизован (токены есть)
- Происходит запрос к 🔒 API

### 1. 401 → refresh flow

```
Событие:      Любой запрос к 🔒 API → 401 Unauthorized

Система:      [Interceptor / ApiClient]
              1. Проверить: refresh_token существует?
                 ┣━ Нет → clearTokens() → authState = .unauthenticated → Navigate /login
                 ┗━ Да → продолжать

              2. Проверить: уже выполняется refresh другим запросом?
                 ┣━ Да → дождаться его результат → retry original request
                 ┗━ Нет → выполнить refresh

              3. POST /api/v1/auth/refresh {refresh_token}
                 ┣━ 200 → saveTokens(newAccess, newRefresh)
                 ┃        → retry original request with new access_token
                 ┃        → оригинальный запрос 200 → отдать результат
                 ┃
                 ┗━ error → clearTokens()
                            authState = .unauthenticated
                            Navigate /login
                            Пользователь НЕ видит ошибку — просто оказывается на /login

              ВАЖНО: Пользователь НЕ ДОЛЖЕН видеть никаких UI-артефактов
              во время refresh. Ни спиннера, ни тоста, ни изменения экрана.
              Refresh происходит полностью в фоне.
```

**Race condition guard:**

```
Три параллельных запроса к API:
  Req1: GET /timeline/home       → 401
  Req2: GET /notifications       → 401
  Req3: GET /users/me            → 401

  Req1 проверяет: refreshPromise == null → выполняет POST /auth/refresh
  Req2 проверяет: refreshPromise != null → ждёт
  Req3 проверяет: refreshPromise != null → ждёт

  POST /auth/refresh → 200 → saveTokens
  Req1: retry → GET /timeline/home → 200 ✓
  Req2: retry → GET /notifications → 200 ✓
  Req3: retry → GET /users/me → 200 ✓

  Результат: 1 refresh вместо 3, все 3 запроса успешны
```

---

## Logout (из ProfileScreen)

### Pre-condition
- Пользователь авторизован
- Маршрут: /profile

```
Пользователь:  Tap "Log out"

Система:      Показать Alert Dialog:
              Title: "Log out of Chirp?"
              Message: "Are you sure you want to log out?"
              Buttons:
                ┣━ "Cancel" → закрыть диалог, ничего не делать
                ┗━ "Log out" (danger red)
                     └─ Tap → clearTokens()
                              authState = .unauthenticated
                              Navigate /login (replace, clear весь стек)
                              Alert закрывается автоматически

              После logout:
              ┣━ Пользователь на /login
              ┣━ Кнопка "Back" не работает (стек очищен)
              ┗━ SecureStorage пуст
```

**Business rules:**
- Обязательно подтверждение (Alert) — logout необратим
- Cancel — закрыть диалог, не очищать токены
- После logout нельзя вернуться назад (clear entire stack)

---

## Что утверждает человек

Человек (тимлид / PM) читает этот документ и проверяет:

1. **Все ли сценарии описаны?**
   - Happy path (успешный вход)
   - Validation errors (невалидные поля)
   - Server errors (401, 409, 500)
   - Network errors (таймаут, нет интернета)
   - Edge cases (rate limit, race condition)

2. **Правильная ли реакция на ошибки?**
   - 401 → toast, а не inline error
   - 409 → подсветка поля, а не общее сообщение
   - 500 → ErrorView + Retry, а не тост

3. **Нет ли лишнего?**
   - Не показываем success toast (редирект — достаточный сигнал)
   - Не блокируем UI без необходимости

4. **UI не противоречит дизайну?**
   - Порядок полей совпадает с Figma
   - Сообщения об ошибках совпадают с DESIGN-SYSTEM

**После утверждения — AI получает задачу: «Реализуй LoginScreen по Screen Behavior Spec».**
AI не нужно думать — всё уже решено.
