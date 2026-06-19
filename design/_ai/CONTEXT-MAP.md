# Context Map — Что читать для какой задачи

> Чтобы не перегружать контекст: для каждой задачи — минимальный и расширенный список файлов.
> "Минимальный" = absolute must-read. "Расширенный" = добавь если задача нестандартная или есть открытые вопросы.

---

## Always (любая design-задача)

Эти **4 файла** читаются в каждой свежей сессии:

1. `/CLAUDE.md` — что за проект, где какой канон
2. `_ai/AGENT.md` — кто ты, что можешь, что нет
3. `_ai/WORKFLOW.md` — пошаговые процедуры
4. `docs/shared/DESIGN-CONTRACT.md` — контракт между дизайном и кодом

После — специфические по задаче.

---

## Task: Draw a screen

### Minimum

- Always (4)
- `docs/shared/SCREENS.md` — есть ли этот экран в списке, в какой фиче
- `docs/shared/WIDGET-STATES.md` — какие состояния обязательны
- `docs/shared/FEATURES.md` § той фичи, к которой принадлежит экран
- `design/03-tokens/colours.md`
- `design/03-tokens/typography.md`
- `design/03-tokens/spacing.md`
- `design/03-tokens/icons.md`
- `design/03-tokens/component-tokens.md`
- `design/03-tokens/semantic-mappings.md`
- `design/04-components/README.md`
- `design/04-components/atoms/` — то, что точно будет на экране (button, avatar)

### Extended (если есть открытые вопросы)

- `design/03-tokens/motion.md` — если экран имеет анимации/переходы
- `design/03-tokens/radius-elevation.md` — если есть карточки/модалки
- `docs/shared/auth-flow/` — если экран из auth-фичи
- `docs/shared/ERRORS.md` — для error-state копи

### Screen-specific

| Screen | Доп. файл |
|--------|-----------|
| Login / Register | `design/01-auth/README.md` + `docs/shared/auth-flow/06-UI-STATES.md` |
| Timeline / Feed | `docs/shared/auth-flow/08-BEHAVIOR.md` (паттерн данных) + `docs/shared/WIDGET-DATA-FLOW.md` |
| Tweet detail | `docs/shared/SCREENS.md § Tweet` + `design/03-tokens/code-theme.md` (если показывает code) |
| Profile | `docs/shared/SCREENS.md § Profile` + `docs/shared/DATA-REQUIREMENTS.md` |
| Search | `docs/shared/SCREENS.md § Search` |
| Notifications | `docs/shared/WIDGET-STATES.md § Notifications` |

---

## Task: Create a component

### Minimum

- Always (4)
- `design/04-components/README.md` — Tier-priority + spec template
- `design/04-components/` — что уже существует (избегать дубликат)
- `design/03-tokens/component-tokens.md`
- `design/03-tokens/semantic-mappings.md`
- `_ai/FIGMA-RULES.md` — правила naming/variants

### Component-type-specific

| Type | Доп. файл |
|------|-----------|
| Button | `design/03-tokens/colours.md § component-tokens — buttons`, semantic-mappings.md §1 |
| Input | `design/03-tokens/colours.md` (focus/disabled), semantic-mappings.md §2 |
| Card-like | `design/03-tokens/radius-elevation.md`, semantic-mappings.md §3 |
| Avatar | `design/03-tokens/component-tokens.md § Avatar` + fallback hash function |
| TweetCard / list-item | `docs/shared/SCREENS.md § Timeline`, `docs/shared/WIDGET-DATA-FLOW.md` |
| Empty state | `docs/shared/WIDGET-STATES.md` + copy guide в `docs/shared/ERRORS.md` |
| Confirm dialog | `docs/shared/ERRORS.md` (для warnings) |
| Code block | `design/03-tokens/code-theme.md` целиком |

---

## Task: Validate existing screen / component

### Minimum

- Always (4)
- `design/03-tokens/` (все 9 файлов) — для проверки токенов
- `docs/shared/DESIGN-CONTRACT.md` — naming, состояния, иконки
- `docs/shared/WIDGET-STATES.md` — обязательные states

### Specific to validation type

- Validation copy → банлист в этом workflow (см. `WORKFLOW.md §7`) + `docs/shared/ERRORS.md`
- Validation a11y → `design/03-tokens/colours.md §7` (контраст)
- Validation tokens → `design/03-tokens/semantic-mappings.md`
- Validation icons → `design/03-tokens/icons.md` + `docs/flutter/ICON-STRATEGY.md`

---

## Task: Write UI copy

### Minimum

- `docs/shared/ERRORS.md` — для error / warning / info messages
- `docs/shared/SCREENS.md` — empty states по экранам

### Extended

- Соседние экраны / spec этой фичи — для tone-consistency
- Принципы из `WORKFLOW.md §7`

---

## Task: Extend / refactor component

### Minimum

- Always (4)
- Существующий spec (`design/04-components/<layer>/<name>.md`)
- `design/03-tokens/component-tokens.md`
- `design/03-tokens/semantic-mappings.md`
- `_ai/FIGMA-RULES.md`

