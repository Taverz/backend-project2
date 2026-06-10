# Auth — cross-platform patterns

> Паттерны авторизации для всех платформ. Без конкретного кода.
> AI читает это и генерирует реализацию на языке платформы.

---

## 1. Token storage pattern

**Задача:** Сохранить access + refresh token так, чтобы их не могли украсть.

| Platform | Место хранения | Ключи |
|----------|---------------|-------|
| Flutter | flutter_secure_storage (iOS: Keychain, Android: EncryptedSharedPrefs) | `access_token`, `refresh_token` |
| Android | EncryptedSharedPreferences | `access_token`, `refresh_token` |
| iOS | Keychain (kSecClassGenericPassword) | `com.chirp.access`, `com.chirp.refresh` |
| Web (MVP) | localStorage | `chirp_access`, `chirp_refresh` |
| Web (prod) | httpOnly cookie (Set-Cookie от backend) | `__Host-access`, `__Host-refresh` |

**Контракт:** Три функции, одинаковый интерфейс на всех платформах:

```
saveTokens(access: String, refresh: String) → void
getAccessToken() → String?  // null = нет токена
clearTokens() → void
```

---

## 2. Auth state pattern

**Задача:** Единый источник правды о том, авторизован пользователь или нет.

**Состояние:** sealed enum/class с 3 вариантами:

```
AuthState
├── .unauthenticated  — нет токена, пользователь не вошёл
├── .loading          — проверяем токен / логинимся / регаемся
└── .authenticated(user: User) — есть токен, знаем кто
```

**Где живёт:** 
- Flutter: Riverpod provider
- Android: ViewModel с StateFlow
- iOS: @Observable ViewModel
- Web: React Context

**Правила:**
- При старте приложения: `state = .loading` → проверить SecureStorage → `.authenticated` или `.unauthenticated`
- После успешного login/register: `state = .authenticated(user)`
- После logout: `state = .unauthenticated`
- При неудачном refresh: `state = .unauthenticated`

---

## 3. API client pattern

**Задача:** Все HTTP-запросы проходят через один класс, который добавляет JWT и обрабатывает 401.

**Структура:**

```
ApiClient
├── GET(path, queryParams?) → Response
├── POST(path, body?) → Response
├── DELETE(path) → Response
└── (private) _tryRefresh() → Boolean
    └── POST /auth/refresh {refresh_token}
        ├── 200 → saveTokens(newAccess, newRefresh) → true
        └── error → clearTokens() → false
```

**Логика 401 (псевдокод):**

```
function request(method, path, body?):
    for attempt = 0; attempt < 2; attempt++:
        token = getAccessToken()
        headers = {Authorization: "Bearer {token}", "Content-Type": "application/json"}
        response = http.request(method, path, headers, body)
        
        if response.status != 401:
            return response
        
        // 401 — попробовать refresh
        if not _tryRefresh():
            break  // refresh failed → выйти из цикла → вернуть 401
    
    // После цикла: refresh не удался
    clearTokens()
    navigate(/login)
    throw AuthException
```

**Важно для race condition:** Если 3 запроса получили 401 одновременно, только ОДИН делает refresh, остальные ждут. Реализация:

```
refreshPromise = null  // global

function _tryRefresh():
    if refreshPromise != null:
        // Кто-то уже делает refresh — ждём его
        return await refreshPromise
    
    refreshPromise = actuallyRefresh()  // POST /auth/refresh
    result = await refreshPromise
    refreshPromise = null  // сбросить для следующего раза
    return result
```

---

## 4. Navigation guard pattern

**Задача:** Защищённые экраны (home, profile, notifications) недоступны без токена.

**Реализация (общая логика для всех платформ):**

```
Каждый раз при смене маршрута:
    1. Смотрим authState
    2. Смотрим targetRoute
    3. Если authState == .unauthenticated И targetRoute НЕ (login или register):
         → redirect → /login
    4. Если authState == .authenticated И targetRoute ЭТО (login или register):
         → redirect → /home
    5. Иначе:
         → разрешить навигацию
```

