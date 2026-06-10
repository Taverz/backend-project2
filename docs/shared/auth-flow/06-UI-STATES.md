# Auth — UI States (полная таблица)

> Все состояния всех экранов авторизации. Без кода.
> AI читает → знает, какие состояния должен обработать каждый экран.

---

## 1. SplashScreen

| # | State | Trigger | UI Elements | Actions |
|---|-------|---------|-------------|---------|
| 1.1 | **checking** | App launched | Center: logo + spinner | — |
| 1.2 | **authenticated** | Токен есть, /users/me 200 | — | Redirect → /home (replace) |
| 1.3 | **no_token** | Storage пуст | — | Redirect → /login (replace) |
| 1.4 | **refresh_ok** | Токен протух, refresh 200 | — | Redirect → /home (replace) |
| 1.5 | **refresh_fail** | Токен протух, refresh error | — | Redirect → /login (replace) |

**Таймаут:** если через 10 секунд splash висит — показать ErrorView с Retry.

---

## 2. LoginScreen

| # | State | Trigger | Form fields | Button | Error display | Navigation |
|---|-------|---------|-------------|--------|---------------|------------|
| 2.1 | **idle** | Первый вход, возврат с ошибки | Пустые, enabled | "Log in" enabled | Скрыт | — |
| 2.2 | **field_error** | onBlur: невалидное поле | Invalid field подсвечено | "Log in" enabled | Inline под полем | — |
| 2.3 | **submitting** | Tap "Log in", валидация OK | Disabled | Spinner вместо текста | Скрыт | — |
| 2.4 | **error_401** | Ответ: 401 | Enabled, значения сохранены | "Log in" enabled | Toast/alert сверху: "Invalid email or password" | — |
| 2.5 | **error_400** | Ответ: 400 с detail | Поле по detail подсвечено | "Log in" enabled | Inline под полем | — |
| 2.6 | **error_500** | Ответ: 5xx или network timeout | Enabled | "Log in" enabled | ErrorView "Something went wrong" + Retry button | — |
| 2.7 | **error_network** | Нет интернета | Enabled | "Log in" enabled | Toast: "No internet connection. Check your network." | — |
| 2.8 | **success** | Ответ: 200 | — | — | — | Redirect /home (replace, clear stack) |
| 2.9 | **rate_limited** | Ответ: 429 | Enabled | "Log in" disabled на N сек | Toast: "Too many attempts. Try again in 30 seconds." | — |

### Transition diagram

```
idle ──onBlur──► field_error ──onFocus──► idle
  │                                        ▲
  ├──tap Submit (valid)──► submitting ─────┤
  │                           │            │
  │                    ┌──────┴──────┐     │
  │                    │             │     │
  │              200 ──► success     500 ──┤
  │                    │             │     │
  │                    ▼             ▼     │
  │               Redirect /home   ErrorView──tap Retry──► submitting
  │                                        │
  └──tap Submit (invalid)──► field_error ──┘
```

---

## 3. RegisterScreen

| # | State | Trigger | Fields | Button | Error display | Nav |
|---|-------|---------|--------|--------|---------------|-----|
| 3.1 | **idle** | Первый вход | Пустые, enabled | "Sign up" enabled | Скрыт | — |
| 3.2 | **field_error** | onBlur: username < 3 | Username подсвечен | "Sign up" enabled | Inline: "Username must be 3-30 characters" | — |
| 3.3 | **field_error** | onBlur: username invalid chars | Username подсвечен | "Sign up" enabled | Inline: "Only letters, digits, and underscores" | — |
| 3.4 | **field_error** | onBlur: email invalid | Email подсвечен | "Sign up" enabled | Inline: "Enter a valid email address" | — |
| 3.5 | **field_error** | onBlur: password < 8 | Password подсвечен | "Sign up" enabled | Inline: "Password must be at least 8 characters" | — |
| 3.6 | **submitting** | Tap "Sign up", все поля OK | Disabled | Spinner | Скрыт | — |
| 3.7 | **error_409_email** | Ответ: "email already registered" | Email подсвечен красным | "Sign up" enabled | Inline: "Email already registered" | — |
| 3.8 | **error_409_username** | Ответ: "username already taken" | Username подсвечен | "Sign up" enabled | Inline: "Username already taken" | — |
| 3.9 | **error_400** | Ответ: 400 с detail | Поле по detail подсвечено | "Sign up" enabled | Inline под полем | — |
| 3.10 | **error_500** | 5xx / timeout | Enabled | "Sign up" enabled | ErrorView + Retry | — |
| 3.11 | **error_network** | Нет интернета | Enabled | "Sign up" enabled | Toast: no internet | — |
| 3.12 | **success** | Ответ: 201 | — | — | — | Redirect /home |

