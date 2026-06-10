# Multi-Platform Project: как организовать документацию

> Проблема: backend (Go) + Android (Kotlin) + iOS (Swift) + Flutter (Dart).
> Одна бизнес-логика, N реализаций. Как не плодить N копий одного и того же?

---

## Главный принцип

**Бизнес-логика и данные — в одном экземпляре.**
**Реализация — отдельно на каждую платформу.**

```
docs/
├── shared/                  ← ОДНА копия для всех платформ
│   ├── SOUL.md              ← идентичность, архитектурные решения (уже есть)
│   ├── API.md               ← все эндпоинты, request/response (уже есть DESIGN-API.md)
│   ├── DATA-FLOW.md         ← как данные движутся через систему
│   ├── FEATURES.md          ← каждая фича: что делает, acceptance criteria
│   ├── SCREENS.md           ← экранная карта, пользовательские сценарии
│   ├── ERRORS.md            ← все ошибки, их HTTP-коды и тексты
│   └── DESIGN-SYSTEM.md     ← цвета, типографика, компоненты, состояния
│
├── backend/                 ← специфика Go-бэкенда
│   ├── DESIGN.md
│   ├── STRUCTURE.md         ← директории, naming, паттерны
│   └── migrations/
│
├── flutter/                 ← специфика Flutter
│   ├── FLUTTER.md           ← карта проекта
│   ├── STRUCTURE.md         <- директории, naming, state management
│   └── widgets/             ← примеры ключевых компонентов
│
├── android/                 ← специфика Android (Kotlin)
│   ├── ANDROID.md           ← карта проекта
│   ├── STRUCTURE.md         ← MVVM? Clean Architecture? директории
│   └── navigation/          ← NavGraph, deep links
│
├── ios/                     ← специфика iOS (Swift)
│   ├── IOS.md               ← карта проекта
│   ├── STRUCTURE.md         ← MVVM? Coordinator? директории
│   └── navigation/          ← SwiftUI NavigationStack / UIKit
│
└── web/                     ← специфика Web (TypeScript)
    ├── STRUCTURE.md         ← React + TypeScript, hooks, api, pages
    └── styles/              ← Tailwind theme
```

---

## Какие файлы нужны — подробно

### SHARED (один экземпляр для всех платформ)

#### 1. SOUL.md — «почему» проект существует

Что есть сейчас. Добавить секцию **«Кто что реализует»**:

```markdown
## Платформы

| Платформа | Язык | Статус | Отвечает |
|-----------|------|--------|----------|
| Backend | Go | ✅ Фаза 2 | backend/ |
| Flutter | Dart | ⬜ | flutter/ |
| Android | Kotlin | ⬜ | android/ |
| iOS | Swift | ⬜ | ios/ |
```

#### 2. API.md — контракт между backend и всеми клиентами

Есть как DESIGN-API.md (974 строки). Единственный источник правды для:
- Всех эндпоинтов (метод, URL, JWT-статус)
- Request body (JSON-схема)
- Response body (JSON-схема)
- Кодов ошибок (HTTP status → detail)
- Формата пагинации (cursor, limit, next_cursor)
- Формата JWT (access + refresh)

**Критическое правило:** если API меняется — меняется ТОЛЬКО этот файл.
AI на каждой платформе читает его и синхронизирует код.

#### 3. DATA-FLOW.md — как данные движутся

Что сейчас разбросано по `backend/docs/flows/*.md`. Единый файл для всех платформ:

```markdown
## Публикация твита (create tweet)

Клиент → POST /tweets {body, media_ids?}
  → Backend: validate → save → fan-out → search index
  → Response: 201 + Tweet
  → Клиент: получает твит, добавляет в локальный state

## Подписка (follow)

Клиент → POST /users/{id}/follow
  → Backend: check self → check exists → save → publish event
  → Response: 204
  → Клиент: обновляет UI (кнопка → Following)
  → Backend (async): создаёт уведомление target'у
```

**Зачем:** каждая платформа может реализовать один и тот же flow, не гадая,
«а что там на сервере происходит?»

#### 4. FEATURES.md — что делает каждая фича

