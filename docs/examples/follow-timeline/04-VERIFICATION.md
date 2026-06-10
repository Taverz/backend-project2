# Follow + Timeline — верификация

> Единственный честный способ проверить: тесты и curl.
> Не документы, написанные тем же AI.

---

## 4.1 Unit-тесты

AI пишет тесты на каждый use case изолированно (с mock-репозиторием):

```go
func TestFollowUseCase_SelfFollow(t *testing.T) {
    // followerID == followeeID → ErrCannotFollowSelf
}

func TestFollowUseCase_UserNotFound(t *testing.T) {
    // followee не существует → error
}

func TestFollowUseCase_Success(t *testing.T) {
    // корректный follow → nil
}

func TestUnfollowUseCase(t *testing.T) {
    // unfollow → nil (даже если не подписан)
}

func TestFanOutUseCase(t *testing.T) {
    // author имеет 3 подписчиков
    // FanOut(tweetID, authorID) → 3 AddEntry вызвано
}

func TestGetHomeTimeline_Pagination(t *testing.T) {
    // 30 entries → limit=20 → first page = 20, has_more = true
    // cursor=последний → second page = 10, has_more = false
}
```

## 4.2 Интеграционный тест

```go
func TestFollowAndTimelineIntegration(t *testing.T) {
    // 1. Register Alice, Bob, Charlie
    // 2. Alice follows Bob
    // 3. Alice follows Charlie
    // 4. Bob creates a tweet
    // 5. Alice's timeline has Bob's tweet
    // 6. Alice unfollows Bob
    // 7. Alice's timeline no longer has Bob's tweet (после нового твита)
}
```

## 4.3 Ручная проверка (curl)

```bash
# 1. Регистрация двух пользователей
ALICE=$(curl -s -X POST localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"alice","email":"a@t.com","password":"12345678"}')
A_TOKEN=$(echo $ALICE | jq -r '.access_token')
A_ID=$(echo $ALICE | jq -r '.user.id')

BOB=$(curl -s -X POST localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"bob","email":"b@t.com","password":"12345678"}')
B_TOKEN=$(echo $BOB | jq -r '.access_token')
B_ID=$(echo $BOB | jq -r '.user.id')

# 2. Alice подписывается на Bob
curl -s -o /dev/null -w "%{http_code}" \
  -X POST "localhost:8080/api/v1/users/$B_ID/follow" \
  -H "Authorization: Bearer $A_TOKEN"
# → 204

# 3. Alice пытается подписаться на себя
curl -s -o /dev/null -w "%{http_code}" \
  -X POST "localhost:8080/api/v1/users/$A_ID/follow" \
  -H "Authorization: Bearer $A_TOKEN"
# → 400 "cannot follow yourself"

# 4. Bob создаёт твит
TWEET=$(curl -s -X POST localhost:8080/api/v1/tweets \
  -H "Authorization: Bearer $B_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"body":"hello from Bob"}')
T_ID=$(echo $TWEET | jq -r '.id')

# 5. Alice проверяет ленту — твит Bob должен быть там
curl -s localhost:8080/api/v1/timeline/home \
  -H "Authorization: Bearer $A_TOKEN" | jq '.data[0].tweet_id'
# → "$T_ID"

# 6. Список подписчиков Bob
curl -s "localhost:8080/api/v1/users/$B_ID/followers" | jq '.total'
# → 1

# 7. Alice отписывается
curl -s -o /dev/null -w "%{http_code}" \
  -X DELETE "localhost:8080/api/v1/users/$B_ID/follow" \
  -H "Authorization: Bearer $A_TOKEN"
# → 204
```

## 4.4 Проверка на соответствие требованиям

| Требование | Проверка | Статус |
|-----------|----------|--------|
| Подписаться → 204 | curl POST → 204 | ✅ |
| Отписаться → 204 | curl DELETE → 204 | ✅ |
| Подписка на себя → 400 | curl POST /users/{self}/follow → 400 | ✅ |
| Список подписчиков | curl GET /users/{id}/followers → data + total | ✅ |
| Список подписок | curl GET /users/{id}/following → data + total | ✅ |
| Твит автора в ленте подписчика | После создания твита → GET /timeline/home содержит его | ✅ |
| Пагинация ленты | limit=5 с 20 твитами → 4 страницы, has_more чередуется | ✅ |

---

**Конец шага 4.** Зелёные тесты + живые HTTP-ответы = фича работает.
Никаких "AI, подтверди, что ты всё правильно сделал".
