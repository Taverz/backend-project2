# Шаг 4: Верификация

> Единственный честный способ проверить, что AI сделал правильно.
> Тесты и curl — не документы, написанные тем же AI.

---

## 4.1 Unit-тесты

AI пишет тесты для каждого use case:

```go
func TestUploadUseCase_TooLarge(t *testing.T) {
    // file size > 10 MB → ErrFileTooLarge
}

func TestUploadUseCase_InvalidType(t *testing.T) {
    // image/svg+xml → ErrInvalidFileType
}

func TestUploadUseCase_Success(t *testing.T) {
    // valid JPEG → media.Media with correct fields
}

func TestGetMediaUseCase_NotFound(t *testing.T) {
    // non-existent ID → error
}
```

## 4.2 Интеграционный тест

```go
func TestMediaUploadAndRetrieve(t *testing.T) {
    // 1. Register user
    // 2. Upload image via POST /api/v1/media/upload
    // 3. Assert 201 + has id and url
    // 4. GET /api/v1/media/{id}/{filename}
    // 5. Assert 200 + correct Content-Type
}
```

## 4.3 Ручная проверка (curl)

```bash
# 1. Регистрация
TOKEN=$(curl -s -X POST localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"test","email":"t@t.com","password":"12345678"}' \
  | jq -r '.access_token')

# 2. Загрузка
curl -s -X POST localhost:8080/api/v1/media/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test.jpg" | jq .

# 3. Проверка размера
curl -s -X POST localhost:8080/api/v1/media/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@too-large.mp4"  # → 413

# 4. Получение
curl -s localhost:8080/api/v1/media/{id}/test.jpg -o downloaded.jpg
file downloaded.jpg  # → JPEG image data
```

## 4.4 Проверка на соответствие требованиям

| Требование | Проверка |
|-----------|----------|
| Загрузить до 4 изображений | Интеграционный тест с 4 файлами |
| Файл > 10 MB → 413 | curl с большим файлом |
| Неподдерживаемый формат → 400 | curl с .exe файлом |
| URL в ответе твита | Интеграционный тест create tweet + media |
| Неавторизованный доступ к файлу | curl без токена на GET /media/{id} |

---

**Конец шага 4.** Если все тесты зелёные и curl-запросы проходят — фича готова.
Не нужна AI-документация, подтверждающая, что AI всё сделал правильно. Нужны
зелёные тесты и живые HTTP-ответы.