### Character counter

| Состояние | Показывать |
|-----------|------------|
| username 0-25 символов | Серый счётчик: "0/30" |
| username 26-30 символов | Жёлтый/оранжевый: "28/30" |
| username 30 символов | Красный: "30/30", поле disabled |
| password 0-7 символов | Красный: "Password must be at least 8 characters" |
| password 8+ символов | Зелёный: "✓ Good password" |

---

## 4. AuthGuard (системный, невидимый экран)

| # | State | condition | Result |
|---|-------|-----------|--------|
| 4.1 | **protected_ok** | AuthState = authenticated, route = /home, /profile, etc. | Показать контент |
| 4.2 | **protected_no_token** | AuthState = unauthenticated, route = /home, /profile, etc. | Redirect → /login |
| 4.3 | **auth_route_logged_in** | AuthState = authenticated, route = /login or /register | Redirect → /home |
| 4.4 | **auth_route_public** | AuthState = unauthenticated, route = /login or /register | Показать форму |
| 4.5 | **loading** | AuthState = loading | Показать спиннер / ничего |

**Тонкость:** при старте приложения AuthState = loading, поэтому AuthGuard
должен ничего не показывать (или спиннер), а не редиректить на /login.
Если guard сработает на loading → пользователь увидит вспышку /login перед
тем как токен найдётся.

---

## 5. ProfileScreen (Logout — часть auth)

| # | State | Trigger | UI |
|---|-------|---------|-----|
| 5.1 | **default** | Screen loaded | Показать профиль + "Log out" button |
| 5.2 | **logging_out** | Tap "Log out" | Подтверждение: "Are you sure?" → Yes/No |
| 5.3 | **logged_out** | Yes confirmed | Redirect → /login (clear stack) |

**Подтверждение выхода:** Alert dialog с двумя кнопками:
- "Cancel" — закрыть диалог, вернуться в default
- "Log out" — clearTokens → /login

---

## 6. Таблица всех состояний (сводная)

| Screen | State count | Loading | Error | Success | Empty | Idle | Field error |
|--------|:-----------:|:-------:|:-----:|:-------:|:-----:|:----:|:-----------:|
| SplashScreen | 5 | ✅ checking | ❌ | ✅ 3 variants | ❌ | ❌ | ❌ |
| LoginScreen | 9 | ✅ submitting | ✅ 4 types | ✅ redirect | ❌ | ✅ idle | ✅ 1 variant |
| RegisterScreen | 12 | ✅ submitting | ✅ 5 types | ✅ redirect | ❌ | ✅ idle | ✅ 4 types |
| AuthGuard | 5 | ✅ loading | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 7. Правила для всех состояний

1. **Loading никогда не блокирует приложение целиком** — только кнопку и поля формы
2. **Ошибки не стирают введённые данные** — пользователь не перепечатывает всё заново
3. **Ошибка 409 показывает, какое поле конфликтует** — email или username
4. **Ошибка 401 не подсвечивает поле** — это ошибка креденшелов, не поля
5. **После успеха — replace navigation** — нельзя вернуться назад к форме
6. **Rate limit (429) — кнопка disabled на N секунд** — показывать таймер
7. **Network error — отличается от server error** — пользователь должен понять: проблема у него или на сервере
8. **Все состояния должны быть реализованы** — если state отсутствует, пользователь увидит белый экран или бесконечный спиннер
