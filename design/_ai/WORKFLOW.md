# Workflow — Стандартные процедуры

> Как делать стандартные задачи: draw screen, create component, extend, validate.
> Каждая процедура — пошаговая, без shortcut'ов.
> Если думаешь "можно пропустить шаг" — нельзя.

---

## Принцип

**Read → Plan → Execute → Self-validate → Hand off.** В этом порядке. Если skip — будут баги.

```
1. Read     ← собрать контекст
2. Plan     ← описать что собираешься делать
3. Execute  ← создать в Figma / files
4. Validate ← проверить себя
5. Hand off ← вернуть с deltas + open questions
```

---

## Workflow 1 — Draw a Screen

### Trigger

User говорит: "Нарисуй экран X" / "/draw-screen <name>" / "Сделай Profile screen".

### Step 1 — Read context

Минимум:
- `_ai/AGENT.md` (если новая сессия)
- `00-brief/VISION.md`
- `00-brief/COPY-GUIDE.md`
- `02-strategy/MVP-SCOPE.md` — найти этот экран в списке
- `03-tokens/colours.md` — semantic + component tokens
- `03-tokens/typography.md`
- `03-tokens/spacing.md`
- `03-tokens/icons.md`
- `03-tokens/component-tokens.md` — для компонент-tokens
- `04-components/` — все компоненты, которые могут быть на этом экране (если папка существует)

См. `_ai/CONTEXT-MAP.md` § "Draw a screen" для точного списка по типу экрана.

### Step 2 — Plan

Перед созданием Figma frames — пиши план:

```
Screen: ProfileScreen (developer self-view)

States I'll create:
- [ ] Default (loaded data, scores visible)
- [ ] Loading (skeleton)
- [ ] Empty (no posts yet)
- [ ] Error (failed to fetch)

Components I need:
- ✅ Avatar (exists, size xl)
- ✅ ScoreFigure (exists)
- ✅ PostCard (exists, feed variant)
- 🟡 ProfileHeader (NOT exist — need to create or compose from atoms)
- ✅ Button (exists, secondary variant for Edit profile)

Layout:
- Container: `container-prose` 640px max width (desktop), full-width mobile
- Vertical rhythm: `space-7` from top → header → space-6 → scores → space-6 → posts list
- Mobile: padding-x `space-3` (12), desktop centered

Tokens used:
- surface (page bg)
- text-primary (name)
- text-secondary (handle, timestamp)
- accent (CTA for Edit, не для scores)
- serif-figure for score numbers
- score-figure-color (component token)

Copy:
- Page title: just "@<username>" in top bar
- Display name: serif h1
- Empty state copy: per COPY-GUIDE.md "Profile (own, no posts)" → "Write your first post."
- Error: "Couldn't load profile. Retry."

Open questions:
- ProfileHeader component не существует. Создать как новый molecule или собрать на screen-level?
- Score row layout — горизонтальный или вертикальный для self-profile vs other-profile?

Validation я проверю по checklist в Step 4.
```

User должен согласиться с планом **до** того как ты начнёшь рисовать. Не молчи и не делай "тихо".

### Step 3 — Execute

В Figma (через MCP или plugin):

1. Создай **одну** page для screen, если ещё нет: `Screens / Profile`
2. Создай frame для каждого state (см. FIGMA-RULES.md naming):
   - `Profile/Self/Default`
   - `Profile/Self/Loading`
   - `Profile/Self/Empty`
   - `Profile/Self/Error`
3. Используй **только token styles** и **existing components**:
   - Colour styles — все из `colours.md` (semantic слой)
   - Text styles — из `typography.md`
   - Spacing — через auto-layout с `space-N` значениями
4. **Никогда** не вставляй raw hex или raw px значения. Если нужны — поднимай вопрос.
5. **Не дублируй** компоненты — используй instances. Если нужен variant, который не существует — добавь variant в master, не отрывай instance.

### Step 4 — Self-validate

Прогони через checklist (см. также `_ai/CONTEXT-MAP.md` § Validation):

#### Tokens
- [ ] Все цвета — через colour styles, raw hex отсутствует
- [ ] Все шрифты — через text styles
- [ ] Все spacing — кратны 4, через auto-layout
- [ ] Все radius — из шкалы (`radius-none/xs/sm/md/lg/full`)
- [ ] Все иконки — Phosphor Regular, из `icons.md` canonical list

#### Anti-patterns (`01-research/anti-patterns.md`)
- [ ] Нет emoji в UI chrome
- [ ] Нет shadows вместо surface/border
- [ ] Нет streaks / badges as trophies
- [ ] Нет follower count на первом плане
- [ ] Нет self-declared skill labels
- [ ] Нет "Welcome back!" приветствий
- [ ] Нет recruiter mass-templated UI