### Extended

- Если нужен новый semantic-token → `design/03-tokens/colours.md` (для цвета) или
  `typography.md` (для шрифта)
- Если меняется поведение → `_ai/WORKFLOW.md §3 + §4` (extend + validate)

---

## Task: Convert tokens to code (Flutter / Web / iOS)

### Minimum

- `design/03-tokens/` (все 9 файлов)
- `design/03-tokens/semantic-mappings.md` — главная таблица
- `docs/shared/DESIGN-CONTRACT.md §1, §2, §7` — naming, colors, typography mapping

### Specific

- **Flutter** → `docs/flutter/ARCHITECTURE_RULES.md`, `docs/flutter/ICON-STRATEGY.md`,
  `packages/ui_kit/lib/src/theme/` (если уже есть `ThemeData`)
- Web → CSS custom properties + Tailwind config (если есть)
- iOS → Asset catalog + UIColor extensions (если есть)

---

## Task: Figma → code spec

### Minimum

- `_ai/AGENT.md` + `_ai/WORKFLOW.md §5`
- `docs/shared/DESIGN-CONTRACT.md §1, §3, §6` (naming, icons, auto-layout)
- `design/03-tokens/semantic-mappings.md`
- Целевая платформа docs:
  - Flutter → `docs/flutter/ARCHITECTURE_RULES.md` + `ICON-STRATEGY.md`
- Готовый промт в `docs/PROMPT-TEMPLATES.md §10`

---

## Task: Code → Figma master

### Minimum

- `_ai/AGENT.md` + `_ai/WORKFLOW.md §6`
- `docs/shared/DESIGN-CONTRACT.md §1, §7, §8`
- `_ai/FIGMA-RULES.md` (page/frame/variant naming)
- `design/03-tokens/colours.md` + `typography.md` (для подбора styles)
- Готовый промт в `docs/PROMPT-TEMPLATES.md §11`

---

## Task: Discovery / understanding the product

User задаёт вопросы типа "что за проект?", "какие фичи?", "что такое X?".

### Minimum

- `/CLAUDE.md` — самое короткое объяснение
- `/SOUL.md` § 1-3 — длиннее, с архитектурой
- `docs/shared/FEATURES.md` — продуктовые фичи

Этих трёх обычно хватает.

### Extended

- `docs/shared/auth-flow/FLOW-README.md` — пример того, как фича задокументирована end-to-end
- `docs/MULTI-PLATFORM.md` — если вопрос про платформы

---

## Анти-pattern: что **не** читать без необходимости

- ❌ **`design/_archive_pivot/`** — это отвергнутая концепция. Никогда не читай для активной задачи.
- ❌ **Все `_ai/` файлы каждый раз** — `AGENT` + `WORKFLOW` достаточно для процесса.
- ❌ **Весь backend код** для дизайн-задач — он вне визуальной системы.
- ❌ **`docs/transcripts/` / `docs/metrics/`** — этих папок больше нет.
- ❌ **`docs/code-review-*.md`** — это исторические снэпшоты ревью, не правила.

---

## Heuristic — выбор файлов

Если задача про:

| Сигнал в задаче | Читай дополнительно |
|----------------|---------------------|
| "почему" / "обоснуй" | `/SOUL.md`, `docs/shared/FEATURES.md` |
| "выглядит как" / "стиль" | `design/03-tokens/colours.md`, `typography.md`, `motion.md` |
| "что писать" / "label" / "error" | `docs/shared/ERRORS.md`, `_ai/WORKFLOW.md §7` |
| "нельзя" / "запрещено" | `_ai/AGENT.md §4 (boundaries)` + `/CLAUDE.md §5` |
| "должно быть" / "always" | `docs/shared/DESIGN-CONTRACT.md` + `design/03-tokens/README.md` |
| "состояния экрана" | `docs/shared/WIDGET-STATES.md` + `DESIGN-CONTRACT.md §4` |
| "иконка" | `design/03-tokens/icons.md` + `docs/flutter/ICON-STRATEGY.md` |
| "tweet" / "feed" | `docs/shared/SCREENS.md`, `WIDGET-DATA-FLOW.md` |
| "auth" / "login" / "register" | `docs/shared/auth-flow/`, `design/01-auth/` |
| "code" / "syntax highlight" | `design/03-tokens/code-theme.md` |
| "тёмная" / "light" / "theme" | `design/03-tokens/colours.md §5, §6` |
| "конвертация" / "Figma → Flutter" | `_ai/WORKFLOW.md §5`, `docs/PROMPT-TEMPLATES.md §10` |
| "промт" / "шаблон промта" | `docs/PROMPT-TEMPLATES.md` |
| "Endorse" / "Score" / "Expertise" | ⚠️ это pivot-наследие, поднять вопрос |

---

## Если не уверен — читай /CLAUDE.md

Если задача неясна, расплывчата, или ты потерялся — **`/CLAUDE.md`** даёт fastest re-grounding.
Это always-on entry-point.

После CLAUDE.md — приходишь к user с **уточняющим вопросом**, не делаешь предположений.
