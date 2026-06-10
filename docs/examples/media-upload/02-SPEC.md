# Шаг 2: Техническая спецификация

> Сгенерировано AI из бизнес-требований (шаг 1).
> Человек проверяет и правит — это **code review на уровне архитектуры**,
> а не на уровне синтаксиса.

---

## 1. Новые эндпоинты

### POST /api/v1/media/upload

Загрузка одного файла. Multipart/form-data.

```
🔒 requires JWT
Content-Type: multipart/form-data
```

**Request:**

| Поле | Тип | Ограничения |
|------|-----|------------|
| file | file | ≤10 MB, JPEG/PNG/GIF/WebP |

**Response 201:**

```json
{
  "id": "uuid",
  "url": "/api/v1/media/uuid/filename.jpg",
  "content_type": "image/jpeg",
  "size": 1048576,
  "created_at": "2025-06-10T12:00:00Z"
}
```

### GET /api/v1/media/{id}/{filename}

Отдача файла.

```
🌐 public
```

**Response 200:** файл с `Content-Type` и `Cache-Control: public, max-age=31536000`.

### POST /api/v1/tweets (изменён)

В теле добавляется опциональное поле `media_ids: ["uuid", "uuid"]` (макс 4).

## 2. Доменная модель

```go
package media

type Media struct {
    ID          string
    UserID      string
    Filename    string
    ContentType string
    Size        int64
    StorageKey  string // ключ в S3/MinIO
    CreatedAt   time.Time
}
```

**Value Objects:**

- `MaxFileSize = 10 MB` — константа
- `AllowedTypes = {"image/jpeg", "image/png", "image/gif", "image/webp"}` — белый список
- `MaxMediaPerTweet = 4`

**Ошибки:**

| Ошибка | Когда |
|--------|-------|
| ErrFileTooLarge | Размер > 10 MB |
| ErrInvalidFileType | Неподдерживаемый формат |
| ErrTooManyMedia | > 4 файлов на твит |

## 3. Порты (интерфейсы)

```go
package port

type MediaRepository interface {
    Save(ctx, userID string, file io.Reader, filename, contentType string) (*media.Media, error)
    GetByID(ctx, id string) (*media.Media, error)
    GetFile(ctx, storageKey string) (io.ReadCloser, error)
}
```

## 4. Use Case'ы

### UploadMediaUseCase

```
1. Проверить размер (≤ 10 MB)
2. Проверить Content-Type (белый список)
3. Сгенерировать UUID
4. Сохранить файл в S3/MinIO → storageKey
5. Сохранить метаданные в БД
6. Вернуть MediaResponse
```

### GetMediaUseCase

```
1. MediaRepo.GetByID(id) → метаданные
2. MediaRepo.GetFile(storageKey) → поток
3. Вернуть файл + Content-Type
```

## 5. Хранилище

### S3Adapter (production)

- MinIO (dev) / AWS S3 (prod) / Cloudflare R2
- Bucket: `chirp-media`
- Ключ: `{userID}/{mediaID}/{filename}`
- URL: signed или прямой (через прокси)

### DiskAdapter (dev fallback)

- Директория: `./data/media/{userID}/{mediaID}/{filename}`
- Авто-создание при первом сохранении

## 6. Изменения в Tweet

Поле `media_ids []string` добавляется в:
- `domain/tweet/entity.go` — новое поле
- `POST /tweets` — валидация ≤ 4, привязка к твиту
- `TweetResponse` — URLs в ответе

## 7. Схема БД

Новая таблица:

```sql
CREATE TABLE media (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename     VARCHAR(255) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    size         BIGINT NOT NULL,
    storage_key  TEXT NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tweet_media (
    tweet_id UUID NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    PRIMARY KEY (tweet_id, media_id)
);
```

---

**Конец шага 2.** AI сгенерировал спецификацию из 3 строк требований.
Человек тратит 5 минут на проверку: убрать лишнее, добавить забытое, поправить naming.
После утверждения — переходим к коду.
