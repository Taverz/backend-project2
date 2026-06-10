

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

### Прочее

| Файл | Описание |
|------|----------|
| [`backend/docs/swagger.json`](backend/docs/swagger.json) | OpenAPI 2.0 спецификация |
| [`backend/docs/swagger.yaml`](backend/docs/swagger.yaml) | YAML-версия Swagger |
| [`backend/docs/config.md`](backend/docs/config.md) | Переменные окружения |
| [`backend/Makefile`](backend/Makefile) | Сборка, тесты, миграции, swagger |

### Итого

**15+ документов**, общий объём **~2 300 строк**. Для переписывания на любом языке достаточно — вся бизнес-логика, схема данных, API и потоки расписаны до уровня шагов.