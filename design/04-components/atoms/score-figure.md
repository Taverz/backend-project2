# ScoreFigure

**Layer:** atom
**Figma:** `Atom/ScoreFigure`
**Status:** draft
**Used in:** ProfileHeader, ScoreRow, ScoreBadge (composed), Search result cards, Profile preview

---

## 1. Why this exists

`ScoreFigure` — главный USP-визуал Bable. Это не просто число, это **доказательство экспертизы**.
Каждый показ Score должен:
- Быть контекстным (всегда `Topic Score`, никогда не `Score` соло)
- Использовать **serif** typography (журнальная серьёзность)
- Использовать **tabular numerals** (выравнивание в таблицах/списках)
- Быть **кликабельным** (→ explanation page, PP-1.1 / Pillar 3 transparent)

Если ScoreFigure где-то выглядит как обычный badge со счётчиком — мы потеряли differentiator.

---

## 2. Anatomy

### Inline (горизонтально)

```
Rust          720
↑ topic       ↑ figure
caption       serif-figure
```

### Stacked (вертикально, в Score list)

```
React
720
─────
```

Только две части. Никаких icons, никаких progress bars, никаких "level up" indicators.

| Part | Element | Token |
|------|---------|-------|
| Topic label | Text | `score-topic-color` (text-secondary) + `body` (16) |
| Figure number | Text | `score-figure-color` (text-primary) + `serif-figure` (32/40, tabular-nums) |
| Optional separator | (none for layout, gap через auto-layout) | `space-3` (12) horizontal, `space-1` (4) vertical |

---

## 3. Properties

| Property | Type | Default | Values |
|----------|------|---------|--------|
| `topic` | text | `"Topic"` | string (e.g. "React", "Rust", "System Design") |
| `value` | text | `"0"` | string (число; формат см. §6) |
| `orientation` | variant | `inline` | `inline` (горизонтально) / `stacked` (вертикально) |
| `size` | variant | `md` | `sm` (24 figure) / `md` (32 figure) / `lg` (48 figure) |
| `topicLength` | variant | `short` | `short` (≤15 chars) / `long` (16+ chars — truncate or wrap) |

---

## 4. Variants

### orientation: inline

```
Rust              720
```

- Auto-layout horizontal
- justify-content: space-between
- Width: hug content или fill (depends on parent)

**Use:** Profile header score list, search result row

### orientation: stacked

```
React
720
```

- Auto-layout vertical
- gap `space-1` (4)
- Topic смешанным, figure ниже

**Use:** Mobile compact profile view, recruiter dense view

---

## 5. Sizes

| size | figure font | topic font | example use |
|------|-------------|-----------|-------------|
| `sm` | `body-bold` (16/24/600, tabular-nums) | `caption` (14) | Inline in PostCard avatar area: "@vlad · React 720" |
| `md` | `serif-figure` (32/40, 500, tabular-nums) | `body` (16) | **Default** — ProfileHeader, ScoreRow |
| `lg` | `h1` (Serif 36/44, 600, tabular-nums) | `body-lg` (18) | ScoreExplanation page hero |

`md` — основной вариант. `sm` для embedded inline. `lg` для standalone hero.

---

## 6. Value formatting

### Range

| Score | Format |
|-------|--------|
| 0–999 | `0` (one decimal point in edge cases not needed — все integers) |
| 1000–9999 | `1.2K` (one decimal, K suffix) |
| 10000+ | `12K` (no decimal) |

### Edge cases

| Case | Display |
|------|---------|
| New user, no score yet | `—` (em dash, not "0") |
| Score being recalculated | `…` (loading indicator inline) |
| Hidden score (privacy) | hidden the whole ScoreFigure, no placeholder |

### Tabular numerals

**Critical:** все figures используют `font-variant-numeric: tabular-nums`. Иначе `720` и `1.2K` будут разной ширины и таблица "поедет".

---

## 7. States

| State | Trigger | Visual |
|-------|---------|--------|
| `default` | Loaded | См. anatomy |
| `loading` | Score being computed | `value = "…"`, остальное как default |
| `hover` (если кликабельная) | Mouse over | `score-figure-color` slightly darker; underline под figure |
| `pressed` (если кликабельная) | Mouse down | scale 0.98 |
| `focused` | Keyboard focus | focus ring around whole ScoreFigure |

Нет `disabled` state — Score либо есть, либо нет (показываем `—` для нет).

---

## 8. Behaviour

### Click → ScoreExplanationPage

ScoreFigure **по умолчанию кликабельный** (в ProfileHeader, ScoreRow). Это implements PP-1.1 (каждое число объяснимо).

При click — push на route `/u/<username>/score/<topic>` который ведёт на Score explanation:
- Какие посты дали Score
- Кто эндорсил, с каким весом каждый
- Динамика по месяцам
- Decay info

