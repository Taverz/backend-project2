# Commands — Triggers и точные процедуры

> Когда user пишет команду — ты следуешь конкретному workflow.
> Команды могут запускаться слешем (`/draw-screen profile`) или фразой ("Нарисуй экран Profile").
> Если фраза неоднозначна — спрашивай уточнение, не выбирай дефолт молча.

---

## Command syntax

```
/<command> <args>
```

| Command | Args |
|---------|------|
| `/draw-screen` | `<feature/screen>` (e.g. `profile/self`) |
| `/create-component` | `<layer/name>` (e.g. `molecule/post-card`) |
| `/extend-component` | `<name> <new-variant-or-property>` |
| `/extend-variant` | `<component> <variant-name>` |
| `/validate-screen` | `<frame-name>` |
| `/validate-component` | `<component-name>` |
| `/refactor` | `<target>` |
| `/copy` | `<context-description>` |
| `/audit-system` | (no args — проверка всей дизайн-системы) |
| `/generate-token` | `<type> <semantic-name>` |
| `/explain` | `<concept>` (e.g. `expertise-score`) |

---

## /draw-screen

### Trigger phrases

- "Нарисуй экран X"
- "Сделай экран X"
- "Draw X screen"
- "/draw-screen <name>"

### Prerequisites

- Screen из `docs/shared/SCREENS.md`. Если экрана нет в списке — спросить, добавлять ли в scope.
- Components, которые понадобятся, существуют или явно создаются параллельно.

### Procedure

См. **`WORKFLOW.md` § 1 — Draw a Screen**. Все 5 шагов обязательны.

### Output

```
Screen: <name>

[Plan section — что будешь делать]
[Components needed — какие есть / каких не хватает]
[Open questions — что уточнить]
[Frames to create — list with naming]

Подтверди план или скорректируй.
```

После confirmation от user → Step 3 (execute) → Step 4 (validate) → Step 5 (hand off).

### Examples

```
User: /draw-screen profile/self
```

или

```
User: Нарисуй экран профиля для разработчика (свой профиль)
```

Оба запускают одну и ту же процедуру.

---

## /create-component

### Trigger

- "Создай компонент X"
- "/create-component <layer/name>"
- "Сделай PostCard"

### Prerequisites

- Component из MVP или явно нужен новый
- Component-tokens для него уже есть (или создадим)

### Procedure

См. **`WORKFLOW.md` § 2 — Create a Component**.

### Examples

```
User: /create-component molecule/post-card
```

```
User: Создай компонент TweetCard
→ Уточняю: какой layer? Molecule (составной из Avatar/Username/Body/ActionRow)?
```

---

## /extend-component / /extend-variant

### Trigger

- "Добавь variant X к Button"
- "/extend-variant button danger"
- "Расширь Input с error state"

### Prerequisites

- Component существует
- Новый variant согласуется с системой (не нарушает principles)

### Procedure

См. **`WORKFLOW.md` § 3 — Extend a Component**.

### Examples

```
User: /extend-variant button danger
→ Check: button-danger-bg token есть? Нет → добавляю в component-tokens.md
→ Add variant `state=danger` в master
→ Verify existing instances не сломались
```

---

## /validate-screen / /validate-component

### Trigger

- "Проверь экран X"
- "Сделай ревью этого компонента"
- "/validate-screen profile/self"

### Procedure

См. **`WORKFLOW.md` § 4 — Validate**.

### Output

Список нарушений с цитатами и приоритетом:

```
Validation: ProfileScreen / Default

Critical (must fix):
1. [03-tokens/colours.md §5] Surface bg использует raw #FFFFFF — должно быть semantic `surface`
2. [docs/flutter/ICON-STRATEGY.md] В Avatar Material `Icons.person` — должно быть Phosphor `User` через UiIcon

Warning (should fix):
3. [03-tokens/typography.md §2] Username использует caption — должен быть body-bold
4. [docs/shared/WIDGET-STATES.md] Отсутствует LoadingMore state

Suggestion (nice to have):
5. Avatar border у own-profile — добавить subtle accent border

Pass:
- Spacing tokens ✓
- Copy guide ✓
- Iconography (Phosphor) ✓ кроме п.2
```

---

## /refactor

### Trigger

- "Перепиши X"
- "Сделай X более consistent"
- "/refactor profile-screen"

### Procedure

1. Read existing artifact
2. Identify issues (можно reuse `/validate-` logic)
3. Plan changes с impact на downstream
4. Confirm with user
5. Execute
6. Re-validate

### Output

```
Refactor target: <name>

Issues found:
- A
- B

Changes I'll make:
- 1
- 2

Impact:
- Screens using this: <list> (will inherit changes)
- Tokens affected: <list>

Confirm to proceed.
```

