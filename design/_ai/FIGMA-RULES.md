# Figma Rules

> Конкретные правила работы в Figma: pages, frames, naming, components, variants, auto-layout, styles.
> Нарушение любого правила = валидация не пройдена.

---

## 1. File structure (Pages)

Figma file должен иметь **строго эти pages** в этом порядке:

```
📄 Cover                ← title page, version, date, link to docs
📄 ⚙️ Foundations       ← tokens visualization
📄 🧩 Components        ← все master components
📄 🔀 Patterns          ← composed patterns (PostCard layouts, ProfileHeader)
📄 🖼️ Screens           ← все screens, разбиты по фичам
📄 📋 Specs             ← redlines / handoff specs (если делаем static specs)
📄 🗄️ Archive           ← старые/устаревшие версии
```

Иконка emoji в названии **только в page name**, не нарушает правило "no emoji in UI". Это organisational, не пользовательское.

### Subpages по фичам в Screens

```
🖼️ Screens
├── Auth (Login, Register)
├── Feed
├── Compose
├── Post
├── Profile
├── Search
├── Recruiter
└── Notifications
```

Каждая фича — отдельная Section (Figma section, не page) внутри Screens page.

---

## 2. Frame naming

### Screens

Format: `<Feature>/<Screen>/<Variant>/<State>`

| Example | Расшифровка |
|---------|-------------|
| `Profile/Self/Default` | Profile фича, own profile, default state |
| `Profile/Other/Following` | Profile other user в "following" state |
| `Feed/Home/Loading` | Feed фича, Home variant, loading state |
| `Compose/Modal/Empty` | Compose modal, empty state |
| `Search/Recruiter/Results` | Search фича, recruiter variant, with results |

Уровни:

- **Feature** — главная категория (matches `02-strategy/MVP-SCOPE.md` категории)
- **Screen** — конкретный экран
- **Variant** (optional) — Self/Other, Modal/Page, etc.
- **State** — Default / Loading / Empty / Error / Success

State обязателен. Если у экрана нет нескольких states — используй `Default`.

### Components

Format: `<Layer>/<Name>` для master.

| Example | Расшифровка |
|---------|-------------|
| `Atom/Avatar` | Atomic level component |
| `Atom/Button` | |
| `Atom/Input` | |
| `Atom/ScoreFigure` | |
| `Atom/TopicTag` | |
| `Atom/ComplexityBadge` | |
| `Molecule/PostCard` | Composed component |
| `Molecule/ProfileHeader` | |
| `Molecule/EndorseButton` | |
| `Organism/Feed` | Multi-molecule structure |
| `Organism/RecruiterSearchBar` | |

Layer levels:

- **Atom** — primitive (Avatar, Button, Input, Icon)
- **Molecule** — composed of atoms (PostCard, ProfileHeader)
- **Organism** — composed of molecules (Feed, ProfileScreen layout)

---

## 3. Variants — naming convention

В master component используем **variant properties** с такими именами:

| Property | Values | Example |
|----------|--------|---------|
| `state` | `default`, `hover`, `pressed`, `focused`, `disabled` | Button states |
| `variant` | (component-specific: `primary`, `secondary`, `danger`, etc.) | Button styling |
| `size` | `sm`, `md`, `lg`, `xl` | Avatar sizes |
| `theme` | `light`, `dark` | When component renders differently per theme |
| `density` | `compact`, `default` | For recruiter mode |

### Naming rules

- **Lowercase**, без пробелов
- Множественные значения через `,` в property name (Figma syntax)
- Boolean — `true`/`false` или `on`/`off`, согласовано в компоненте

### Combinations

Не плодим лишние variants. Если variant нужен только в одной комбинации (`size=lg + state=disabled`) — это **одна** комбинация в master, а не два variants.

---

## 4. Component properties

Используем все 4 типа properties Figma:

