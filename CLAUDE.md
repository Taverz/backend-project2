# CLAUDE.md — Entry point for AI agents

> Если ты AI-агент (Claude Code, Cursor, MCP, plugin) — это первый файл, который ты читаешь.
> Цель: за 3 минуты понять, что за проект, где канон, и куда идти дальше для конкретной задачи.

---

## 1. Что за проект

**Chirp** — Twitter-like социальная сеть: посты, фолоу, лента, лайки, поиск, уведомления.

| Слой | Технологии | Статус |
|------|-----------|--------|
| Backend | Go 1.23+, Chi, PostgreSQL, Redis | Фазы 1-2 завершены (User/Tweet/Follow/Like/Timeline) |
| Flutter | Dart, монорепо workspaces | Foundation готов (apps/chirp + storybook + packages/ui_kit + app_api) |
| iOS / Android / Web | — | Не начаты |

Полный канон продукта: **`/SOUL.md`**.

---

## 2. Два слоя канона — не путать

| Слой | Канон | Что описывает |
|------|-------|---------------|
| **Продукт** (что за фичи, сущности, API) | `/SOUL.md`, `docs/shared/` | Twitter-clone: User, Tweet, Follow, Like, Timeline, Notification |
| **Визуальная айдентика** (как выглядит) | `design/03-tokens/`, `design/04-components/` | Editorial calm — тёплая бумажная палитра, terra cotta акцент, Phosphor icons, serif headlines |

При конфликте имён компонентов или цветов между двумя слоями — **визуальный канон побеждает** для UI. Все конкретные hex / px / шрифты — только в `design/03-tokens/`. Никаких raw значений в коде или в `docs/shared/`. Маппинг semantic → primitive — `design/03-tokens/semantic-mappings.md`.

Pivot-эксперимент с "IT-expertise platform" (Persona Recruiter, Expertise Score, Endorsement) **отвергнут** и лежит в `design/_archive_pivot/`. Не использовать сущности оттуда в новой работе. Извлекать только если будет явно сказано.

---

## 3. Структура репозитория

```
/                     ← корень
├── CLAUDE.md         ← (этот файл) entry point для AI
├── SOUL.md           ← канон продукта и архитектуры
├── README.md         ← человеческая read-me репозитория
├── Makefile          ← команды (test, build, swagger)
│
├── backend/          ← Go backend, чистая архитектура
│   ├── domain/       ← чистые типы, zero deps
│   ├── usecase/      ← бизнес-логика, зависит от port
│   ├── port/         ← интерфейсы (контракты адаптеров)
│   ├── adapter/      ← реализации port (postgres, in-memory, redis)
│   └── transport/    ← HTTP-handlers
│
├── flutter/          ← Flutter монорепо (workspaces)
│   ├── apps/chirp/   ← основное приложение
│   ├── apps/storybook/ ← компонент-каталог
│   └── packages/
│       ├── ui_kit/   ← компоненты, темы, иконки, токены
│       └── app_api/  ← API-клиент (модели + repos + dio)
│
├── docs/             ← документация для людей и AI
│   ├── PROMPT-TEMPLATES.md  ← ⭐ шаблоны промтов для всех типов задач
│   ├── BREAKING-CHANGES.md  ← policy и журнал API-изменений
│   ├── WORKFLOW.md          ← общий процесс работы над фичей
│   ├── shared/              ← кросс-платформенные спеки (API, ERRORS, SCREENS, FEATURES, …)
│   ├── shared/auth-flow/    ← пример полной фичи (canonical reference)
│   ├── flutter/             ← Flutter-специфика (архитектура, иконки, тесты, setup)
│   └── examples/            ← шаблоны фич (media-upload, follow-timeline)
│
├── design/           ← визуальная дизайн-система и AI-инструкции
│   ├── README.md
│   ├── 01-auth/      ← Splash / Login / Register screens
│   ├── 03-tokens/    ← КАНОН: primitives → semantic → component tokens
│   ├── 04-components/ ← atomic компоненты (atoms / molecules / organisms)
│   ├── _ai/          ← инструкции для AI по design-работе
│   └── _archive_pivot/ ← отвергнутая IT-expertise концепция (не использовать)
│
├── obsidian/         ← персональные заметки автора (игнорировать)
└── python/           ← вспомогательные скрипты (если есть)
```

---

## 4. Маршрут чтения по типу задачи

Прежде чем начинать любую задачу — **открой `docs/PROMPT-TEMPLATES.md`** и найди подходящий шаблон. Каждый шаблон уже содержит:
- роль / контекст / цель / ввод / ограничения / формат / проверка,
- ссылки на правильные каноны.

Quick-навигация:

