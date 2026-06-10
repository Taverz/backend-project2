# Шаг 3: Код

> AI генерирует код модуля за модулем на основе SPEC (шаг 2).
> Каждый блок верифицируется сразу: `go build`, `go test`.

---

## Файлы, которые создаются

### 3.1 Domain

**`backend/internal/domain/media/entity.go`**:

```go
package media

import "time"

type Media struct {
    ID          string
    UserID      string
    Filename    string
    ContentType string
    Size        int64
    StorageKey  string
    CreatedAt   time.Time
}

const (
    MaxFileSize      = 10 * 1024 * 1024 // 10 MB
    MaxMediaPerTweet = 4
)

var AllowedTypes = map[string]bool{
    "image/jpeg": true,
    "image/png":  true,
    "image/gif":  true,
    "image/webp": true,
}

var (
    ErrFileTooLarge    = errors.New("file too large: max 10 MB")
    ErrInvalidFileType = errors.New("unsupported file type")
    ErrTooManyMedia    = errors.New("max 4 media per tweet")
)
```

### 3.2 Port

**`backend/internal/port/media.go`**:

```go
package port

import (
    "io"
    "github.com/nikitakovalevtaverz/chirp/internal/domain/media"
)

type MediaRepository interface {
    Save(ctx, userID, filename, contentType string, file io.Reader) (*media.Media, error)
    GetByID(ctx, id string) (*media.Media, error)
    GetFile(ctx, storageKey string) (io.ReadCloser, error)
}
```

### 3.3 UseCase

**`backend/internal/usecase/media/upload.go`**:

```go
func (uc *UploadUseCase) Execute(ctx, userID, filename, contentType string, file io.Reader) (*media.Media, error) {
    // 1. Check size (read first bytes, check Content-Length)
    // 2. Check content type whitelist
    // 3. Generate UUID
    // 4. Save to storage → storageKey
    // 5. Save metadata to DB
    // 6. Return Media
}
```

### 3.4 Adapters

**`backend/internal/adapter/s3/media.go`** — MinIO/S3 adapter
**`backend/internal/adapter/disk/media.go`** — Disk fallback (dev)

### 3.5 Transport

**`backend/internal/transport/media_handler.go`**:

- `POST /api/v1/media/upload` — парсит multipart, вызывает UploadUseCase
- `GET /api/v1/media/{id}/{filename}` — вызывает GetMediaUseCase, стримит файл

### 3.6 App wiring

**`backend/internal/app/app.go`** — добавляются:

```go
mediaRepo := disk.NewMediaRepo("./data/media")  // или s3.NewMediaRepo(...)
uploadUC := media.NewUploadUseCase(mediaRepo, mediaRepo)
mediaHandler := transport.NewMediaHandler(uploadUC, getMediaUC)

r.Post("/media/upload", mediaHandler.Upload)   // 🔒
r.Get("/media/{id}/{filename}", mediaHandler.Get) // 🌐
```

### 3.7 Migrations

```
000007_create_media.up.sql
000008_create_tweet_media.up.sql
```

---

## Как AI это генерирует

По одному файлу за раз, в порядке зависимостей:

```
entity.go → port.go → usecase 
→ adapter (disk) → handler → app.go wiring → migration
```

После каждого файла — `go build`. После всех — `go test ./...`

---

**Конец шага 3.** Вместо "напиши весь проект сразу" — модуль за модулем,
каждый проверяется компиляцией.