Атомарное описание **каждой фичи** с acceptance criteria:

```markdown
## Feature: Follow user

### Description
Зарегистрированный пользователь может подписаться на другого пользователя.

### Acceptance Criteria
- POST /users/{id}/follow → 204
- Нельзя подписаться на себя → 400 "cannot follow yourself"
- Нельзя подписаться на несуществующего пользователя → 404
- После подписки кнопка меняется с "Follow" на "Following"
- После подписки твиты пользователя появляются в ленте
- При подписке (если не на себя) → уведомление target'у

### Data Flow
См. DATA-FLOW.md → Follow

### API
POST /api/v1/users/{id}/follow (🔒)
DELETE /api/v1/users/{id}/follow (🔒)
GET /api/v1/users/{id}/followers (🌐)
GET /api/v1/users/{id}/following (🌐)
```

#### 5. SCREENS.md — что видит пользователь

Экранная карта, общая для всех платформ:

```markdown
## Screen: Home Timeline

Route: /home
Auth: 🔒
Platforms: mobile (bottom tab), web (main column)

### Elements
1. Top bar: "Chirp" + avatar (profile link)
2. Tweet list: бесконечный скролл
3. Tweet card: avatar + username + body + timestamp + actions
4. FAB: "New Tweet" → push /create
5. Bottom navigation: Home, Search, Notifications, Profile

### States
| State | Что показать |
|-------|-------------|
| Loading | Skeleton (3-5 placeholder cards) |
| Empty | "No tweets yet. Follow someone to see tweets." |
| Error | "Something went wrong" + Retry button |
| Data | Список твитов |
| Loading more | Activity indicator внизу списка |

### User Actions
| Action | Результат |
|--------|-----------|
| Tap tweet card | Push /tweet/{id} |
| Tap avatar | Push /user/{id} |
| Tap like | POST /tweets/{id}/like → toggle heart |
| Tap FAB | Push /create |
| Pull to refresh | GET /timeline/home?cursor= |
| Scroll to bottom | Load more |
```

#### 6. DESIGN-SYSTEM.md — как выглядит UI

```markdown
## Colors

| Token | Hex | Назначение |
|-------|-----|-----------|
| Primary | #1DA1F2 | Twitter blue, кнопки, ссылки |
| Background | #FFFFFF / #15202B | Светлая / тёмная тема |
| Card | #F5F5F5 / #192734 | Карточки твитов |
| Error | #E0245E | Ошибки, удаление |
| Text primary | #0F1419 / #FFFFFF | Основной текст |

## Typography

| Token | Size | Weight | Использование |
|-------|------|--------|--------------|
| h1 | 24px | 700 | Заголовки экранов |
| body | 16px | 400 | Текст твита |
| caption | 13px | 400 | Timestamp, подписи |
| button | 15px | 600 | Кнопки |

## Components

### TweetCard
- Avatar (48×48, круглый, инициалы если нет фото)
- Username (body, bold)
- Body (body, 1-280 chars, line-height 1.4)
- Timestamp (caption, grey)
- Actions row: Reply, Retweet, Like, Share
```

#### 7. ERRORS.md — все ошибки в одном месте

```markdown
| HTTP | Domain Error | Detail | Что делать клиенту |
|:----:|-------------|--------|-------------------|
| 400 | ErrBodyTooLong | tweet body: must be at most 280 characters | Показать предупреждение под полем ввода |
| 401 | — | missing authorization header | Redirect на /login |
| 401 | — | invalid or expired token | Попробовать refresh, если не вышло → /login |
| 403 | ErrNotOwner | you can only delete your own tweets | Скрыть кнопку удаления |
| 404 | ErrTweetNotFound | tweet not found | Показать «Tweet not found» |
| 409 | ErrEmailTaken | email already registered | Подсветить поле email |
| 413 | — | payload too large | Показать «File too large» |
```

---

### PLATFORM-SPECIFIC (по одному экземпляру на платформу)

#### Каждая платформа получает STRUCTURE.md