| Задача | Сначала прочитай |
|--------|------------------|
| Backend код (Go) | `/SOUL.md` §2-4, `docs/shared/API.md`, `docs/shared/ERRORS.md`, соседний модуль в `backend/` |
| Flutter код | `docs/flutter/ARCHITECTURE_RULES.md`, `docs/flutter/HOW-TO-ADD-FEATURE.md`, `docs/flutter/ICON-STRATEGY.md` |
| Новая фича end-to-end | `docs/shared/FEATURES.md`, `docs/shared/auth-flow/` как образец, `docs/WORKFLOW.md` |
| Code review | `/SOUL.md` §2, `docs/flutter/ARCHITECTURE_RULES.md`, `docs/PROMPT-TEMPLATES.md §3` |
| Дизайн экрана | `design/_ai/AGENT.md` → `WORKFLOW.md` → `CONTEXT-MAP.md`; токены из `design/03-tokens/` |
| Дизайн компонента | `design/04-components/README.md` + `design/03-tokens/component-tokens.md` + `semantic-mappings.md` |
| Figma → код | `docs/shared/DESIGN-CONTRACT.md` §1 (naming), `design/03-tokens/semantic-mappings.md`, `docs/flutter/ICON-STRATEGY.md` |
| Код → Figma | `docs/shared/DESIGN-CONTRACT.md`, `design/_ai/FIGMA-RULES.md` |
| Breaking API change | `docs/BREAKING-CHANGES.md` (policy + шаблон записи) |
| Тесты | `docs/flutter/TESTING.md` (для Flutter), `backend/*_test.go` соседи (для Go) |

---

## 5. Правила, которые AI нарушать не должен

### Архитектура
- **Backend.** `domain` не импортирует ничего из проекта. `usecase` зависит только от `port`. `transport` не вызывает `adapter` напрямую. Подробно: `/SOUL.md` §2.
- **Flutter.** Bloc — только для I/O (см. memory `feedback_flutter_architecture`). Material — только `Scaffold` (+ `AppTextField`). UI-примитивы — в `packages/ui_kit`. API — в `packages/app_api`. Подробно: `docs/flutter/ARCHITECTURE_RULES.md`.

### Дизайн
- **Никаких raw hex / px / font-family в коде или Figma** — только через токены из `design/03-tokens/`.
- **Никаких emoji в UI chrome** (buttons, labels, nav). Emoji допустимы только в user-generated content.
- **Никаких компонентов из ниоткуда** — используем существующие в `design/04-components/` и `packages/ui_kit/`. Новый компонент = отдельная задача со спекой.
- **Material Icons запрещены** в feature-коде Flutter. См. `docs/flutter/ICON-STRATEGY.md`.

### Процесс
- **Не выдумывай endpoints / поля / методы** — если нет в `docs/shared/API.md` или соседнем коде, спроси.
- **Не амендуй коммиты, не делай force-push, не используй `--no-verify`** без явного запроса.
- **Не создавай `*.md` документацию по своей инициативе** — только если попросили.
- **Followups в отдельную секцию** — не чини "заодно" вне скоупа задачи.

---

## 6. Команды

| Команда | Что делает |
|---------|-----------|
| `make test` | Все тесты backend |
| `make swagger` | Регенерация Swagger из аннотаций |
| `make run` | Запуск backend локально |
| `cd flutter && dart pub get` | Установить Flutter зависимости |
| `cd flutter/apps/chirp && flutter test` | Тесты основного приложения |

---

## 7. Перед сдачей результата

Self-check для любой задачи:

- [ ] Тесты зелёные (`make test` для backend / `flutter test` для Flutter)
- [ ] Сheck'и архитектуры не нарушены (см. §5)
- [ ] Нет magic strings/hex/px в новом коде
- [ ] Followups вынесены отдельным списком, не починены в этом же PR
- [ ] Обновлены связанные доки, если контракт изменился (API.md / FEATURES.md / SOUL.md)
- [ ] Логи без PII (email, password, token)

---

## 8. Если что-то не сходится

- Несоответствие между `docs/shared/` и `design/03-tokens/` → используй `design/03-tokens/` для UI значений, `docs/shared/` — для продуктовых сущностей.
- Спецификация противоречит коду → спроси, не предполагай.
- Файл упоминается в чужой ссылке, но не существует → проверь `design/_archive_pivot/`; если там — он отвергнут, не использовать.
- Не понимаешь продуктовую логику → `/SOUL.md` §1-3 даёт самое короткое объяснение.

---

## 9. Связанные документы для подробностей

- **`/SOUL.md`** — продуктовый и архитектурный канон
- **`docs/PROMPT-TEMPLATES.md`** — шаблоны промтов по типам задач (must-read для AI)
- **`docs/WORKFLOW.md`** — процесс работы над фичей end-to-end
- **`docs/shared/DESIGN-CONTRACT.md`** — контракт между дизайном и кодом (naming, icons, screen states)
- **`design/_ai/AGENT.md`** — расширенная роль для design-задач
- **`design/03-tokens/README.md`** — индекс визуальных токенов
- **`docs/BREAKING-CHANGES.md`** — как ломать API без катастрофы