#### Positive patterns (`01-research/positive-patterns.md`)
- [ ] Каждое число имеет explanation path
- [ ] Score контекстный (`Rust 720`, не `720`)
- [ ] Endorser identity visible (когда показываем endorsements)
- [ ] Type-driven hierarchy (не через цвет)
- [ ] One accent action на экран
- [ ] Empty state имеет действие
- [ ] Errors объяснимы + actionable

#### Copy (`00-brief/COPY-GUIDE.md`)
- [ ] Buttons — глагол императив
- [ ] Errors — факт + действие
- [ ] Empty — факт + опц. действие
- [ ] Никаких из banlist 20+ фраз

#### A11y
- [ ] Контраст body на surface — verified
- [ ] Touch targets ≥ 44px
- [ ] Focus rings указаны (хотя бы для primary CTA)
- [ ] Caption text ≥ 14px, body ≥ 16px

#### Состояния
- [ ] Все 4 state'а (default / loading / empty / error)
- [ ] Optimistic UI описано (где применимо)

### Step 5 — Hand off

Возвращай user:

```
Screen: ProfileScreen (developer self-view)

Created frames:
- Profile/Self/Default
- Profile/Self/Loading
- Profile/Self/Empty
- Profile/Self/Error

New components/variants added:
- ProfileHeader (new molecule) — see 04-components/profile-header.md

Tokens used: surface, text-primary, text-secondary, accent, serif-figure, score-figure-color, button-secondary-bg, …

Self-validation:
- Passed: 28/30 checks
- Open: score layout (vertical chosen — verify with you)
- Open: ProfileHeader naming (named `MoleculeProfileHeader` — verify)

Open questions:
- Should bio be limited to N lines with "... see more" or full?
- Where does "Edit profile" sit on mobile — header or below?
```

---

## Workflow 2 — Create a Component

### Trigger

User говорит: "Создай компонент X" / "/create-component <name>".

### Step 1 — Read

Минимум:
- `_ai/AGENT.md`
- `02-strategy/MVP-SCOPE.md` — нужен ли вообще в MVP?
- `03-tokens/component-tokens.md` — есть ли component-token для него?
- `04-components/` — что уже существует (избегаем дубликатов)
- Где в UI он применяется — какие screens нужны для понимания контекста

### Step 2 — Plan

```
Component: PostCard (organism)
Layer: molecule (composed of atoms)

Composed of:
- Avatar (size md)
- Username text (body-bold)
- Handle (caption, text-secondary)
- Timestamp (caption, text-secondary)
- Post body (body-lg)
- TopicTag chip
- ComplexityBadge
- ActionRow (icons + counts)

Variants:
- variant: feed (compact, padded space-4)
- variant: detail (promoted, padded space-5)
- variant: reply (indented, smaller avatar)

Properties (boolean / instance swap):
- showActions (default true; false for embedded mode)
- showCodeBlock (true if post has code)
- ownPost (true → adds menu with Edit/Delete)
- liked (true → endorse icon active)

States within variants:
- default
- pressed (overlay)
- loading (skeleton variant separately)

Component tokens used:
- post-card-bg
- post-card-divider
- post-card-padding-y/x
- post-card-author-name
- post-card-actions-color-default/active

Open questions:
- Should reply variant include parent post snippet? Or solo?
- Hover state — `hover-overlay` или нет hover для editorial?
```

### Step 3 — Execute

1. Создай master component в Figma page `Components / Molecules / PostCard`
2. Используй **auto-layout** на всех уровнях — никаких absolute positioning
3. Свойства как **component properties** (boolean / instance swap / text)
4. Variants как **variant properties** (state, density, role)
5. Каждый sub-element ссылается на token styles
6. Никаких detached instances внутри
7. Документ внутри (Figma description) — что компонент, какие variants, где использовать

### Step 4 — Self-validate

#### Component structure
- [ ] Все sub-elements через auto-layout
- [ ] Все atoms — instances существующих, не дубликаты
- [ ] Variants именованы по convention (см. FIGMA-RULES.md)
- [ ] Properties именованы по convention
- [ ] Description в Figma описывает usage

#### Tokens
- [ ] Все цвета — token styles
- [ ] Все text — text styles
- [ ] Spacing — auto-layout gaps кратны 4
- [ ] Component tokens используются (не semantic напрямую)

#### MVP alignment
- [ ] Компонент решает 🟢 MVP job из jtbd.md
- [ ] Нет visual conflict с editorial direction
- [ ] Использует только Phosphor icons

### Step 5 — Hand off

Возвращай:

```
Component: PostCard

Added to: Components / Molecules / PostCard

Variants: feed (default), detail, reply
Properties: showActions, showCodeBlock, ownPost, liked
Used token: post-card-bg, post-card-divider, …

Documented in: design/04-components/post-card.md

Self-validation: 14/14 passed

Open: reply variant snippet handling
```

---

## Workflow 3 — Extend a Component

