# Code Block Syntax Theme

> Bable про код. Code blocks — first-class content, не decoration.
> Theme должна быть читабельной, согласована с editorial palette, и работать на обеих темах.

---

## Decision

Используем **кастомную палитру**, основанную на One Light / One Dark, но скорректированную под editorial warm tokens.

**Почему не Catppuccin / Dracula / GitHub:**
- Catppuccin / Dracula — слишком яркие, ломают editorial calm
- GitHub themes — нейтральны, но используют cold neutrals (мы warm)
- One Light/Dark — хороший базис, но требует warm-tint

---

## Code block container

| Property | Light | Dark |
|----------|-------|------|
| Background | `surface-sunken` (`#F4EFE8`) | `surface-sunken` (`#0F0D0B`) |
| Border | `border-subtle` (1px) | `border-subtle` (1px) |
| Border radius | `radius-none` (0) — editorial flat | same |
| Padding | `space-4` (16) vertical, `space-4` horizontal | same |
| Font | JetBrains Mono, `mono-body` (14/22) | same |
| Default text colour | `text-primary` | `text-primary` |
| Overflow | `overflow-x: auto`, не wrap | same |
| Copy button | Top-right, на hover показывается | same |

Inline `code` (через backticks):
- Background `surface-sunken`
- Padding `0 4px`
- Border-radius `2px`
- Font `mono-inline` (см. typography)

---

## Syntax token palette

Editorial-warm palette. Все цвета **WCAG AA** на code block background.

### Light theme

| Token | Hex | Roles |
|-------|-----|-------|
| `code-default` | `#1A1614` (ink) | Plain text, punctuation, brackets |
| `code-comment` | `#7C746A` (warm-500) | Comments (italic) |
| `code-keyword` | `#8A3D27` (terra-700) | `if`, `const`, `function`, `return`, `class` |
| `code-string` | `#3C6E47` (forest-500) | `"hello"`, `'world'` |
| `code-number` | `#A84B30` (terra-600) | `42`, `3.14`, `0xFF` |
| `code-function` | `#3B3E8C` (deep indigo) | Function names в declaration / call |
| `code-type` | `#6B2F1F` (terra-800) | `string`, `User`, `Promise<T>` |
| `code-property` | `#1A1614` (ink) | Object properties в access |
| `code-attribute` | `#B07A1F` (ochre-500) | HTML/JSX attribute names, decorators |
| `code-tag` | `#8A3D27` (terra-700) | HTML/JSX tags (`<div>`) |
| `code-variable` | `#1A1614` (ink) | Variable names default |
| `code-operator` | `#5C544B` (warm-600) | `+`, `-`, `=`, `=>`, `&&` |
| `code-builtin` | `#3B3E8C` (deep indigo) | `console`, `Math`, `JSON` |
| `code-regex` | `#A84B30` (terra-600) | Regex literals |
| `code-deletion` | `#A8362A` (brick-500) | `- removed line` (diff red) |
| `code-insertion` | `#3C6E47` (forest-500) | `+ added line` (diff green) |

### Dark theme

| Token | Hex | Roles |
|-------|-----|-------|
| `code-default` | `#EBE5DC` | Plain text |
| `code-comment` | `#7C746A` (warm-500) | Comments |
| `code-keyword` | `#E69478` (terra-300) | Keywords |
| `code-string` | `#9CBFA3` (forest tint) | Strings |
| `code-number` | `#D77456` (terra-400) | Numbers |
| `code-function` | `#9DA0E8` (indigo lighter) | Functions |
| `code-type` | `#F0BAA5` (terra-200) | Types |
| `code-property` | `#EBE5DC` | Properties |
| `code-attribute` | `#D49946` (ochre-400) | Attributes, decorators |
| `code-tag` | `#E69478` (terra-300) | Tags |
| `code-variable` | `#EBE5DC` | Variables |
| `code-operator` | `#9B8F80` | Operators |
| `code-builtin` | `#9DA0E8` | Builtins |
| `code-regex` | `#D77456` (terra-400) | Regex |
| `code-deletion` | `#C04032` | Diff removed |
| `code-insertion` | `#5A8C66` | Diff added |

---

## Engine

Используем **Shiki** (web) и **flutter_highlight** или **flutter_code_editor** (Flutter).

Почему Shiki:
- Использует TextMate grammars — корректно подсвечивает 100+ языков
- Generates static HTML — не требует client-side JS
- Поддерживает custom themes

Для Flutter:
- `flutter_highlight` поддерживает highlight.js styles, можем экспортировать custom theme
- Или использовать pre-rendered HTML с серверной подсветки через Shiki

---

## Supported languages (MVP)

Приоритет по аудитории (Marina, Vlad, типичные tech-посты):

**Tier 1 (must):**
- JavaScript / TypeScript / JSX / TSX
- Python
- Rust
- Go
- Java / Kotlin
- C / C++
- HTML / CSS

**Tier 2 (should):**
- Swift
- Ruby
- PHP
- SQL
- Shell / Bash
- JSON / YAML / TOML

**Tier 3 (nice):**
- Lua, Zig, Nim, OCaml, Haskell, Elixir, Scala

Если язык не определён или unsupported — fallback to `text` (no highlighting), но code block формат остаётся.

---

## Examples

### TypeScript

```ts
const user: User = await fetchUser(id);
//   ↑       ↑              ↑      ↑
//   keyword type           function property
//                          variable
if (user.role === "admin") {
//↑   ↑    ↑    ↑    ↑
//key prop prop op   string
  console.log(`Hi ${user.name}`);
  //↑          ↑     ↑
  //builtin    string interpolation
}
```

### Rust

```rust
fn calculate_score(user: &User, topic: &str) -> u32 {
//↑                    ↑       ↑      ↑       ↑
//keyword              type    type   type    type
    let endorsements = user.endorsements_for(topic);
    //↑              ↑    ↑                    ↑
    //keyword        prop  function             variable
    endorsements.iter().map(|e| e.weight()).sum()
}
```

### Diff (when showing code changes)

```diff
- function calc(a, b) {
-   return a + b;
- }
+ function calc(a: number, b: number): number {
+   return a + b;
+ }
```

---

## A11y для code

- Contrast ratio минимум 4.5:1 для всех code tokens на `surface-sunken`
- Не полагаемся только на цвет: ключевые слова **bold** в light theme (weight 600), курсив для комментариев
- Code block имеет `role="region"` + `aria-label="Code block, JavaScript"` для screen readers
- Copy button с `aria-label="Copy code"`

---

## What we DON'T highlight

- ❌ Plain text посты — не code, не подсвечиваем
- ❌ Whitespace-significant индикация (точки на пробелах) — visual noise
- ❌ Line numbers по умолчанию — на post detail можно опционально включать
- ❌ Code folding в посте — пост короткий (256 char + small code block)
- ❌ Linting indicators — пост это пост, не editor
