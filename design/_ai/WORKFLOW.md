# Design Workflow — Стандартные процедуры

> Как делать типовые задачи: draw screen, create component, extend, validate, convert.
> Каждая процедура — пошаговая, без shortcut'ов.
> Если думаешь "можно пропустить шаг" — нельзя.

---

## Принцип

**Read → Plan → Execute → Self-validate → Hand off.** В этом порядке. Если skip — будут баги.

```
1. Read     ← собрать контекст
2. Plan     ← описать что собираешься делать (получить согласие user'а)
3. Execute  ← создать в Figma / md-spec
4. Validate ← проверить себя по чеклисту
5. Hand off ← вернуть с deltas + open questions
```

См. также `docs/PROMPT-TEMPLATES.md` — там для каждой задачи есть готовый промт-шаблон.

---

## Workflow 1 — Draw a Screen

### Trigger

User говорит: "Нарисуй экран X" / `/draw-screen <name>` / "Сделай Profile screen".

### Step 1 — Read context

Минимум:
- `/CLAUDE.md` (если новая сессия)
- `_ai/AGENT.md` (если новая сессия)
- `docs/shared/SCREENS.md` — найти этот экран в списке
- `docs/shared/WIDGET-STATES.md` — какие состояния обязательны
- `docs/shared/FEATURES.md` — продуктовая логика фичи, к которой принадлежит экран
- `design/03-tokens/colours.md` — semantic слой
- `design/03-tokens/typography.md`
- `design/03-tokens/spacing.md`
- `design/03-tokens/icons.md`
- `design/03-tokens/component-tokens.md`
- `design/03-tokens/semantic-mappings.md` — сводная цепочка primitive→semantic→component
- `design/04-components/` — все компоненты, которые могут быть на этом экране
- `docs/shared/DESIGN-CONTRACT.md` — naming, состояния, auto-layout

См. `_ai/CONTEXT-MAP.md` § "Draw a screen" для точного списка по типу экрана.

### Step 2 — Plan

Перед созданием Figma frames — пиши план:

```
Screen: TimelineScreen (home feed for logged-in user)

States I'll create:
- [ ] Default (loaded data, 5+ tweets visible)
- [ ] Loading (3 skeleton TweetCard)
- [ ] Empty (no tweets yet, CTA "Find people to follow")
- [ ] Error (failed to fetch, retry button)
- [ ] LoadingMore (spinner at bottom of list)

Components I need:
- ✅ Avatar (exists, size md = 40)
- ✅ Button (exists, primary variant for CTA)
- 🟡 TweetCard (NOT exists yet — нужно создать как molecule перед screen'ом)
- 🟡 TopBar (NOT exists — atom-level)
- 🟡 BottomTabBar (NOT exists — molecule)

Layout:
- Mobile 390×844 base
- Vertical rhythm: top bar 56 → list → bottom bar 56
- List: padding-x space-4 (16), divider border-subtle между постами
- Empty/Error: centered, space-9 (96) padding-y

Tokens used (через semantic):
- surface (page bg)
- surface-elevated (cards)
- text-primary, text-secondary
- accent (CTA "Find people")
- border-subtle (dividers)

Copy (из docs/shared/ или CLAUDE.md, не от себя):
- Empty: "No tweets yet. Follow someone to see their posts here."
- Error: "Couldn't load timeline. Retry."
- CTA: "Find people"

Open questions:
- TweetCard component не существует. Создаём как отдельную задачу до этого экрана
  или собираем inline в этом задании?
- Top bar: только логотип или поиск тоже на mobile?

Validation я проверю по чеклисту в Step 4.
```

User должен согласиться с планом **до** того как ты начнёшь рисовать. Не молчи и не делай "тихо".

### Step 3 — Execute

В Figma (через MCP или plugin):

1. Создай **одну** Page для screen, если ещё нет: `Screens / Timeline`
2. Создай frame для каждого state (см. `FIGMA-RULES.md` naming):
   - `Timeline/Default`
   - `Timeline/Loading`
   - `Timeline/Empty`
   - `Timeline/Error`
   - `Timeline/LoadingMore`
3. Используй **только token styles** и **existing components**:
   - Colour styles — все из `colours.md` (semantic слой)
   - Text styles — из `typography.md`
   - Spacing — через auto-layout с `space-N` значениями
