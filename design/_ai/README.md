# `_ai/` — AI Handoff

> Папка для работы AI с дизайн-системой Bable.
> Здесь — инструкции, правила, команды, mapping контекста.
> Если ты AI-агент (Claude, MCP, plugin) — это твоё руководство.

---

## Quick start (для AI)

В порядке чтения для **новой сессии**:

1. **`AGENT.md`** — кто ты, что делаешь, что не делаешь
2. **`WORKFLOW.md`** — как ты работаешь (5 стандартных процедур)
3. **`COMMANDS.md`** — какие триггеры тебя запускают и как реагировать
4. **`CONTEXT-MAP.md`** — какие файлы из `design/` читать для каждой задачи
5. **`FIGMA-RULES.md`** — правила работы в Figma (pages, frames, naming, components)

Дальше — конкретные файлы по задаче (см. CONTEXT-MAP).

---

## Quick start (для человека)

Если ты дизайнер / разработчик / PM работаешь с AI над Bable:

1. **Начни с `AGENT.md`** — узнай, что AI умеет и где границы
2. **Глянь `COMMANDS.md`** — как давать AI задачи (фразами или slash-командами)
3. **`WORKFLOW.md`** — что ожидать от AI на каждом шаге работы
4. **`FIGMA-RULES.md`** — что AI создаёт в Figma и как это организует

---

## Файлы

| Файл | Что внутри | Когда читать |
|------|-----------|------------|
| [`AGENT.md`](AGENT.md) | Identity, скилы, границы AI. Что делает / что не делает. Tone взаимодействия. | **Первым** в каждой сессии |
| [`WORKFLOW.md`](WORKFLOW.md) | 5 стандартных процедур: draw screen, create component, extend, validate, write copy. Пошагово. | Перед началом любой задачи |
| [`COMMANDS.md`](COMMANDS.md) | `/draw-screen`, `/create-component`, `/validate-`, `/copy`, `/audit`, etc. Triggers и outputs. | Когда понимаешь намерение пользователя |
| [`CONTEXT-MAP.md`](CONTEXT-MAP.md) | Какие файлы из `design/` читать для какой задачи. Минимальный + extended. | После определения типа задачи |
| [`FIGMA-RULES.md`](FIGMA-RULES.md) | Pages, frame naming, components, variants, auto-layout, styles. Self-check. **§14 — common AI/MCP pitfalls.** | При работе непосредственно в Figma |
| [`REVIEW-2026-06-15-figma-v0.1.md`](REVIEW-2026-06-15-figma-v0.1.md) | Senior UX/UI ревью первой AI-сборки Figma-файла. Findings + remediation plan. | Перед "v0.2" итерацией Figma-файла |

---

## Принципы папки

### 1. Self-contained instructions

Каждый файл написан так, чтобы AI без дополнительного контекста мог приступить к работе. Минимум cross-references к тем местам, которые **обязательно** нужны.

### 2. Pointers, not duplication

Если правило живёт в `00-brief/PRINCIPLES.md` — мы ссылаемся, не копируем. Один source of truth.

### 3. Executable, not aspirational

Все инструкции — actionable. "Прочитай VISION.md" > "Помни про vision". "Используй `surface-elevated`" > "Используй правильные цвета".

### 4. Validation first

В каждом workflow есть self-validation step. Не пропускать.

---

## Что эти файлы НЕ заменяют

- Не заменяют `00-brief/VISION.md`, `PRINCIPLES.md`, `COPY-GUIDE.md` — это основа продукта
- Не заменяют `03-tokens/*` — это дизайн-словарь
- Не заменяют human review — AI делает первый проход, человек апрувит

---

## Жизненный цикл `_ai/`

Эта папка обновляется когда:

- Добавляются новые типы задач (нужен новый workflow)
- Появляется новый инструмент (MCP-связка с Figma, например — новые FIGMA-RULES)
- AI делает повторяющуюся ошибку (добавляем правило в AGENT или WORKFLOW)
- Меняется команда / процесс (обновляется CONTEXT-MAP)

Не обновляется при изменениях в продукте (это `00-brief/`) или в дизайн-системе (это `03-tokens/`).

---

## Структура `design/` (для контекста)

```
design/
├── 00-brief/          ← What and why we're building
│   ├── VISION.md
│   ├── PROJECT-BRIEF.md
│   ├── PRINCIPLES.md
│   └── COPY-GUIDE.md
├── 01-research/       ← Who for, JTBD, anti-patterns
│   ├── personas.md
│   ├── anti-personas.md
│   ├── competitors.md
│   ├── jtbd.md
│   ├── switch-triggers.md
│   ├── anti-patterns.md
│   └── positive-patterns.md
├── 02-strategy/       ← Positioning, MVP scope, visual direction
│   ├── POSITIONING.md
│   ├── MVP-SCOPE.md
│   ├── visual-directions.md
│   └── CHOSEN-DIRECTION.md
├── 03-tokens/         ← Design system primitives + semantic + component
│   ├── colours.md
│   ├── typography.md
│   ├── spacing.md
│   ├── radius-elevation.md
│   ├── motion.md
│   ├── icons.md
│   ├── code-theme.md
│   └── component-tokens.md
├── 04-components/     ← (when exists) Component specs (atomic library)
├── 05-flows/          ← (when exists) IA, navigation, wireframes
├── 06-screens/        ← (when exists) Hi-fi screen specs
└── _ai/               ← YOU ARE HERE
    ├── AGENT.md
    ├── WORKFLOW.md
    ├── COMMANDS.md
    ├── CONTEXT-MAP.md
    └── FIGMA-RULES.md
```

---

## Example interaction

```
User: Нарисуй экран профиля разработчика

AI: (читает AGENT.md, WORKFLOW.md)
    Это /draw-screen команда. Использую WORKFLOW §1.

    Reading context:
    - VISION, PRINCIPLES, COPY-GUIDE
    - MVP-SCOPE → ProfileScreen P1-P7
    - tokens/* (8 files)
    - components/profile-header, post-card, score-figure (если есть)

    Plan:
    Screen: Profile/Self
    States: Default, Loading, Empty, Error

    Components I need:
    ✅ Avatar — exists, size xl
    ✅ ScoreFigure — exists
    ✅ PostCard — exists, feed variant
    🟡 ProfileHeader — НЕ существует, нужно создать как molecule

    Open questions:
    - ProfileHeader как molecule или собрать на screen-level?
    - Score layout: vertical (editorial) или horizontal (compact)?

    Подтверди план или скорректируй.
```

После confirm — AI идёт в Step 3 (execute), потом Step 4 (validate), потом Step 5 (hand off).
