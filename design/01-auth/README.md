# Auth Feature — Design Spec

> Фича: регистрация и вход пользователя.
> 3 экрана: Splash, Login, Register.

---

## Screen: SplashScreen

**Route:** `/`
**Purpose:** Проверить JWT при запуске, перенаправить на /home или /login

### Layout (сверху вниз)

```
┌──────────────────────┐
│                      │
│                      │
│                      │
│       🐦 Chirp       │  ← h1 (24px), white
│                      │
│      ○ loading       │  ← CircularProgressIndicator, primary color
│                      │
│                      │
│                      │
└──────────────────────┘
```

### States

| State | Visual | Duration |
|-------|--------|----------|
| checking | Logo + спиннер | Пока notoken → /login, has token → /home |

### Figma frames

| Frame name | Content |
|-----------|---------|
| `Splash/Checking` | Logo + spinner, dark bg |

---

## Screen: LoginScreen

**Route:** `/login`
**Device:** Mobile (bottom sheet / full screen)

### Layout

```
┌──────────────────────────────────────┐
│                                      │
│           Welcome to Chirp           │  ← h1, centered, margin-bottom: 32px
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Email                         │  │  ← InputField, height: 44px
│  └────────────────────────────────┘  │     placeholder: "Email"
│                                      │     margin-bottom: 16px
│  ┌────────────────────────────────┐  │
│  │  Password                  👁  │  │  ← InputField + eye icon
│  └────────────────────────────────┘  │     obscured, margin-bottom: 24px
│                                      │
│  ┌────────────────────────────────┐  │
│  │          Log in                │  │  ← PrimaryButton, full-width
│  └────────────────────────────────┘  │     height: 44px, radius: 24px
│                                      │     margin-bottom: 16px
│                                      │
│    Don't have an account? Sign up    │  ← caption + link, centered
│                                      │
└──────────────────────────────────────┘
```

### States (отдельными фреймами)

| State | Name | Visual changes |
|-------|------|---------------|
| Default | `Login/Default` | Пустые поля, кнопка disabled (opacity 0.5) |
| Filled | `Login/Filled` | Email + Password заполнены, кнопка enabled |
| Error (401) | `Login/Error401` | Toast сверху: "Invalid email or password" |
| Error (field) | `Login/FieldError` | Email border=#E0245E, inline: "Enter a valid email address" |
| Loading | `Login/Loading` | Кнопка: spinner, поля disabled |
| Error (network) | `Login/NetworkError` | Toast: "No internet connection" |
| Rate limited | `Login/RateLimited` | Toast: "Too many attempts. Try again in 30s" |
| Success | `Login/Success` | — (redirect) |

### Error messages

| Error | Message | Where |
|-------|---------|-------|
| Invalid email | "Enter a valid email address" | Inline под полем email |
| Wrong password | "Invalid email or password" | Toast сверху |
| Server error | "Something went wrong" | Full screen ErrorView + Retry |
| Network | "No internet connection. Check your network." | Toast |
| Rate limit | "Too many attempts. Try again in 30 seconds." | Toast |

### InputField validation timing

- onBlur: проверить email format → если ошибка → показать inline
- onSubmit: проверить оба поля → если ошибка → показать inline, не отправлять

---

## Screen: RegisterScreen

**Route:** `/register`

### Layout

```
┌──────────────────────────────────────┐
│                                      │
│         Create your account          │  ← h1, centered
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Username              0/30   │  │  ← InputField + counter
│  └────────────────────────────────┘  │     placeholder: "Username"
│                                      │     margin-bottom: 16px
│  ┌────────────────────────────────┐  │
│  │  Email                         │  │  ← InputField
│  └────────────────────────────────┘  │     margin-bottom: 16px
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Password                      │  │  ← InputField, obscured
│  └────────────────────────────────┘  │     margin-bottom: 24px
│                                      │
│  ┌────────────────────────────────┐  │
│  │         Sign up                │  │  ← PrimaryButton, full-width
│  └────────────────────────────────┘  │
│                                      │
│    Already have an account? Log in   │
│                                      │
└──────────────────────────────────────┘
```

### States

| State | Name | Visual |
|-------|------|--------|
| Default | `Register/Default` | Пустые поля, кнопка disabled |
| Filled | `Register/Filled` | Все поля заполнены, кнопка enabled |
| Error (username) | `Register/ErrorUsername` | Username border=#E0245E, inline error |
| Error (email) | `Register/ErrorEmail` | Email border=#E0245E, inline error |
| Error (password) | `Register/ErrorPassword` | Password border=#E0245E, inline error |
| Conflict (email) | `Register/ConflictEmail` | Email border=#E0245E, "Email already registered" |
| Conflict (username) | `Register/ConflictUsername` | Username border=#E0245E, "Username already taken" |
| Loading | `Register/Loading` | Кнопка spinner, поля disabled |
| Error (network) | `Register/NetworkError` | Toast: "No internet" |
| Success | `Register/Success` | — (redirect) |

### Character counter

| Length | Counter color |
|--------|-------------|
| 0-25 | Grey (#71767B) |
| 26-30 | Yellow (#FFAD1F) |
| =30 | Red (#E0245E), stop input |

### Validation rules

| Field | Rule | Error message |
|-------|------|---------------|
| Username | 3-30 chars, a-z, 0-9, _ | "Username must be 3-30 characters" |
| Email | Valid format | "Enter a valid email address" |
| Password | 8+ chars | "Password must be at least 8 characters" |
