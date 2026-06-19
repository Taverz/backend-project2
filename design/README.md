# Design Folder Structure

> Все артефакты дизайна Chirp: токены, компоненты, фича-спеки.
> Продукт = Twitter-clone (см. `/SOUL.md` и `docs/shared/`).
> Визуальная айдентика — editorial calm с тёплой палитрой и terra cotta акцентом.

---

## Структура

```
design/
├── README.md                 ← (this)
│
├── _ai/                      ← Workflow для AI-агента
│   ├── AGENT.md              ← Роль и правила
│   ├── WORKFLOW.md           ← Как создавать экран/компонент
│   ├── COMMANDS.md           ← Шорткаты команд
│   ├── FIGMA-RULES.md        ← Конвенции в Figma
│   ├── CONTEXT-MAP.md        ← Что читать перед задачей
│   ├── README.md
│   └── archive/              ← Прошлые session-логи и ревью
│
├── 01-auth/                  ← Feature: Splash / Login / Register
│   ├── README.md             ← Экраны и состояния
│   └── components.md         ← Спеки уникальных для auth атомов
│
├── 03-tokens/                ← Канонические design tokens
│   ├── README.md             ← Индекс и принципы
│   ├── colours.md            ← Primitives + semantic (light/dark)
│   ├── typography.md         ← Type scale, font stack
│   ├── spacing.md            ← 4-base scale
│   ├── radius-elevation.md   ← Borders + почти-нет-shadows
│   ├── motion.md             ← Duration, easing
│   ├── icons.md              ← Phosphor + canonical vocabulary
│   ├── code-theme.md         ← Syntax highlighting
│   ├── component-tokens.md   ← Промежуточный слой semantic → component
│   └── semantic-mappings.md  ← Сводная таблица primitive → semantic → component
│
└── 04-components/            ← Atomic дизайн
    ├── README.md             ← Tier-priority и spec template
    ├── atoms/                ← Avatar, Button
    ├── molecules/            ← README + WIP молекулы
    └── organisms/            ← WIP
```

---

## _archive_pivot/

В `_archive_pivot/` лежит IT-expertise pivot, который был отвергнут:
brief (Persona Recruiter, Expertise Score), research, strategy, и
pivot-специфичные атомы (`score-figure`, `button-passport`). Извлечь
оттуда любую часть можно, если решим вернуться к концепции.

Текущая продуктовая концепция: см. **`/SOUL.md`** и
**`docs/shared/FEATURES.md`** — стандартный Twitter-flow с твитами,
лайками, фолоу и таймлайном.

---

## Workflow добавления фичи

1. Создать `design/{NN}-{feature-name}/` (например `02-feed/`)
2. `README.md` — экраны фичи: layout, состояния (Loading/Empty/Error/Data)
3. `components.md` — атомы и молекулы, уникальные для фичи
4. Общие компоненты — в `design/04-components/`
5. Все цвета/шрифты/spacing — только через токены из `design/03-tokens/`

---

## Как AI использует папку

```
Задача: "Нарисуй FeedScreen"

1. Читает /SOUL.md и docs/shared/FEATURES.md   → продуктовый контекст
2. Читает design/03-tokens/README.md           → визуальные правила
3. Читает design/04-components/README.md       → доступные компоненты
4. Читает design/02-feed/README.md             → экран и состояния
5. Читает design/02-feed/components.md         → специфика фичи

→ Генерирует Figma frame с состояниями, используя только design tokens.
```

См. `_ai/WORKFLOW.md` для детального процесса.

---

## Связанная документация

- `/SOUL.md` — архитектура и доменные модули backend
- `docs/shared/FEATURES.md` — продуктовые фичи
- `docs/shared/DESIGN-CONTRACT.md` — naming, icons, screen states, Figma↔Code
- `docs/shared/DESIGN-SYSTEM.md` — концепция дизайн-системы (источник — `design/03-tokens/`)
- `docs/flutter/ICON-STRATEGY.md` — как иконки загружаются в Flutter
