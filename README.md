

Готово. Система Logs + Traces для AI-сессий.

Что получилось

docs/
├── scripts/
│   ├── save-transcript.sh      ← сохранить transcript + обновить index
│   ├── generate-traces.py      ← JSONL → структурированные трассы
│   └── replay.sh               ← воспроизвести контекст
└── transcripts/
    └── index.json              ← индекс сессий

save-transcript.sh

./docs/scripts/save-transcript.sh 25468bf4 /tmp/transcript.jsonl --traces

Делает:
- Копирует JSONL → docs/transcripts/25468bf4.jsonl
- Создаёт docs/transcripts/25468bf4.meta.json
- Обновляет docs/transcripts/index.json
- При  --traces генерирует 25468bf4.traces.json со спанами

replay.sh

./docs/scripts/replay.sh 25468bf4            # вся сессия
./docs/scripts/replay.sh 25468bf4 --turn 5   # до 5-го хода

Выводит читаемый промт, готовый к копированию в новую сессию CodeWhale.

Traces (пример)

{
  "trace_id": "25468bf4",
  "spans": [{
    "id": "turn-5",
    "name": "user: создать follow модуль",
    "children": [
      {"name": "thinking", "chars": 450},
      {"name": "write_file", "input_preview": "{...}"},
      {"name": "tool_call", "name": "shell"},
      {"name": "assistant_response", "text_preview": "..."}
    ]
  }]
}

Процесс при «запиши в лог»

1. RLM: session://active/transcript → получаю JSONL
2. save-transcript.sh <session_id> <jsonl> --traces
3. Собираю метрики → AI-LOG.md
4. Сохраняю метрики → docs/metrics/

---

## Карта документации проекта

Вся документация для восстановления/переписывания проекта на любом стеке:

### Архитектура и проектирование

| Файл | Строк | Что даёт |
|------|-------|----------|
| [`SOUL.md`](SOUL.md) | 369 | Единый источник правды: архитектурные решения, стек, доменные модули, API surface, потоки данных, план развития, техдолг |
| [`backend/DESIGN.md`](backend/DESIGN.md) | 524 | Clean architecture, структура директорий, ответственность каждого модуля, sequence-диаграммы, инварианты |
| [`backend/DESIGN-API.md`](backend/DESIGN-API.md) | 974 | Полная спецификация API: все эндпоинты с request/response, ошибки, пагинация, событийная модель, схемы БД, use case шаги |

### API и потоки данных

| Файл | Что описывает |
|------|---------------|
| [`backend/docs/flows/registration.md`](backend/docs/flows/registration.md) | Регистрация: валидация → bcrypt → JWT |
| [`backend/docs/flows/create-tweet.md`](backend/docs/flows/create-tweet.md) | Создание твита: валидация → save → fan-out → search index |
| [`backend/docs/flows/follow.md`](backend/docs/flows/follow.md) | Подписка/отписка |
| [`backend/docs/flows/like.md`](backend/docs/flows/like.md) | Лайк/анлайк с нотификацией |
| [`backend/docs/flows/timeline.md`](backend/docs/flows/timeline.md) | Чтение домашней ленты |
| [`backend/docs/flows/search.md`](backend/docs/flows/search.md) | Полнотекстовый поиск |

### База данных (PostgreSQL)

| Миграция | Описание | DDL |
|----------|----------|-----|
| `000001_create_users` | Пользователи | ✅ |
| `000002_create_tweets` | Твиты | ✅ |
| `000003_create_follows` | Подписки (composite PK) | ✅ новая |
| `000004_create_likes` | Лайки (composite PK) | ✅ новая |
| `000005_create_timeline` | Лента (fan-out, PK recipient+tweet) | ✅ новая |
| `000006_create_notifications` | Уведомления с CHECK type | ✅ новая |

### JWT

| Файл | Описание |
|------|----------|
| [`backend/docs/jwt-spec.md`](backend/docs/jwt-spec.md) | Полный payload access/refresh, валидация, refresh flow, псевдокод |

### Инфраструктура (AI-сессии)

| Файл | Описание |
|------|----------|
| [`docs/AI-LOG.md`](docs/AI-LOG.md) | Лог AI-сессий: задачи, метрики, ошибки |
| [`docs/transcripts/`](docs/transcripts/) | Сырые JSONL-транскрипты с мета-информацией |
| [`docs/metrics/`](docs/metrics/) | Метрики по сессиям |
| [`docs/scripts/save-transcript.sh`](docs/scripts/save-transcript.sh) | Сохранение транскрипта |
| [`docs/scripts/replay.sh`](docs/scripts/replay.sh) | Воспроизведение сессии |
| [`docs/scripts/generate-traces.py`](docs/scripts/generate-traces.py) | Генерация трасс из JSONL |

### Flutter

| Файл | Описание |
|------|----------|
| [`docs/flutter/STRUCTURE.md`](docs/flutter/STRUCTURE.md) | Полная структура Flutter-проекта: auth, состояния, пагинация, формы |