**Где живёт:**
- Flutter: GoRouter.redirect callback
- Android: NavHost + composable guard
- iOS: NavigationStack root + conditional
- Web: React Router `<ProtectedRoute>` wrapper

---

## 5. Form validation pattern

**Задача:** Валидация полей на клиенте ДО отправки на сервер.

**Правила валидации (одинаковые на всех платформах):**

| Поле | Правило | Сообщение об ошибке |
|------|---------|-------------------|
| username | 3-30 chars, a-z, 0-9, _, lowercase | "Username must be 3-30 characters" |
| email | Не пустой, содержит @, валидный домен | "Enter a valid email address" |
| password | 8-72 символа | "Password must be at least 8 characters" |

**Когда валидировать:**
- `onBlur` каждого поля — показать ошибку сразу после того, как пользователь ушёл с поля
- `onSubmit` всей формы — проверить все поля перед отправкой

**Как показывать ошибки:**
- 400 от сервера → парсим detail → показываем inline под соответствующим полем
- 409 → подсвечиваем поле (email/username) + текст ошибки
- 401 → toast/alert над формой (это не ошибка поля, это ошибка креденшелов)

---

## 6. Loading state pattern

**Задача:** Пользователь видит индикатор загрузки, пока запрос в процессе.

**Где:**
- Кнопка "Log in" / "Sign up" → disabled + spinner вместо текста
- Splash screen → логотип + spinner (пока проверяем JWT)
- AuthGuard → ничего не рендерить (или спиннер), пока authState = .loading

**Когда выключать:**
- Пришёл ответ (успех или ошибка) → убрать spinner
- При ошибке — кнопка снова активна, можно повторить

---

## 7. Logout pattern

**Задача:** Очистить всё и вернуться на login.

**Что происходит:**
```
1. clearTokens() — удалить access + refresh из SecureStorage
2. authState = .unauthenticated
3. navigate(/login) — replace, clear весь стек
```

**Где вызывается:**
- Кнопка "Log out" в ProfileScreen
- Автоматически при неудачном refresh

---

## 8. Первый запуск vs повторный

| Сценарий | Что происходит |
|----------|---------------|
| Первый запуск | Нет токенов → Splash (0.5s) → /login |
| Повторный запуск | Токены есть → Splash → проверить /users/me → если 200 → /home |
| Токен протух | Splash → /users/me → 401 → refresh → если ОК → /home, если нет → /login |
| После logout | /login, стек пустой |

---

## 9. Что должно быть на каждой платформе — чеклист

| Компонент | Flutter | Android | iOS | Web |
|-----------|---------|---------|-----|-----|
| AuthService (save/get/clear tokens) | ✅ | ✅ | ✅ | ✅ |
| ApiClient (JWT + 401 → refresh) | ✅ | ✅ | ✅ | ✅ |
| AuthProvider/ViewModel (state machine) | ✅ | ✅ | ✅ | ✅ |
| AuthGuard (redirect если нет токена) | ✅ | ✅ | ✅ | ✅ |
| LoginScreen + form | ✅ | ✅ | ✅ | ✅ |
| RegisterScreen + form | ✅ | ✅ | ✅ | ✅ |
| SplashScreen (проверка токена при старте) | ✅ | ✅ | ✅ | ✅ |
| Logout button | ✅ | ✅ | ✅ | ✅ |
| Inline validation ошибок | ✅ | ✅ | ✅ | ✅ |
| Loading state (spinner в кнопке) | ✅ | ✅ | ✅ | ✅ |
| 401 → refresh → retry (с race condition guard) | ✅ | ✅ | ✅ | ✅ |
| 401 → refresh failed → /login | ✅ | ✅ | ✅ | ✅ |
| Token refresh в фоне, без UI-блокировки | ✅ | ✅ | ✅ | ✅ |
