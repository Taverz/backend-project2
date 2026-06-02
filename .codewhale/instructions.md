# Chirp Backend — AI Instructions

> This file guides CodeWhale / DeepSeek when working in this project.
> Keep it updated as architecture evolves.

## Project Identity

- **Name:** Chirp — Twitter-клон
- **Stack:** Go 1.23+, Chi router, PostgreSQL, Redis, Kafka, Elasticsearch, MinIO
- **Architecture:** Модульный монолит с портами и адаптерами (clean architecture)
- **Frontend:** Flutter (в отдельной директории, позже)

## Directory Conventions

```
backend/
├── cmd/server/main.go         # Точка входа, graceful shutdown
├── internal/
│   ├── app/app.go             # Bootstrap, DI, роутинг
│   ├── config/config.go       # Конфигурация из env
│   ├── domain/<module>/       # Сущности (чистый Go, без зависимостей)
│   ├── usecase/<module>/      # Бизнес-логика (зависит от port, не от adapter)
│   ├── port/                  # Интерфейсы (репозитории, сервисы)
│   ├── adapter/<tech>/        # Реализации портов (postgres, redis, kafka, es)
│   └── transport/             # HTTP-хендлеры + middleware
├── pkg/                       # Утилиты без бизнес-логики
├── migrations/                # SQL-миграции (golang-migrate)
└── go.mod
```

## Module Template

При создании нового доменного модуля (например, `notification`):

1. `internal/domain/notification/entity.go` — сущности
2. `internal/domain/notification/errors.go` — доменные ошибки
3. `internal/port/notification.go` — интерфейсы (NotificationRepository)
4. `internal/usecase/notification/` — usecase-ы (Create, MarkRead, List)
5. `internal/adapter/postgres/notification_repo.go` — реализация
6. `internal/transport/notification_handler.go` — HTTP-хендлеры

## Coding Rules

### Dependency Direction
```
transport → usecase → port ← adapter
               ↓
            domain
```
- `domain` не импортирует ничего из проекта
- `usecase` импортирует `domain` и `port` (интерфейсы)
- `adapter` импортирует `port` и `domain`
- `transport` импортирует `usecase` и `domain`
- Никаких циклических импортов

### Error Handling
- Доменные ошибки — типизированные (sentinel errors + кастомные типы)
- usecase возвращает ошибку, transport маппит в HTTP-статус
- Не использовать `panic` в бизнес-логике
- Все ошибки логируются через `slog`

### Testing
- Unit-тесты: мокаем порты (ручные моки или testify/mock)
- Integration-тесты: testcontainers-go для PostgreSQL, Redis
- Именование: `TestUsecase_Method_Scenario`
- Паттерн AAA (Arrange, Act, Assert)

### Конфигурация
- Только через переменные окружения
- Никаких YAML/JSON/TOML конфигов
- Дефолты в `config.go`
- Секреты никогда не коммитить

### HTTP
- Все хендлеры возвращают JSON
- Ошибки — RFC 7807 Problem Details
- Пагинация — cursor-based
- Валидация в transport-слое до вызова usecase

## Key Commands (Makefile)

```bash
make run           # Запуск dev-сервера
make test          # Все тесты с race detector
make lint          # golangci-lint
make tidy          # go mod tidy
make build         # Сборка бинарника
make migrate-up    # Применить миграции
make migrate-down  # Откатить миграцию
```

## Phase Tracking

Текущая фаза: **1 — Ядро**. Реализуем:
- [x] Структура проекта
- [x] Hello world HTTP
- [ ] User + Auth модули (регистрация, логин, JWT)
- [ ] Tweet CRUD
- [ ] PostgreSQL + Redis адаптеры

Следующая фаза: **2 — Социальные механики** (timeline, лайки, подписки).

## Language

- Код, комментарии, логи — на английском
- Общение с пользователем — на русском (если пользователь пишет по-русски)
- Документация — на русском

## Do / Don't

| Do | Don't |
|----|-------|
| Минимум зависимостей (stdlib + chi + pgx) | Не тащить фреймворки (gin, echo, fiber) |
| Интерфейсы маленькие (1-3 метода) | Не делать God-интерфейсы |
| Каждый модуль — отдельная папка | Не смешивать домены в одном файле |
| Кодогенерация sqlc для SQL | Не писать сырые SQL-строки в коде |
| Graceful shutdown всегда | Не убивать процесс без Shutdown |

## Session Hygiene

### End of session
Когда пользователь явно завершает сессию или говорит «запиши в лог»:

1. **Собрать метрики** из `session://active/transcript` через RLM:
   - `total_messages`, `assistant_messages`, `tool_calls_total`, `tool_errors`
   - `thinking_chars_total`, `thinking_chars_avg`
   - `write_ops`, `read_ops`, `shell_ops`, `no_tool_assistant_turns`

2. **Записать в `docs/AI-LOG.md`**: задача, метрики, созданные файлы, ошибки, acceptance rate

3. **Сохранить сырые метрики** в `docs/metrics/YYYY-MM-DD_session-ID.json`

4. **Оценить стоимость**: ~133K токенов ≈ $0.30-0.50 за среднюю сессию

### Self-correction
- При обнаружении бага в собственном коде — исправить немедленно, записать в лог ошибок
- При tool-ошибке — не повторять идентичный вызов, изменить параметры
- Не скрывать свои ошибки от пользователя