---

## /copy

### Trigger

- "Напиши копирайт для X"
- "/copy login error invalid credentials"
- "Empty state для notifications"

### Procedure

См. **`WORKFLOW.md` § 5 — Write UI Copy**.

### Output

```
Context: <what for>

Options:
A) <option> — fact-based, COPY-GUIDE §3 pattern
B) <option> — with action hint
C) <option> — minimal

Recommended: <A/B/C> because <reason>
```

---

## /audit-system

### Trigger

- "Проверь всю систему"
- "Audit"
- "/audit-system"

### Procedure

1. Read `/CLAUDE.md`, `/SOUL.md`, `docs/shared/DESIGN-CONTRACT.md`, all `design/03-tokens/*`, all `design/04-components/*`
2. Cross-check:
   - Tokens referenced в компонентах существуют в `colours.md` / `component-tokens.md`
   - Components referenced в screens существуют в `04-components/`
   - Все component-tokens покрыты в `semantic-mappings.md`
   - Naming совпадает между Figma и кодом (`DESIGN-CONTRACT.md §1`)
   - Никаких raw hex, никаких Material Icons, никакого Twitter blue в активных файлах
3. Output: comprehensive report

### Output

```
Audit Chirp Design System — <date>

OK ✓:
- N/N screens из docs/shared/SCREENS.md покрыты в design/<feature>/
- 100% tokens организованы в 3 слоя
- 0 hardcoded hex в активных компонентах
- semantic-mappings.md синхронизирован с component-tokens.md

Warnings ⚠:
- TimelineScreen использует `accent` для 2 actions (один accent CTA на экран)
- TweetCard avatar size 32 — должен быть 40 (component-tokens.md avatar-size-md)

Critical ✗:
- (none / or list)

Suggestions:
- ...
```

---

## /generate-token

### Trigger

- "Создай token X"
- "Нам нужен новый цвет для Y"
- "/generate-token color score-badge-bg"

### Procedure

1. Verify need (можно ли использовать существующий?)
2. Pick primitive (если colour — из palette)
3. Add semantic если нужно
4. Add component-token если нужно
5. Document в соответствующем файле

### Output

```
New token: <name>

Type: colour / typography / spacing / ...
Primitive: <ref or new>
Semantic: <name → primitive>
Component: <name → semantic>

Where used: <list>
Where documented: <file:section>

Verification: contrast/scale rule passed
```

---

## /explain

### Trigger

- "Что такое X?"
- "/explain timeline-fan-out"
- "Расскажи про Chirp"

### Procedure

1. Read relevant file(s) (см. `CONTEXT-MAP.md`)
2. Answer кратко (1-2 параграфа)
3. Цитируй конкретные файлы для deep dive

### Output

```
<concept>:

<short answer>

For details: <file:section>
Related: <other concepts>
```

### Examples

```
User: /explain timeline-fan-out

Твит при создании рассылается в ленты всех подписчиков (fan-out on write).
Чтение ленты — один быстрый запрос. Запись дорогая для популярных авторов.

Details: /SOUL.md §2.4 + §3 (timeline модуль)
Related: home timeline endpoint, follow module, Phase 3 Kafka-оптимизация
```

---

## Universal rules для всех commands

### Always

1. **Read AGENT.md** если новая сессия
2. **Read context** по `CONTEXT-MAP.md` для типа команды
3. **State the plan** перед execution
4. **Ask** если что-то неясно
5. **Self-validate** перед hand-off
6. **List open questions** в output

### Never

1. ❌ Execute без planning step
2. ❌ Skip validation
3. ❌ Hand off с "готово!" — всегда детально
4. ❌ Создавать без проверки, есть ли уже похожее
5. ❌ Игнорировать anti-patterns даже если user просит

---

## Command-less requests

Часто user пишет неструктурированный запрос. Распознавай намерение:

| User wrote | Command |
|------------|---------|
| "сделай X" | `/draw-screen` или `/create-component` (уточни) |
| "проверь / посмотри / ревью" | `/validate-` |
| "поменяй / перепиши" | `/refactor` |
| "что такое / расскажи" | `/explain` |
| "напиши текст / label" | `/copy` |
| "новый цвет / шрифт / spacing" | `/generate-token` |

Если не уверен — **спроси**, не угадывай.

---

## Confidence levels

Возвращая output, используй маркеры уверенности:

| Marker | Когда |
|--------|-------|
| `✅ Done` | Сделал, всё прошло validation |
| `🟡 Done with notes` | Сделал, есть open questions |
| `⚠️ Blocked` | Не могу продолжить без user input |
| `❌ Won't do` | Запрос нарушает critical rule (anti-pattern, principle) |

При `❌` — объясни какое правило, и предложи альтернативу.
