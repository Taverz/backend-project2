# Auth — cross-platform спецификация

---

## 1. API

### POST /api/v1/auth/register

```
🌐 public
Content-Type: application/json
```

**Request:**
```json
{"username": "alice", "email": "alice@example.com", "password": "secret123"}
```

| Field | Constraints |
|-------|-------------|
| username | 3-30 chars, a-z, 0-9, _, lowercase |
| email | Valid email, trim + lowercase |
| password | 8-72 chars |

**Response 201:**
```json
{
  "user": {"id": "uuid", "username": "alice", "email": "...", "display_name": "", "bio": "", "created_at": "..."},
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:** 400 (validation), 409 (email/username taken)

### POST /api/v1/auth/login

```
🌐 public
```

**Request:**
```json
{"email": "alice@example.com", "password": "secret123"}
```

**Response 200:** Same body as register.

**Errors:** 400 (validation), 401 (invalid email or password)

---

## 2. Token format

| Token | Payload | Lifetime |
|-------|---------|----------|
| Access | `{sub: userID, iat, exp}` | 15 min |
| Refresh | `{sub: userID, iat, exp}` | 7 days |

Algorithm: HS256. Secret: random 32-byte hex from env `JWT_SECRET`.

---

## 3. Platform-specific: хранение токенов

| Platform | Storage | Method |
|----------|---------|--------|
| Flutter | flutter_secure_storage | Keychain (iOS) / EncryptedSharedPrefs (Android) |
| Android | EncryptedSharedPreferences | AndroidX Security |
| iOS | Keychain | SecItemAdd / SecItemCopyMatching |
| Web | httpOnly cookie | Backend sets cookie, or localStorage + interceptor |

---

## 4. Platform-specific: Auth guard

Каждая платформа перехватывает 401 и пытается refresh:

```
1. Request → 401 Unauthorized
2. Interceptor: есть refresh token?
     Нет → redirect /login
     Да → POST /auth/refresh {refresh_token}
           ОК → save new tokens → retry original request
           Ошибка → clear tokens → redirect /login
```

---

## 5. JWT Payload (см. backend/docs/jwt-spec.md)

```json
{
  "sub": "uuid (user_id)",
  "exp": 1750000000,
  "iat": 1749999100
}
```

---

## 6. Формы на клиентах

### Login form

| Field | Type | Validation |
|-------|------|------------|
| email | Email keyboard | Valid email format |
| password | Obscured | Not empty |

### Register form

| Field | Type | Validation |
|-------|------|------------|
| username | Text | 3-30 chars, a-z, 0-9, _ |
| email | Email keyboard | Valid email format |
| password | Obscured | 8+ chars, show strength indicator |

**Submit:** button disabled while loading. Show spinner.
**Error:** inline under fields (400), toast/alert (500).
**Success:** redirect to /home.