```markdown
# Flutter Structure (пример)

## Принципы
- Feature-first: каждая фича = директория с screens/, widgets/, providers/
- Core: разделяемые модули (api, models, theme, utils)
- Shared: переиспользуемые UI-компоненты
- GoRouter для навигации
- Riverpod для состояния

## Где что лежит
lib/
  core/api/       ← HTTP-клиент, endpoints
  core/models/    ← DTO (fromJson)
  core/theme/     ← Дизайн-система
  features/*/     ← Фичи
  shared/         ← Переиспользуемые виджеты
```

---

## Сколько это всё стоит в файлах

### Shared (для всех платформ — 1 раз)

| Файл | Строк | Зачем |
|------|-------|-------|
| SOUL.md | ~50 | Идентичность, решения, платформы |
| API.md | ~400 | Контракт backend↔клиенты |
| DATA-FLOW.md | ~100 | Как данные движутся |
| FEATURES.md | ~300 | Что делает каждая фича |
| SCREENS.md | ~200 | Экранная карта, состояния, элементы |
| DESIGN-SYSTEM.md | ~100 | Цвета, шрифты, компоненты |
| ERRORS.md | ~50 | Все ошибки и реакция клиента |
| **Итого shared** | **~1200** | |

### Per platform (по 1 разу на каждую)

| Файл | Строк | Зачем |
|------|-------|-------|
| STRUCTURE.md | ~50 | Где что лежит |
| **Итого platform** | **~50** | |

### Итог для проекта с 4 платформами

```
shared/           ~1200 строк  (1 раз)
backend/           ~50 строк
flutter/           ~50 строк
android/           ~50 строк
ios/               ~50 строк
                  ─────────
Всего            ~1400 строк
```

По сравнению с 5 255 строками Go-кода — **документация занимает ~25% от объёма кода**. Это нормально.

---

## Как AI работает с такой структурой

**AI получает задачу:** «Сделай экран Home Timeline на SwiftUI».

**AI читает:**
1. `shared/API.md` — какие эндпоинты дёргать
2. `shared/SCREENS.md` — какие элементы, состояния, actions
3. `shared/DESIGN-SYSTEM.md` — цвета, шрифты, компоненты
4. `shared/ERRORS.md` — что показывать при ошибках
5. `ios/STRUCTURE.md` — куда положить файлы, какой паттерн

**AI НЕ читает:**
- Go-код (не нужен для Swift)
- Android-структуру
- Flutter-структуру

**Результат:** AI генерирует экран, который:
- Дёргает правильные API (из API.md)
- Показывает правильные состояния (из SCREENS.md)
- Использует правильные цвета/шрифты (из DESIGN-SYSTEM.md)
- Лежит в правильной директории (из STRUCTURE.md)
- Правильно обрабатывает ошибки (из ERRORS.md)

---

## Резюме: какие файлы нужны

```
docs/shared/
├── SOUL.md              ← обязательно (уже есть)
├── API.md               ← обязательно (уже есть как DESIGN-API.md)
├── DATA-FLOW.md         ← опционально (можно собрать из flows/*.md)
├── FEATURES.md          ← обязательно (без него AI не знает, что делать)
├── SCREENS.md           ← обязательно (без него AI гадает UI)
├── DESIGN-SYSTEM.md     ← обязательно (без него AI придумывает свои цвета)
└── ERRORS.md            ← опционально (можно встроить в API.md)

docs/backend/STRUCTURE.md    ← опционально (для нового разработчика)
docs/flutter/STRUCTURE.md    ← обязательно (для AI-генерации Flutter)
docs/android/STRUCTURE.md    ← обязательно (для AI-генерации Android)
docs/ios/STRUCTURE.md        ← обязательно (для AI-генерации iOS)
```

**Без чего AI не сможет работать адекватно:**
1. `API.md` — не знает, какие запросы слать
2. `FEATURES.md` — не знает, что должна делать фича
3. `SCREENS.md` — не знает, как выглядит экран и какие у него состояния
4. `DESIGN-SYSTEM.md` — придумает свои цвета и шрифты, получится каша

**С чем AI справится без документации:**
- Архитектура внутри платформы (MVVM, Clean Architecture, etc.)
- Routing
- State management
- Тесты