Если используется в context где не нужен navigation (например, в search results — то это инфо-only) — wrap'им в non-clickable container.

### Не анимируем counter increment

В отличие от vanity-стиля "counter rolling animation" (Instagram likes), ScoreFigure показывает **stabilized value**. Когда меняется (после нового endorse) — value просто меняется. Без count-up анимации, без particle effects.

---

## 9. Token references

| Component token | → Semantic |
|----------------|-----------|
| `score-figure-color` | `text-primary` |
| `score-figure-font` | `serif-figure` (32/40) — variable per size |
| `score-figure-feature` | `font-variant-numeric: tabular-nums` |
| `score-topic-color` | `text-secondary` |
| `score-topic-font` | `body` (16) — variable per size |
| `score-row-gap-y` | `space-1` (4) for stacked |
| `score-row-gap-x` | `space-3` (12) for inline |

См. `03-tokens/component-tokens.md` § Score Display.

---

## 10. A11y

| Aspect | Requirement |
|--------|------------|
| Element (clickable) | `<a href="...">` или `<button>` |
| Aria label | `"<topic> score: <value>. View details."` |
| Element (read-only) | `<div role="text">` |
| Screen reader text | "Rust score: 720. Built from 14 endorsements." (через aria-describedby если расширенная info) |
| Touch target | Min 44×44 (sm size figure — нужно обернуть в hit area) |
| Focus indicator | Visible ring (`focus-ring`) at 2px offset |
| Colour | Не полагаемся только на цвет — figure font size + family дают hierarchy |

### Reduced motion

Не применимо — ScoreFigure не имеет анимаций.

---

## 11. Copy

### Topic display

Всегда полное имя темы:
- ✅ "React"
- ✅ "System Design"
- ✅ "Rust"
- ❌ "REACT" (caps — anti-editorial)
- ❌ "react" (lowercase для proper noun — некорректно)
- ❌ "#react" (hash — это для tags, не для topics в score context)

Длинные topics:
- ≤15 символов: one line
- 16+ символов: truncate с `…` на конце (если место ограничено) или wrap на 2 строки (если место есть)

### Value display

Только число (с форматированием как в §6). **Никаких labels рядом:**
- ✅ "720"
- ❌ "720 points"
- ❌ "720 pts"
- ❌ "Score: 720"

Контекст уже задан через `topic`.

---

## 12. Do / Don't

### ✅ Do

- Always показывай topic + value вместе (никаких standalone numbers)
- Use serif-figure font для number — это часть identity
- Tabular numerals — обязательно
- Кликабельность по умолчанию (transparency principle)

### ❌ Don't

- Don't show "Score: 720" — topic уже это context
- Don't use sans-serif font для number — теряем differentiator
- Don't add progress bar / level indicator — это геймификация (AP)
- Don't animate count-up — vanity (AP-2)
- Don't show "+10" pop-up при endorse — gamification (AP)
- Don't compare visually ("vs market average") — введёт competition

---

## 13. Figma master spec

### Variants

- Variant `orientation`: `inline` / `stacked`
- Variant `size`: `sm` / `md` / `lg`
- Component property `topic`: text
- Component property `value`: text
- Boolean `isClickable`: для conditional focus ring и hover state

### Total variants

2 orientations × 3 sizes × 2 isClickable (на focus ring) = **12 variants**

(Если делаем focus ring и hover как separate states — добавь state variant. Иначе focus ring управляется через wrapper.)

### Auto-layout

- inline: horizontal, justify-content space-between, align center
- stacked: vertical, align start, gap `space-1`

### Component description (в Figma)

```
ScoreFigure

Atom для отображения Topic + Score number.
Главный USP-визуал Bable.

Orientation:
- inline — горизонтально (default, profile + search)
- stacked — вертикально (mobile compact)

Size:
- sm (figure 16/24) — inline in cards
- md (figure 32/40) — DEFAULT
- lg (figure 36/44) — hero on Score explanation

Topic:
- Full name (React, System Design)
- Не caps, не hash

Value:
- 0-999: as is
- 1K-9.9K: with K suffix
- 10K+: no decimal
- New user: em dash —
- Loading: ellipsis …

Tokens:
score-figure-color/-font, score-topic-color/-font

Clickability:
Default true. Click → /u/<user>/score/<topic>.

Docs: design/04-components/atoms/score-figure.md
```

---

## 14. Open questions

- [ ] Decay indicator: показывать ли направление trend (↗ growing / → stable / ↘ decay)? Сейчас нет — minimal. Можно добавить как small caret в `lg` size on ScoreExplanation hero
- [ ] Локализация чисел: "1.2K" работает в EN. В русском — "1.2 тыс"? Решим в i18n phase
- [ ] What if topic > 30 chars? В MVP topic — language/framework — short. Edge case
