# `_ai/` — AI Handoff (Design)

> Папка для работы AI с визуальной системой Chirp.
> Здесь — инструкции, правила, команды, mapping контекста.
> Если ты AI-агент (Claude, MCP, plugin) — это твоё руководство по design-задачам.

Общий entry-point для всего репо — `/CLAUDE.md`. Дизайн — частный случай.

---

## Quick start (для AI)

В порядке чтения для **новой сессии**:

1. **`/CLAUDE.md`** — что за проект, два слоя канона (продукт vs визуал)
2. **`AGENT.md`** — кто ты, что делаешь, что не делаешь
3. **`WORKFLOW.md`** — пошаговые процедуры (draw / create / extend / validate / convert / copy)
4. **`CONTEXT-MAP.md`** — какие файлы из `design/` и `docs/` читать для каждой задачи
5. **`COMMANDS.md`** — какие триггеры тебя запускают и как реагировать
6. **`FIGMA-RULES.md`** — правила работы в Figma (pages, frames, naming, components)

Дальше — конкретные файлы по задаче (см. CONTEXT-MAP) или готовый шаблон из
**`docs/PROMPT-TEMPLATES.md`**.

---

## Quick start (для человека)

Если ты дизайнер / разработчик / PM работаешь с AI над Chirp:

1. **Начни с `AGENT.md`** — узнай, что AI умеет и где границы
2. **Глянь `COMMANDS.md`** — как давать AI задачи (фразами или slash-командами)
3. **`WORKFLOW.md`** — что ожидать от AI на каждом шаге работы
4. **`FIGMA-RULES.md`** — что AI создаёт в Figma и как это организует
5. **`/docs/PROMPT-TEMPLATES.md`** — готовые шаблоны промтов

---

## Файлы

| Файл | Что внутри | Когда читать |
|------|-----------|------------|
| [`AGENT.md`](AGENT.md) | Identity, скилы, границы AI. Что делает / что не делает. Tone. | **Первым** в каждой сессии |
| [`WORKFLOW.md`](WORKFLOW.md) | 7 процедур: draw screen, create/extend component, validate, Figma→code, code→Figma, write copy | Перед началом любой задачи |
| [`COMMANDS.md`](COMMANDS.md) | Slash-команды и фразы-триггеры. Inputs/outputs каждой команды. | Когда понимаешь намерение пользователя |
| [`CONTEXT-MAP.md`](CONTEXT-MAP.md) | Какие файлы читать для какой задачи. Minimum + extended. | После определения типа задачи |
| [`FIGMA-RULES.md`](FIGMA-RULES.md) | Pages, frame naming, components, variants, auto-layout, styles. **§14 — common AI/MCP pitfalls.** | При работе непосредственно в Figma |
| [`archive/`](archive/) | Прошлые session-логи и ревью (исторический контекст, не правила) | Только если нужна история конкретной итерации |

---

## Принципы папки

### 1. Self-contained instructions

Каждый файл написан так, чтобы AI без дополнительного контекста мог приступить к работе.
Минимум cross-references к тем местам, которые **обязательно** нужны.

### 2. Pointers, not duplication

Если правило живёт в `docs/shared/DESIGN-CONTRACT.md` — мы ссылаемся, не копируем.
Один source of truth.

### 3. Executable, not aspirational

Все инструкции — actionable.
"Прочитай `colours.md`" > "Помни про токены".
"Используй `surface-elevated`" > "Используй правильные цвета".

### 4. Validation first

В каждом workflow есть self-validation step. Не пропускать.

---

## Что эти файлы НЕ заменяют

- **Не заменяют** `/SOUL.md` и `docs/shared/FEATURES.md` — это продуктовый канон
- **Не заменяют** `design/03-tokens/*` — это визуальный словарь (semantic + component слои)
- **Не заменяют** `docs/shared/DESIGN-CONTRACT.md` — это контракт design↔code
- **Не заменяют** human review — AI делает первый проход, человек апрувит

---

## Жизненный цикл `_ai/`

Эта папка обновляется когда:

- Добавляются новые типы задач (нужен новый workflow)
- Появляется новый инструмент (новая MCP-связка с Figma — обновляем FIGMA-RULES)
- AI делает повторяющуюся ошибку (добавляем правило в AGENT или WORKFLOW)
- Меняется команда / процесс (обновляется CONTEXT-MAP)

Не обновляется при изменениях в продукте (это `/SOUL.md` + `docs/shared/`) или в
дизайн-системе (это `design/03-tokens/` + `design/04-components/`).

---

## Структура `design/` (для контекста)

```
design/
├── README.md
├── 01-auth/             ← Splash / Login / Register feature spec
├── 03-tokens/           ← Visual KANON: primitives → semantic → component tokens
├── 04-components/       ← Atomic компоненты (atoms / molecules / organisms)
├── _ai/                 ← YOU ARE HERE
│   ├── AGENT.md
│   ├── WORKFLOW.md
│   ├── COMMANDS.md
│   ├── CONTEXT-MAP.md
│   ├── FIGMA-RULES.md
│   └── archive/         ← старые session-логи и ревью
└── _archive_pivot/      ← отвергнутая IT-expertise концепция (НЕ использовать)
```

⚠️ **`_archive_pivot/`** содержит концепции `Endorse`, `ScoreFigure`, `Expertise`, `Recruiter`.
Они отвергнуты. Любое упоминание в задаче — сигнал переспросить, не работать с ними молча.

---

## Example interaction

```
User: Нарисуй экран Timeline

AI: (читает /CLAUDE.md, _ai/AGENT.md, _ai/WORKFLOW.md §1, _ai/CONTEXT-MAP.md § Draw a screen)

    Это /draw-screen команда. Использую WORKFLOW §1.

    Reading context:
    - /CLAUDE.md → Chirp = Twitter-like, editorial visual canon
    - docs/shared/SCREENS.md § Timeline → 5 states обязательны
    - docs/shared/WIDGET-STATES.md → loading/empty/error patterns
    - design/03-tokens/ → semantic + component tokens
    - design/04-components/ → atoms готовы (Avatar, Button), TweetCard ещё нет

    Plan:
    Screen: TimelineScreen
    States: Default, Loading, Empty, Error, LoadingMore

    Components:
    ✅ Avatar — exists, size md
    ✅ Button — exists, primary
    🟡 TweetCard — НЕ существует, нужно создать как molecule
    🟡 TopBar — НЕ существует, нужно создать как atom

    Open questions:
    - TweetCard как отдельная задача перед screen'ом, или собрать вместе?
    - TopBar: только логотип на mobile или + search?

    Подтверди план или скорректируй.
```

После confirm — AI идёт в Step 3 (execute), потом Step 4 (validate), потом Step 5 (hand off).

Готовый промт для Draw a screen — `docs/PROMPT-TEMPLATES.md §7`.