### Web (TypeScript / React)

| Файл | Описание |
|------|----------|
| [`docs/web/STRUCTURE.md`](docs/web/STRUCTURE.md) | Структура Web-фронтенда: React + TypeScript + Vite + Tailwind |

### Flow фич (cross-platform: backend + все клиенты)

| Файл | Описание |
|------|----------|
| [`docs/shared/auth-flow/FLOW-README.md`](docs/shared/auth-flow/FLOW-README.md) | Auth: бизнес-требования → SPEC → код на 5 платформах → верификация |
| [`docs/shared/auth-flow/01-REQUIREMENTS.md`](docs/shared/auth-flow/01-REQUIREMENTS.md) | Шаг 1: 6 требований, 10 acceptance criteria |
| [`docs/shared/auth-flow/02-SPEC.md`](docs/shared/auth-flow/02-SPEC.md) | Шаг 2: API контракт (для всех платформ) |
| [`docs/shared/auth-flow/03-ARCHITECTURE.md`](docs/shared/auth-flow/03-ARCHITECTURE.md) | Шаг 3: sequence диаграммы, data/screen/model structure, state machine |
| [`docs/shared/auth-flow/04-PATTERNS.md`](docs/shared/auth-flow/04-PATTERNS.md) | Шаг 4: платформенные паттерны (для AI, без кода) |
| [`docs/shared/auth-flow/05-VERIFICATION.md`](docs/shared/auth-flow/05-VERIFICATION.md) | Шаг 5: тесты + curl + таблица сценариев |

### Frontend (Flutter)

| Файл | Описание |
|------|----------|
| [`docs/examples/frontend/FLUTTER.md`](docs/examples/frontend/FLUTTER.md) | Полная карта Flutter-фронтенда: экраны, маршруты, структура, API-слой, модели, состояние, тема |

### Flow разработки с AI

| Файл | Описание |
|------|----------|
| [`docs/examples/media-upload/FLOW-README.md`](docs/examples/media-upload/FLOW-README.md) | Описание flow: бизнес-требования → SPEC → код → верификация |
| [`docs/examples/media-upload/01-REQUIREMENTS.md`](docs/examples/media-upload/01-REQUIREMENTS.md) | Шаг 1: требования (пишет человек, 3–10 строк) |
| [`docs/examples/media-upload/02-SPEC.md`](docs/examples/media-upload/02-SPEC.md) | Шаг 2: AI генерирует техзадание из требований |
| [`docs/examples/media-upload/03-CODE.md`](docs/examples/media-upload/03-CODE.md) | Шаг 3: AI пишет код модулями, каждый проверяется |
| [`docs/examples/media-upload/04-VERIFICATION.md`](docs/examples/media-upload/04-VERIFICATION.md) | Шаг 4: тесты и curl — единственная честная верификация |

### Shared Docs (for all platforms)

| Файл | Описание |
|------|----------|
| [`docs/shared/SOUL.md`](docs/shared/SOUL.md) | Идентичность, архитектурные решения, список платформ |
| [`docs/shared/API.md`](docs/shared/API.md) | Контракт backend↔клиенты: все эндпоинты, request/response |
| [`docs/shared/FEATURES.md`](docs/shared/FEATURES.md) | Каждая фича + acceptance criteria |
| [`docs/shared/SCREENS.md`](docs/shared/SCREENS.md) | Экранная карта, состояния (loading/empty/error/data) |
| [`docs/shared/DESIGN-SYSTEM.md`](docs/shared/DESIGN-SYSTEM.md) | Цвета, шрифты, компоненты, иконки |
| [`docs/shared/ERRORS.md`](docs/shared/ERRORS.md) | Все ошибки и реакция клиента |
| [`docs/shared/DESIGN-CONTRACT.md`](docs/shared/DESIGN-CONTRACT.md) | Контракт между Figma и кодом: naming, экспорт, состояния |

### Multi-Platform

| Файл | Описание |
|------|----------|
| [`docs/MULTI-PLATFORM.md`](docs/MULTI-PLATFORM.md) | Как организовать документацию для проекта на N платформ: shared vs platform-specific, какие файлы обязательны |

### Прочее

| Файл | Описание |
|------|----------|
| [`backend/docs/swagger.json`](backend/docs/swagger.json) | OpenAPI 2.0 спецификация |
| [`backend/docs/swagger.yaml`](backend/docs/swagger.yaml) | YAML-версия Swagger |
| [`backend/docs/config.md`](backend/docs/config.md) | Переменные окружения |
| [`backend/Makefile`](backend/Makefile) | Сборка, тесты, миграции, swagger |

### Итого

**15+ документов**, общий объём **~2 300 строк**. Для переписывания на любом языке достаточно — вся бизнес-логика, схема данных, API и потоки расписаны до уровня шагов.