4. **Никогда** не вставляй raw hex или raw px. Если нужны — поднимай вопрос.
5. **Не дублируй** компоненты — используй instances. Если нужен variant, который не существует —
   добавь variant в master через отдельную задачу (см. Workflow 3).
6. Naming layers — по `docs/shared/DESIGN-CONTRACT.md §1` (Figma layer name = code class name).

### Step 4 — Self-validate

#### Tokens
- [ ] Все цвета — через colour styles, raw hex отсутствует
- [ ] Все шрифты — через text styles
- [ ] Все spacing кратны 4, через auto-layout
- [ ] Все radius — из шкалы (`radius-none/xs/sm/md/lg/full`)
- [ ] Все иконки — Phosphor Regular, из `design/03-tokens/icons.md` canonical list
- [ ] Никаких Twitter-blue (`#1DA1F2`), даже если попадается в legacy примерах

#### Состояния
- [ ] Все обязательные states (Default / Loading / Empty / Error)
- [ ] LoadingMore — если экран = список
- [ ] Each state — отдельный frame в правильной Page

#### Anti-patterns
- [ ] Нет emoji в UI chrome
- [ ] Нет shadows вместо surface/border
- [ ] Нет gradient backgrounds
- [ ] Нет pivot-сущностей (`Endorse`, `Score`, `Expertise`, `Recruiter view`)
- [ ] Нет Material/SF Symbols/FontAwesome иконок

#### Copy
- [ ] Buttons — глагол в императиве
- [ ] Errors — факт + действие
- [ ] Empty — факт + опц. действие
- [ ] Никаких маркетинговых "Welcome back!" / "Get started!"

#### A11y
- [ ] Контраст body на surface — verified (см. `colours.md §7`)
- [ ] Touch targets ≥ 44px
- [ ] Focus rings указаны (хотя бы для primary CTA)
- [ ] Caption text ≥ 14px, body ≥ 16px

#### Naming и структура
- [ ] Frame names совпадают с `DESIGN-CONTRACT.md §1`
- [ ] Auto-layout везде, нет absolute positioning без нужды
- [ ] Components — instances, не detached

### Step 5 — Hand off

Возвращай user:

```
Screen: TimelineScreen

Created frames:
- Timeline/Default
- Timeline/Loading
- Timeline/Empty
- Timeline/Error
- Timeline/LoadingMore

New components/variants added:
- TweetCard (new molecule) — см. design/04-components/molecules/tweet-card.md
- TopBar (new atom) — см. design/04-components/atoms/top-bar.md

Tokens used: surface, surface-elevated, text-primary, text-secondary, accent,
  border-subtle, …

Self-validation:
- Passed: 24/26 checks
- Open: Top bar search-icon — нужен ли на mobile или только в search-screen?
- Open: TweetCard reply-snippet — пока без, добавим если будет reply-feature

Open questions for user:
- Подтверди TweetCard molecule создан правильно (см. spec)
- Confirm bottom-bar 5 табов vs 4
```

---

## Workflow 2 — Create a Component

### Trigger

User говорит: "Создай компонент X" / `/create-component <name>`.

### Step 1 — Read

Минимум:
- `_ai/AGENT.md`
- `design/04-components/README.md` — Tier-priority и spec template
- `design/03-tokens/component-tokens.md` — есть ли token для него?
- `design/03-tokens/semantic-mappings.md` — для маппинга в цепочку
- `design/04-components/` — что уже существует (избегаем дубликатов)
- `docs/shared/DESIGN-CONTRACT.md §1, §7, §8` — naming, text styles, variants

### Step 2 — Plan

```
Component: TweetCard
Layer: molecule (composed of atoms)

Composed of:
- Avatar (size md)
- Username text (body-bold)
- Handle (caption, text-secondary)
- Timestamp (caption, text-secondary)
- Tweet body (body-lg)
- ActionRow (icons + counts: like, reply, retweet, share)

Variants:
- variant: feed (compact, padded space-4)
- variant: detail (promoted, padded space-5)
- variant: reply (indented, smaller avatar)

Properties (boolean / instance swap):
- showActions (default true; false for embedded mode)
- hasMedia (false default; true → reserve media slot)
- ownTweet (true → adds menu with Delete)
- liked (true → like icon active state)

States within variants:
- default
- pressed (overlay)
- skeleton (separate variant)

Component tokens used (existing):
- post-card-bg → surface-elevated
- post-card-divider → border-subtle
- post-card-padding-y/x
- post-card-author-name / handle / timestamp
- post-card-actions-color-default/active

Open questions:
- Reply variant — показывать parent tweet snippet?
- Hover state на mobile — нет; на web — `hover-overlay`?
```

