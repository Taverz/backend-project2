# Typography Tokens

> Editorial calm требует серьёзной типографики. Три семейства, чёткие роли.

---

## 1. Font Stacks

| Role | Family | Fallback |
|------|--------|----------|
| **Serif** (headlines, names) | **Source Serif 4** (variable) | Charter, "Iowan Old Style", Georgia, serif |
| **Sans** (UI, body) | **Inter** (variable) | -apple-system, "Segoe UI", Roboto, sans-serif |
| **Mono** (code, metadata) | **JetBrains Mono** | "SF Mono", Menlo, Consolas, monospace |

### Почему эти

- **Source Serif 4** — Adobe rebranded из Source Serif Pro. Variable font, optical sizing (`opsz`), open-source. Отличная читаемость, нейтрально-журнальный
- **Inter** — индустриальный стандарт для UI, variable, оптимизирован для экрана, free
- **JetBrains Mono** — best-in-class для кода, отличные ligatures, free

Все три семейства бесплатны, доступны через Google Fonts и для self-host. Языки: Latin + Cyrillic покрытие у всех трёх.

---

## 2. Type Scale

**Honest hybrid scale.** Display-уровни следуют modular 1.25 (major third). UI-уровни используют industry-standard sizes (12/14/16/18) для читаемости и согласованности с native платформами. Это **осознанный гибрид**, не чистая модульная шкала.

### Display (Serif) — modular 1.25

| Token | Family | Size | Line-height | Weight | Letter-spacing | Use |
|-------|--------|:----:|:-----------:|:------:|:--------------:|-----|
| `h1` | Serif | 36 | 44 (1.22) | 600 | -0.015em | Page titles (profile name, post detail title) |
| `h2` | Serif | 28 | 36 (1.28) | 600 | -0.01em | Section headers |
| `h3` | Serif | 22 | 30 (1.36) | 600 | -0.005em | Subsection headers |
| `lead` | Serif | 20 | 32 (1.6) | 400 | 0 | Lead paragraph (post detail intro) |
| `serif-figure` | Serif | 32 | 40 (1.25) | 500 | -0.01em | Score numbers (`720`) |

(`display` 48 удалён — в MVP не используется.)

### UI (Sans) — industry-standard

| Token | Family | Size | Line-height | Weight | Letter-spacing | Use |
|-------|--------|:----:|:-----------:|:------:|:--------------:|-----|
| `body-lg` | Sans | 18 | 28 (1.56) | 400 | 0 | Promoted body (post detail body) |
| `body` | Sans | 16 | 24 (1.50) | 400 | 0 | **Default UI text** |
| `body-bold` | Sans | 16 | 24 (1.50) | 600 | 0 | Username, emphasis |
| `caption` | Sans | 14 | 20 (1.43) | 400 | 0 | Metadata, timestamps, secondary |
| `caption-bold` | Sans | 14 | 20 (1.43) | 600 | 0 | Field labels |
| `small` | Sans | 12 | 16 (1.33) | 400 | 0.005em | Counters, helpers (минимум для a11y) |
| `overline` | Sans | 11 | 16 (1.45) | 600 | 0.08em | UPPERCASE labels (only) |

### Code (Mono)

| Token | Family | Size | Line-height | Weight | Use |
|-------|--------|:----:|:-----------:|:------:|-----|
| `mono-body` | Mono | 14 | 22 (1.57) | 400 | Code blocks |
| `mono-inline` | Mono | 14 | inherit | 400 | Inline code в `body` (см. note ниже) |

**Note про `mono-inline`:** размер фиксирован 14px (не относительный) — потому что внутри `h1` 36 inline mono выглядит избыточно. Если нужен inline code в headline, лучше использовать spans с `body-bold` mono (отдельная вариация).

### Mobile adjustments

На mobile (< 480px) уменьшаем display-ступени:

| Token | Desktop | Mobile |
|-------|:-------:|:------:|
| `h1` | 36 | 28 |
| `h2` | 28 | 24 |
| `h3` | 22 | 20 |
| `serif-figure` | 32 | 28 |
| Все UI / mono | без изменений | без изменений |

---

## 3. Применение по экранам / компонентам

### Profile screen

```
Vlad Iliev                  ← h1 (Serif 36/44)
Senior FE Engineer          ← body (Sans 16, text-secondary)

React          720          ← h3 (Serif 22) for label, serif-figure (32) for number
System Design  510
Rust           280
```

### PostCard (feed)

```
Vlad Iliev · @vlad          ← body-bold (Sans 16/24/600)
2h ago · React, medium      ← caption (Sans 14, text-secondary)

The Suspense subtree        ← body-lg (Sans 18/28) — post body
boundary leaks promises…

```jsx
<Suspense />                ← mono-body (Mono 14/22)
```

⌃ 14 endorsements           ← caption (Sans 14)
```

### Post detail

```
The Suspense subtree        ← h2 (Serif 28/36) — body promoted
boundary leaks promises
if you don't wrap parent
in startTransition.

[mono-body code block]

Posted June 12, 2026        ← caption, full date
```

### Search results (recruiter)

