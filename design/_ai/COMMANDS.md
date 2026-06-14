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

- Screen из `02-strategy/MVP-SCOPE.md`. Если не из MVP — спросить, добавлять ли в scope.
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
User: Создай компонент EndorseButton
→ Уточняю: какой layer? Atom (только button) или Molecule (icon + count + animation)?
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
Validation: ProfileScreen / Self / Default

Critical (must fix):
1. [tokens/colours.md] Surface bg использует raw #FFFFFF — должно быть `surface`
2. [anti-patterns.md AP-2.1] Follower count показан в header

Warning (should fix):
3. [typography.md] Score number использует body-bold — должен быть serif-figure

Suggestion (nice to have):
4. [positive-patterns.md PP-1.3] Endorsement list мог бы показывать score эндорсера

Pass:
- Spacing tokens ✓
- Copy guide ✓
- Iconography ✓
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

1. Read all `00-brief/*`, `01-research/*`, `02-strategy/*`, `03-tokens/*`
2. Cross-check:
   - Tokens referenced в компонентах существуют
   - Components referenced в screens существуют
   - Copy в UI follows guide
   - Anti-patterns absent
3. Output: comprehensive report

### Output

```
Audit Bable Design System — <date>

OK ✓:
- 47/47 MVP-SCOPE features have rationale
- 100% tokens organized in 3 layers
- 0 hardcoded hex в documented components

Warnings ⚠:
- ProfileScreen использует `accent` для 2 actions (PRINCIPLES §X — один accent на экран)
- Score figure font в SearchResults — `body-bold` вместо `serif-figure`

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
- "/explain expertise-score"
- "Расскажи про Bable"

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
User: /explain expertise-score

Score per topic, computed as Σ endorsement.weight × complexity_multiplier − decay.
Weight зависит от Score эндорсера по той же теме (StackOverflow-style).

Details: 00-brief/PROJECT-BRIEF.md § 5.1
Related: weighted endorsement, peer-review, anti-pattern AP-3.3 (one-click endorsements)
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