### Step 3 — Execute

1. Создай master component в Figma page `Components / Molecules / TweetCard`
2. **Auto-layout** на всех уровнях — никаких absolute positioning
3. Свойства как **component properties** (boolean / instance swap / text)
4. Variants как **variant properties** (state, density, role)
5. Каждый sub-element ссылается на token styles из `colours.md` / `typography.md`
6. Никаких detached instances внутри
7. Description в Figma — что компонент, какие variants, где использовать
8. Создай md-spec по template из `design/04-components/README.md` §"Spec template"

### Step 4 — Self-validate

#### Component structure
- [ ] Все sub-elements через auto-layout
- [ ] Все atoms — instances существующих, не дубликаты
- [ ] Variants именованы по convention (см. `FIGMA-RULES.md`)
- [ ] Properties именованы по convention
- [ ] Description в Figma описывает usage

#### Tokens
- [ ] Все цвета — token styles
- [ ] Все text — text styles
- [ ] Spacing — auto-layout gaps кратны 4
- [ ] Component tokens используются (не semantic напрямую)
- [ ] Если добавил новый component-token → обновил `component-tokens.md` И `semantic-mappings.md`

#### Spec md
- [ ] Все 8 секций заполнены (Anatomy, Properties, Variants, States, Behaviour, Token references, A11y, Do/Don't)
- [ ] A11y: role, aria-label, keyboard, focus
- [ ] Don't section не пустая

### Step 5 — Hand off

```
Component: TweetCard

Added to: Components / Molecules / TweetCard (Figma)
Spec: design/04-components/molecules/tweet-card.md

Variants: feed (default), detail, reply, skeleton
Properties: showActions, hasMedia, ownTweet, liked
Tokens used: post-card-bg, post-card-divider, post-card-padding-y/x, …

New tokens added: (none / list if any) — обновил semantic-mappings.md

Self-validation: 14/14 passed

Open: reply variant snippet handling — solo или с parent snippet?
```

---

## Workflow 3 — Extend a Component

### Trigger

"Добавь variant X к Y" / `/extend-variant Button danger`.

### Step 1 — Read

- `_ai/AGENT.md`
- Существующий component spec (`design/04-components/atoms/<name>.md` или `molecules/`)
- `design/03-tokens/component-tokens.md` — есть ли подходящий token

### Step 2 — Plan

```
Extend: Button
New variant: danger

Why: For destructive actions (Delete tweet, Logout confirm).

Tokens needed:
- button-danger-bg → error
- button-danger-bg-hover → ?  ← нет error-hover в semantic, нужно добавить
- button-danger-text → #FFFFFF (через `text-on-accent`)

Changes:
- Master component: добавить variant `danger`
- Existing instances НЕ ломаются (variant добавляется, не заменяется)
- design/03-tokens/colours.md: добавить semantic `error-hover` (brick-600)
- design/03-tokens/component-tokens.md: добавить button-danger-bg-hover
- design/03-tokens/semantic-mappings.md: добавить строку в §1 Button

Where used:
- ConfirmDialog destructive action
- Tweet menu "Delete"
- Profile settings "Logout"

Open: нужен ли отдельный focus-ring-error для button-danger или общий focus-ring?
```

### Step 3 — Execute

- Открой master component в Figma
- Add variant через Properties panel
- Использовать новые component tokens (если нужны — сначала добавь их в `component-tokens.md`
  и `semantic-mappings.md` одной правкой)
- Update Figma description
- Update component spec md (`design/04-components/atoms/button.md`)

### Step 4 — Validate

- [ ] Existing instances renderятся правильно (variant добавлен, не заменён)
- [ ] Naming variants консистентно (lowercase, как остальные)
- [ ] Component tokens documented
- [ ] semantic-mappings.md обновлён
- [ ] Spec md обновлён (Variants section)

### Step 5 — Hand off

```
Button: added variant `danger`

New component tokens (added to component-tokens.md):
- button-danger-bg → error
- button-danger-bg-hover → error-hover (NEW semantic)
- button-danger-text → text-on-accent

New semantic added to colours.md: error-hover (light: brick-600 #8B2D24 / dark: brick-300 #D8615E)

Existing instances: 0 changes
New variant available for: ConfirmDialog, tweet menu, profile settings

Files updated:
- design/04-components/atoms/button.md
- design/03-tokens/colours.md
- design/03-tokens/component-tokens.md
- design/03-tokens/semantic-mappings.md
```

---

## Workflow 4 — Validate a Screen / Component

### Trigger

"Проверь экран X" / `/validate-screen <name>` / "Сделай ревью этого Figma frame".

### Step 1 — Read

- `_ai/AGENT.md`
- `design/03-tokens/` (8 файлов — для проверки токенов)
- `docs/shared/DESIGN-CONTRACT.md` — naming, states, icons
- Конкретный артефакт для проверки

### Step 2 — Run checklist

Используй чеклист из Workflow 1 Step 4. Дополнительно для типа:

| Type | Спец-checklist |
|------|---------------|
| Screen | All обязательные states? Mobile-first размеры? Naming пейджей? |
| Component | Auto-layout everywhere? Variants consistent? Description заполнено? |
| Copy | Banlist слов? Императив в кнопках? Без emoji? |
| Token usage | Только semantic в компонентах? Только component-token в master'ах? Нет hex? |

### Step 3 — Output

Список нарушений с конкретными цитатами:

```
TimelineScreen / Default — violations:

| 🔴 | Header bg | raw hex `#FFFFFF` | colours.md §5 | use semantic `surface-elevated` |
| 🔴 | TweetCard | использует Material `Icons.favorite` | icons.md, ICON-STRATEGY.md | use Phosphor `Heart` via UiIcon |
| 🟡 | Empty CTA | label "Get started!" | DESIGN-CONTRACT.md / copy banlist | replace "Find people" |
| 🟡 | Avatar size | 32px | component-tokens.md avatar-size-md=40 | scale to 40 |
| 🟢 | Top bar | без focus ring | a11y | add focus indicator |

Recommendation: fix 🔴 before merge; 🟡 high priority; 🟢 best-effort.
```

### Step 4 — Hand off

Не "fix it" silently. Возвращай list и спрашивай user'а, что фиксить.

---

## Workflow 5 — Figma → Code spec

### Trigger

"Сконвертируй этот Figma node в Flutter" / `/figma-to-code <node-id>`.

### Step 1 — Read

- `_ai/AGENT.md`
- `docs/shared/DESIGN-CONTRACT.md §1` (naming convention)
- `design/03-tokens/semantic-mappings.md` (mapping table)
- `docs/flutter/ICON-STRATEGY.md` (для иконок)
- `docs/flutter/ARCHITECTURE_RULES.md` (где лежит UI код)
- Целевой пакет — `packages/ui_kit/lib/src/` для атомов, `apps/chirp/lib/features/` для feature-виджетов
- См. `docs/PROMPT-TEMPLATES.md §10` для готового промта

### Step 2 — Plan

```
Figma node: Components/Atoms/Button (variant=primary, state=default)
Target: packages/ui_kit/lib/src/buttons/ui_button.dart

Mapping:
- Frame → class UiButton extends StatelessWidget
- variant property → enum UiButtonVariant { primary, secondary, text, danger }
- size property → enum UiButtonSize { compact, default_, large }
- BG fill `button-primary-bg` → context.colors.buttonPrimaryBg
- Label text style `Button (15/600)` → context.typography.button
- Padding-x 16, height 40 → const EdgeInsets.symmetric(horizontal: Spacing.lg)
- Border-radius `radius-sm` (4) → BorderRadius.circular(Radius.sm)
- Focus ring `focus-ring` → FocusRing widget

Иконки в кнопке (если есть leading/trailing):
- UiIcon(UiIcons.<name>, size: UiIconSize.sm)
- Никаких Icons.foo

Open: disabled-state — opacity или отдельный bg? → `button-primary-bg-disabled` = `disabled-bg`, явный bg
```

### Step 3 — Execute

- Создай или обнови файл по target path
- Никакого hex / px / font-family в коде
- Все semantic — через `context.colors.*` extension
- Иконки через `UiIcon(UiIcons.*, size: UiIconSize.*)`
- Проверь, что есть ассеты для иконок в `packages/ui_kit/assets/icons/`

### Step 4 — Validate

- [ ] Нет hex-литералов в файле
- [ ] Нет magic px (только 0/1, остальное через токены)
- [ ] Все state'ы реализованы (default/hover/pressed/disabled/focused)
- [ ] Semantic widget c label/role
- [ ] Golden test (если есть в проекте) — diff < 3 px
- [ ] `flutter analyze` зелёный
- [ ] `dart format` применён

### Step 5 — Hand off

```
Created: packages/ui_kit/lib/src/buttons/ui_button.dart
Spec sync: design/04-components/atoms/button.md (no changes — code следует за дизайном)

Mapping table:
| Figma part | Code |
| BG primary | context.colors.buttonPrimaryBg |
| Label | context.typography.button |
| ...

Tokens used: 7 component-tokens (все существующие)
New assets: (none)
Tests: golden + a11y

Open: leading-icon convention — spacing.sm между иконкой и текстом? Confirm.
```

---

## Workflow 6 — Code → Figma master

### Trigger

"Сделай Figma master по этому виджету" / `/code-to-figma <path>`.

### Step 1 — Read

- `_ai/AGENT.md`
- Целевой файл (.dart / .tsx / .swift)
- `docs/shared/DESIGN-CONTRACT.md` (naming)
- `design/03-tokens/` (для нахождения соответствующих styles)
- См. `docs/PROMPT-TEMPLATES.md §11`

### Step 2 — Plan

Mapping code → Figma в плане (props → properties/variants, hex → semantic styles, и т.д.).

### Step 3 — Execute

Создаёшь Figma master через MCP. Каждый visible part = именованный layer.
Layer naming совпадает с code class name (см. `DESIGN-CONTRACT.md §1`).

### Step 4 — Validate

- [ ] Variants покрывают все state-enum'ы кода
- [ ] Token-references вместо raw values (если в коде была magic — отметить как открытый вопрос)
- [ ] Component description заполнено

### Step 5 — Hand off

Возвращаешь mapping + расхождения, которые потребовали интерпретации.

---

## Workflow 7 — Write UI Copy

### Trigger

"Напиши label для X" / `/copy <context>`.

### Step 1 — Read

- `docs/shared/ERRORS.md` (для error messages)
- `docs/shared/SCREENS.md` (для empty states)
- Контекст — какой экран, какое действие

### Step 2 — Draft

Принципы:
- **Buttons:** глагол в императиве (Save, Cancel, Find people)
- **Errors:** факт + действие ("Couldn't load. Retry.")
- **Empty:** факт + опц. действие ("No tweets yet. Find people to follow.")
- **Placeholder:** что вводить, без "please" ("Email", не "Please enter your email")
- **Confirm:** что произойдёт, явно ("Delete tweet?" + "Delete" / "Cancel")

### Step 3 — Self-validate

- [ ] Не банлист ("Welcome back!", "Get started!", "Awesome!", "Oops!", emoji)
- [ ] Под лимитом длины (3-6 слов для button, 1 sentence для description)
- [ ] Без восклицаний
- [ ] Без passive voice ("This will be deleted" → "Delete this?")

### Step 4 — Hand off

Дай **2-3 опции** где это разумно. Не одну "лучшую".

```
Empty state for "Timeline (logged-in, not following anyone)":

Option A (factual): "Your timeline is empty."
Option B (with hint): "Follow people to see their tweets here."
Option C (with CTA): "Follow people to see their tweets here." + button "Find people"

Recommended: C — следует pattern "empty state = факт + действие".
```

---

## Critical reminders

1. **Никогда не молчи.** Каждая работа → план → execute → validate → hand off.
2. **Никогда не делай "тихо".** User должен видеть, что ты собираешься делать.
3. **Никогда не возвращай pivot-сущности** (`Endorse`, `ScoreFigure`, `Expertise`). Если задача требует — переспроси, нужен ли возврат к концепции.
4. **Никогда не используй Twitter-blue палитру** (`#1DA1F2` и т.п.), даже если она встречается в legacy `docs/shared/DESIGN-SYSTEM.md` примерах.
5. **Если устал** проверять чеклист — у тебя нет права устать. Прогоняй каждый раз.
6. **Если что-то не описано в `design/*` или `docs/shared/`** — поднимай вопрос, не предполагай.

Promt-шаблоны на каждый workflow — `docs/PROMPT-TEMPLATES.md`.