| Type | When | Example |
|------|------|---------|
| **Variant** | Discrete states (default/hover/disabled) | `state` |
| **Boolean** | Show/hide элемента | `showActions`, `hasCodeBlock` |
| **Instance swap** | Подмена вложенного instance | `iconSlot` |
| **Text** | Динамический текст | `label`, `count` |

### Naming

- camelCase: `showActions`, `iconSlot`, `label`
- Booleans с `show` / `has` prefix: `showActions`, `hasError`, `isLoading`
- Текст без prefix: `label`, `count`, `username`

---

## 5. Auto-layout — обязательно

### Правила

- **Всё через auto-layout.** Никакого absolute positioning кроме крайне редких случаев (overlays, badges позиционированные относительно parent — даже их часто делаем через flex alignment)
- **Gap = token spacing** (4, 8, 12, 16, 24, 32, 48, 64)
- **Padding = token spacing**
- **Direction:** vertical для большинства content layouts, horizontal для chips/actions rows
- **Alignment:** start / center / end / space-between — explicit, не "magic" значения
- **Fill / Hug / Fixed:** explicit per direction

### Что **не** допускается

- ❌ Frame с absolute children (если это не overlay)
- ❌ Magic spacing values (15, 17, 22 — не кратные 4)
- ❌ Margin (Figma не имеет margin — используем gap)

---

## 6. Styles vs raw values

### Colour styles

**Никогда** не используем raw hex в fill / stroke. Только colour styles.

| Style organization | Naming |
|--------------------|--------|
| `surface / surface` | (matches semantic token name) |
| `surface / surface-elevated` | |
| `surface / surface-sunken` | |
| `text / text-primary` | |
| `text / text-secondary` | |
| `accent / accent` | |
| `accent / accent-soft` | |
| `border / border-subtle` | |
| `border / border-default` | |
| `status / success` | |
| `status / error` | |
| `code / keyword` | |

### Text styles

**Все** text — через text styles.

| Style |
|-------|
| `Serif / h1` |
| `Serif / h2` |
| `Serif / h3` |
| `Serif / lead` |
| `Serif / serif-figure` |
| `Sans / body-lg` |
| `Sans / body` |
| `Sans / body-bold` |
| `Sans / caption` |
| `Sans / caption-bold` |
| `Sans / small` |
| `Sans / overline` |
| `Mono / mono-body` |
| `Mono / mono-inline` |

### Effect styles

| Style | Value |
|-------|-------|
| `elevation-1` | 0 1px 2px rgba(26,22,20,0.05) |
| `elevation-2` | 0 4px 12px rgba(26,22,20,0.08) |

Применяем редко (см. radius-elevation.md — editorial flat).

### Grid styles

| Style | Use |
|-------|-----|
| `Container / Prose 640` | Single column 640 |
| `Container / Feed 720` | Single column 720 (обновлено: используем 700 единое — TODO) |
| `Container / Recruiter 1280` | Single column 1280 |

---

## 7. Component usage

### Никаких detached instances

Если используешь компонент — это **instance**. Если нужна модификация — **variant** в master.

Detached instance = bug. Это разрывает связь с дизайн-системой, изменения не propagate.