```
Vlad Iliev                  ← body-bold (compact density)
React 720 · System Des. 510 ← caption + mono-inline for numbers
Senior FE Engineer · Open   ← small (12)
```

### Errors / Empty

```
No posts yet                ← h3 (Serif 22)
Follow people or topics     ← body (Sans 16, text-secondary)
to see content.
```

---

## 4. Правила использования

### Когда serif

- Любой headline / название экрана
- User display name (профиль, post)
- Score figures (числа Score) — `serif-figure`
- Lead-paragraph (post detail)

### Когда sans

- Всё UI: buttons, inputs, metadata, captions, navigation
- Post body в feed (не promoted version)
- Все секондар-тексты

### Когда mono

- Code blocks (всегда)
- Inline `code` (через backticks)
- Username technical references (e.g. `@vlad` в специфических контекстах) — опционально, default sans
- Metadata где визуально важна выравнивание (timestamps в logs view — recruiter mode)

---

## 5. Hierarchy через type, не через цвет

Editorial calm — hierarchy через **size + weight + family**, не через colour.

**Так:**
```
Vlad Iliev          ← Serif 36, 600 weight
Senior FE Engineer  ← Sans 16, 400 weight, text-secondary

[оба читаются разно за счёт family + size]
```

**Не так:**
```
Vlad Iliev          ← Sans 16, bold, primary colour
Senior FE Engineer  ← Sans 14, regular, accent colour

[hierarchy через цвет — anti-editorial]
```

---

## 6. Технические детали

### Font features

| Feature | Where | Use |
|---------|-------|-----|
| `font-optical-sizing: auto` | Source Serif 4, Inter | Variable optical sizing — улучшает рендер на разных размерах |
| `font-feature-settings: "ss02"` | Inter | Open digits (0 with slash) — лучше для чисел |
| `font-variant-numeric: tabular-nums` | Score numbers, любые числа в таблицах | Выравнивание чисел в колонке |
| `font-feature-settings: "liga"` | JetBrains Mono | Code ligatures (`=>`, `!=`, `>=`, `===`) |
| `font-feature-settings: "smcp"` | `overline` style | Small caps (если нужны опционально) |

**Note:** `tabular-nums` НЕ ставим по умолчанию на body — только там, где числа должны выравниваться (Score tables, recruiter results, profile stats). Propor цифры читаются лучше в обычном тексте.

### Loading

```html
<!-- Self-host preferred over Google CDN -->
<link rel="preload" as="font" href="/fonts/source-serif-pro-600.woff2" crossorigin>
<link rel="preload" as="font" href="/fonts/inter-400.woff2" crossorigin>
<link rel="preload" as="font" href="/fonts/inter-600.woff2" crossorigin>
<link rel="preload" as="font" href="/fonts/jetbrains-mono-400.woff2" crossorigin>
```

Subset to Latin + Cyrillic only. Variable fonts для Inter и Source Serif если возможно (уменьшает payload).

### Font-display

```css
@font-face {
  font-display: swap;  /* показать fallback до загрузки */
}
```

Чтобы fallback не давал большого reflow, fallback семьи и main размеры близки.

---

## 7. Accessibility

- Минимальный body size: **16px** (никаких 13px body)
- Минимальный caption: **14px**
- Line-height для body: ≥ 1.5
- Letter-spacing для UPPERCASE: ≥ 0.08em (обязательно для читаемости caps)
- User can scale up to 200% без поломки layouts (важно для тех, кому 18 нужно вместо 16)

---

## 7.5 Text-wrap rules (editorial-specific)

Editorial calm требует контроля над переносами строк.

### Headlines

```css
.h1, .h2, .h3 {
  text-wrap: balance;          /* избегать orphans в headlines */
  hyphens: none;               /* не переносим headline */
}
```

### Body

```css
.body, .body-lg {
  text-wrap: pretty;           /* fewer orphans в body */
  hyphens: auto;               /* переносы для длинных слов (URL и т.п.) */
  overflow-wrap: break-word;   /* длинные техн. термины не вылазят */
}
```

### Code

```css
.mono-body {
  text-wrap: nowrap;           /* код не переносится */
  overflow-x: auto;            /* scroll горизонтально если длинный */
}
```

### Минимум по символам

- **Headline не короче 2 слов** на строке (text-wrap: balance делает автоматически)
- **Body параграф не один word на последней строке** (text-wrap: pretty)
- **Username — никогда не переносится** (`white-space: nowrap`)

## 8. Что **не** используем

- ❌ More than 3 семейства
- ❌ All-caps headlines (только `overline` для labels)
- ❌ Italics (кроме редкого emphasis в body) — editorial sober не "вычурный"
- ❌ Decorative scripts / handwritten fonts
- ❌ Subpixel sizes (15.5px) — только из стандартной шкалы
- ❌ Letter-spacing положительное на body (только tracking caps и small)

---

## 9. Cheatsheet

- **Headline / Score? → Serif.**
- **UI text? → Sans.**
- **Код? → Mono.**
- **Hierarchy? → Через size + weight + family. Не через цвет.**
- **Body never below 16px.**
