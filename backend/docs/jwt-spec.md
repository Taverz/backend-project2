# JWT Specification

> Формат и валидация JWT-токенов в Chirp.

---

## 1. Алгоритм

| Параметр | Значение |
|----------|----------|
| Algorithm | HS256 (HMAC-SHA256) |
| Secret | Случайная строка из env `JWT_SECRET` (минимум 32 байта) |
| Header | `{"alg": "HS256", "typ": "JWT"}` |

## 2. Access Token

Живёт **15 минут**. Используется в каждом запросе: `Authorization: Bearer <token>`.

### Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1750000000,
  "iat": 1749999100,
  "type": "access"
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| `sub` | string (UUID) | ID пользователя. По нему сервер идентифицирует запрос |
| `exp` | number (unix) | Expiration time. Сервер проверяет: `exp > now()` |
| `iat` | number (unix) | Issued at. Когда токен выпущен |
| `type` | string | Всегда `"access"` |

### Валидация

```
1. Проверить подпись (HS256, JWT_SECRET)
2. Проверить срок: exp > current_timestamp
3. Проверить тип: type == "access"
4. Извлечь sub → userID
```

## 3. Refresh Token

Живёт **7 дней**. Используется только для получения новой пары токенов.

### Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1750600000,
  "iat": 1749999100,
  "type": "refresh"
}
```

| Поле | Тип | Описание |
|------|-----|----------|
| `sub` | string (UUID) | ID пользователя |
| `exp` | number (unix) | 7 дней от выпуска |
| `iat` | number (unix) | Когда выпущен |
| `type` | string | Всегда `"refresh"` |

### Refresh Flow

```
POST /auth/refresh
  Body: { "refresh_token": "jwt..." }

  Сервер:
  1. Валидирует refresh token (подпись, срок, тип)
  2. Извлекает sub → userID
  3. Проверяет, что пользователь существует
  4. Выпускает новую пару { access_token, refresh_token }
```

## 4. Response Format

При регистрации и логине:

```json
{
  "user": { "...полный UserResponse..." },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 5. Ошибки

| HTTP | Detail | Когда |
|------|--------|-------|
| 401 | missing authorization header | Нет заголовка |
| 401 | invalid or expired token | Невалидная подпись или просрочен |
| 401 | invalid token type | access используется как refresh или наоборот |

---

## 6. Реализация (пример на любом языке)

```python
# Псевдокод — логика одинакова для всех языков
import jwt, time

SECRET = os.environ["JWT_SECRET"]

def issue_token_pair(user_id: str) -> dict:
    now = int(time.time())
    return {
        "access_token": jwt.encode({
            "sub": user_id, "exp": now + 900,   # 15 min
            "iat": now, "type": "access"
        }, SECRET, algorithm="HS256"),
        "refresh_token": jwt.encode({
            "sub": user_id, "exp": now + 604800, # 7 days
            "iat": now, "type": "refresh"
        }, SECRET, algorithm="HS256"),
    }

def validate_access_token(token: str) -> str:
    payload = jwt.decode(token, SECRET, algorithms=["HS256"])
    assert payload["type"] == "access", "invalid token type"
    return payload["sub"]  # user_id
```