Исключения:
- Контентные текст-блоки (тебе нужно показать конкретный пост Vlad'а)
- Скриншоты code blocks (когда контент специфический)

### Instance swap

Используй для:
- Иконок в компонентах с разными иконами (Button иконкой может быть любая)
- Avatar в карточках, ленте

Не используй для:
- Замены целого компонента — это уже другой компонент

---

## 8. Documentation внутри Figma

### Component description

Каждый master component **обязан** иметь description в Figma (доступно через right panel при выбранном master).

Шаблон:

```
PostCard

What:
Карточка поста в Bable. Используется в feed, profile, search results.

When to use:
- Feed (variant: feed)
- Profile posts list (variant: feed)
- Search results (variant: feed compact)
- Post detail (variant: detail — promoted)

Properties:
- variant: feed / detail / reply
- showActions: boolean (default true)
- hasCodeBlock: boolean
- ownPost: boolean (показывает … menu)
- liked: boolean (endorse icon active)

Tokens:
post-card-bg, post-card-divider, …

Docs:
design/04-components/post-card.md
```

---

## 9. Cover page (мандатно)

Каждый Figma file имеет Cover page:

```
┌─────────────────────────────────────┐
│                                      │
│     Bable                            │  Serif h1
│     Mobile Design System v0.1        │  Sans body-bold
│                                      │
│     Last updated: <date>             │  caption
│     Repo: design/                    │
│                                      │
│     Status: WIP / Phase: Step 4      │
│                                      │
└─────────────────────────────────────┘
```

При запросе stakeholder'а — открывают Cover, видят актуальную информацию.

---

## 10. Темы (Light + Dark)

### Подход

Используем Figma's **modes** (variables) для switching:

```
Mode: Light (default)
Mode: Dark
```

Каждый colour style имеет два значения, переключение через mode на canvas.

Component не дублируется для light/dark — он рендерится в текущем mode.

### Если modes недоступны (старые files)

Дублируй components: `Atom/Button/Light`, `Atom/Button/Dark`. Это temporary, миграция на modes — приоритет.

---

## 11. Naming для new components — гайдлайны

| Pattern | Когда |
|---------|-------|
| `ScoreFigure` | Когда визуальная "вещь" (figure = number visual) |
| `ScoreBadge` | Когда compact pill / chip |
| `ScoreRow` | Когда список scores (multi-line) |
| `ScoreExplanation` | Когда детальный modal/section |
| `Endorse**Button**` | Когда нажимается |
| `Endorse**List**` | Когда список людей |
| `Endorse**Card**` | Когда полная info карточка |

Используй consistent suffixes: `Button`, `Card`, `Row`, `List`, `Badge`, `Figure`, `Tag`, `Chip`, `Tile`, `Item`.

Не используй: `Container`, `Wrapper`, `Box`, `Element` — слишком generic.

---

## 12. Что не делать в Figma

- ❌ **Не оставлять unnamed frames** (Frame 1, Frame 2, …) — переименовывай в smart name
- ❌ **Не использовать Smart Animate** для motion — motion определяется кодом, не Figma animation
- ❌ **Не embedding code** в Figma frames как PNG — используй specs files
- ❌ **Не хранить специфический контент** (реальные имена, скриншоты постов с real data) — sample data в Lorem-style: "@vlad", "Sample post body…"
- ❌ **Не использовать Figma plugin'ы для генерации contentа** (Lorem Picsum, etc.) — это часто содержит mock data, которая лжёт о density

---

## 13. Self-check перед "сдачей" Figma frame

- [ ] Frame name соответствует convention?
- [ ] Все цвета через colour styles? (`style_apply` к style ID, **не** raw hex в `paint_set_solid` / `node_create_frame.color`)
- [ ] Все text через text styles? (`style_apply` к text style ID, **не** прямой `fontFamily`/`fontSize`)
- [ ] Auto-layout везде?
- [ ] Spacing кратно 4?
- [ ] Components — instances, не дубликаты?
- [ ] **Master — реальный component?** (вызван `component_create`, не просто фрейм)
- [ ] **Properties добавлены?** (`component_add_property_definition` для каждого variant/boolean/text/instance swap из md-spec)
- [ ] Variants documented?
- [ ] Cover page обновлён (date, status)?
- [ ] Description в master components заполнена?
- [ ] Light + Dark через modes (если включены)?

---

## 14. Common AI/MCP pitfalls

> Извлечено из ревью v0.1 (см. `REVIEW-2026-06-15-figma-v0.1.md`).
> Эти ошибки убивают design system изнутри — компоненты выглядят правильно, но связи разорваны.

### 14.1 Paint style ≠ apply

Создание `style_create_paint` не привязывает стиль к нодам. Если потом в `node_create_frame` передать `color: "#C45A3D"` — фрейм получит **raw hex**, не связь со стилем.

**Правильно:** после style — `paint_set_solid` не нужен; используем `style_apply(nodeId, styleId, "fill")`.

**Симптом:** меняешь `accent` в styles → ничего на канвасе не обновляется.

### 14.2 Frame ≠ Component

`node_create_frame` создаёт фрейм. Это **не** компонент. Без `component_create(nodeId)`:
- Нельзя сделать instance.
- Нет component properties panel.
- Нет variant override.
- Нет `label` text property, нет icon `instance swap`.

**Правильно:** после построения структуры master frame → `component_create` → `component_add_property_definition` для каждой переменной из md-spec → variant-наборы превращаются в `component_create_set`.

**Симптом:** на странице Components всё выглядит как компоненты, но в Screens их не получается переиспользовать.

### 14.3 Text style ≠ font apply

То же что 14.1, но для текста. `style_create_text` создаёт описание (description), но **не** загружает шрифт. Применение к ноде — через `style_apply(textNodeId, textStyleId, "text")`.

**Правильно:** в начале сессии — `text_list_fonts` → понять, что загружено → `text_load_font` для нужных. После создания text styles — `style_apply` на каждом `text_create`.

### 14.4 Tokens page обновляется **первой**, не последней

При смене палитры/типографики первое действие — перерисовать визуальные swatches на странице Tokens. Иначе дизайнер видит старую палитру и думает, что она актуальная. **File lies.**

### 14.5 MCP не удаляет styles

`style_remove` удаляет binding со стилем у ноды, **не** сам стиль. Удаления локальных стилей через MCP **нет**. Если меняем палитру:

1. **До** начала работ — предупредить пользователя.
2. Попросить вручную удалить старые styles через Figma UI (right panel → Local styles).
3. **Только потом** заливать новую палитру.

Никогда не делать "новое поверх старого" — оба набора будут жить параллельно.

### 14.6 Property contract из md-spec

Каждый property из `04-components/*.md` §2 (Properties) обязан стать соответствующей сущностью в Figma:

| md-spec type | Figma property |
|--------------|----------------|
| `variant` | Variant property (`state`, `variant`, `size`) |
| `boolean` | Boolean property (`hasLeadingIcon`, `fullWidth`) |
| `text` | Text property (`label`, `username`, `value`) |
| `instance swap` | Instance swap property (`leadingIcon`, `trailingIcon`) |

Spec template из `04-components/README.md` — это **чек-лист**. Если в Figma не хватает property — значит spec не реализован.

### 14.7 Sections + descriptions для discoverability

Страница `🧩 Components` без структуры — это свалка. Обязательно:

- **Figma Sections** по layer: `Atoms` / `Molecules` / `Organisms`.
- **Index frame** наверху страницы со списком всех компонентов и их статусом (`draft` / `in-figma` / `shipped`).
- **Description** у каждого master по шаблону из §8 — с tags для поиска через Figma search.

Без этого дизайнер не находит то, что уже есть, и создаёт дубликаты.

### 14.8 Atomic order: atom → molecule → organism

Molecules создаются **только после** того, как atoms — настоящие компоненты (см. 14.2). Иначе Avatar внутри `PostCard` будет клоном, а не instance. Single source of truth сломан.

### 14.9 Honest deliverables

Если spec говорит "72 variants" — либо честно делаем 72, либо в начале явно объявляем Tier 1 / Tier 2 split. **"Полный паспорт" должен означать полный паспорт.** Не "44% от полного, потому что устал".

### 14.10 Pre-flight checklist

В начале каждой Figma-сессии через MCP:

```
1. document_get_info        — какой это файл, на какой странице
2. page_get_all             — структура страниц
3. text_list_fonts          — какие шрифты загружены
4. variable_get_collections — какие variables уже есть
5. style_get_all            — какие styles уже есть
```

Без этого — слепое программирование Figma.