### Trigger

"Добавь variant X к Y" / "/extend-variant Button danger".

### Step 1 — Read

- AGENT.md
- Существующий компонент (`04-components/<name>.md`)
- `component-tokens.md` — есть ли подходящий token для нового variant'а

### Step 2 — Plan

```
Extend: Button
New variant: danger

Why: For destructive actions (Delete post, Delete account, Logout confirm).

Tokens to add (if missing):
- button-danger-bg → error
- button-danger-bg-hover → ? (нет error-hover в semantic — нужно добавить или использовать accent-hover нелогично)
- button-danger-text → #FFFFFF

Changes to master:
- Add variant: danger
- Existing instances НЕ ломаются (variant добавляется)

Where used:
- ConfirmDialog destructive action
- Profile settings "Delete account" link
- Post menu "Delete"

Open: нужен ли button-danger-bg-hover token? Если да — добавить в colours.md
```

### Step 3 — Execute

- Open master component
- Add variant via Properties panel
- Use new component tokens (если нужны — сначала добавь их в `component-tokens.md`)
- Update Figma description с новым variant'ом

### Step 4 — Validate

- [ ] Existing instances renderятся правильно (variant добавлен, не заменён)
- [ ] Naming variants консистентно (lowercase, как остальные)
- [ ] Component tokens documented

### Step 5 — Hand off

```
Button: added variant `danger`

New component tokens:
- button-danger-bg → error
- button-danger-bg-hover → NEW: error-hover (#... added to colours.md)
- button-danger-text → #FFFFFF

Existing instances: 0 changes
New variant available for: ConfirmDialog, account settings, post menu

Files updated:
- 04-components/button.md
- 03-tokens/component-tokens.md
- 03-tokens/colours.md (added error-hover token)
```

---

## Workflow 4 — Validate a Screen / Component

### Trigger

"Проверь экран X" / "/validate-screen <name>".

### Step 1 — Read

- AGENT.md
- Все 5 baseline (VISION, PRINCIPLES, COPY, tokens)
- Конкретный артефакт для проверки

### Step 2 — Run checklist

См. полный checklist из Workflow 1 Step 4 + специфические для типа:

| Type | Спец-checklist |
|------|---------------|
| Screen | All 4 states present? Mobile adaptation? |
| Component | Auto-layout everywhere? Variants consistent? |
| Copy | Через COPY-GUIDE banlist? |
| Token | Используется semantic, не primitive? |

### Step 3 — Output

Список нарушений с конкретными цитатами:

```
ProfileScreen / Default — violations:

1. [tokens/colours.md §5] Header bg использует raw #FFFFFF — должен быть surface-elevated (#FDFAF5)
2. [01-research/anti-patterns.md AP-2.1] Follower count показан в profile header как primary metric — должен быть secondary
3. [00-brief/COPY-GUIDE.md §10] Button label "Get started!" в banlist — заменить на "Sign up"
4. [03-tokens/typography.md §2] Score number использует `body-bold` — должен быть `serif-figure`
5. [01-research/positive-patterns.md PP-1.3] Endorsement list не показывает endorser identity — добавить avatar + score

Suggestion: исправь п.1-3 как обязательные, п.4-5 повышают качество.
```

### Step 4 — Hand off

Не "fix it" silently. Возвращай list и спрашивай user'а что фиксить.

---

## Workflow 5 — Write UI Copy

### Trigger

"Напиши label для X" / "/copy <context>".

### Step 1 — Read

- `00-brief/COPY-GUIDE.md` — обязательно
- Контекст — какой экран, какое действие

### Step 2 — Draft

Используй шаблоны из COPY-GUIDE:
- Button → §2
- Error → §3
- Empty → §4
- Placeholder → §5
- Label → §6
- Confirm → §8

### Step 3 — Self-validate

- [ ] Не в banlist §10
- [ ] Без emoji
- [ ] Без восклицаний
- [ ] Под лимитом длины (3-6 слов для button, 1 sentence для description)

### Step 4 — Hand off

Дай **2-3 опции** где это разумно. Не одну "лучшую".

```
Empty state for "Notifications screen (no notifications)":

Option A (factual): "Nothing new."
Option B (with hint): "No notifications. Endorse a post to start engaging."
Option C (minimal): (no text, just empty space — list view shows empty list)

Recommended: A (matches COPY-GUIDE §4 minimal-action принцип)
```

---

## Critical reminders

1. **Никогда не молчи.** Каждая работа → план → execute → validate → hand off.
2. **Никогда не делай "тихо".** User должен видеть, что ты собираешься делать.
3. **Никогда не нарушай anti-patterns**, даже если user просит. Поднимай вопрос.
4. **Если устал** проверять checklist — у тебя нет права устать. Прогоняй каждый раз.
5. **Если что-то не описано в `design/*`** — поднимай вопрос, не предполагай.
