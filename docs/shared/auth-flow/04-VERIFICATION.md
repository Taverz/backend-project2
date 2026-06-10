# Auth — верификация

---

## 1. Backend тесты

```go
func TestRegister_Success(t *testing.T) {
    // POST /auth/register → 201 + user + tokens
}

func TestRegister_DuplicateEmail(t *testing.T) {
    // register same email twice → 409
}

func TestRegister_UsernameTaken(t *testing.T) {
    // register same username twice → 409
}

func TestRegister_Validation(t *testing.T) {
    // empty username → 400, short password → 400, invalid email → 400
}

func TestLogin_Success(t *testing.T) {
    // register → login with same creds → 200 + new tokens
}

func TestLogin_WrongPassword(t *testing.T) {
    // register → login with wrong password → 401
}

func TestAuthGuard_MissingToken(t *testing.T) {
    // GET /timeline/home without Authorization → 401
}

func TestAuthGuard_InvalidToken(t *testing.T) {
    // GET /timeline/home with fake token → 401
}
```

---

## 2. Интеграционный тест (все платформы)

```go
func TestAuthFlow(t *testing.T) {
    // 1. Register → save access_token
    // 2. GET /users/me (🔒) with token → 200
    // 3. GET /users/me without token → 401
    // 4. GET /users/me with expired token → 401
    // 5. Login with same creds → new tokens
}
```

---

## 3. Ручная проверка (curl)

```bash
# Register
RESP=$(curl -s -X POST localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"alice","email":"alice@test.com","password":"12345678"}')
echo $RESP | jq '.user.username'  # → "alice"
A_TOKEN=$(echo $RESP | jq -r '.access_token')
R_TOKEN=$(echo $RESP | jq -r '.refresh_token')

# Access protected endpoint
curl -s localhost:8080/api/v1/users/me \
  -H "Authorization: Bearer $A_TOKEN" | jq '.username'
# → "alice"

# No token → 401
curl -s -o /dev/null -w "%{http_code}" localhost:8080/api/v1/users/me
# → 401

# Wrong password → 401
curl -s -o /dev/null -w "%{http_code}" \
  -X POST localhost:8080/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"alice@test.com","password":"wrong"}'
# → 401

# Duplicate email → 409
curl -s -o /dev/null -w "%{http_code}" \
  -X POST localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"bob","email":"alice@test.com","password":"12345678"}'
# → 409
```

---

## 4. Фронтенд проверка

| Сценарий | Flutter | Android | iOS | Web |
|----------|---------|---------|-----|-----|
| Открыть приложение без токена → /login | ✅ | ✅ | ✅ | ✅ |
| Register → /home | ✅ | ✅ | ✅ | ✅ |
| Login → /home | ✅ | ✅ | ✅ | ✅ |
| Неверный пароль → ошибка на форме | ✅ | ✅ | ✅ | ✅ |
| Закрыть приложение → открыть → уже /home (токен жив) | ✅ | ✅ | ✅ | ✅ |
| При 401 → refresh → retry | ✅ | ✅ | ✅ | ✅ |
| При неудачном refresh → logout | ✅ | ✅ | ✅ | ✅ |
| Logout → /login | ✅ | ✅ | ✅ | ✅ |
