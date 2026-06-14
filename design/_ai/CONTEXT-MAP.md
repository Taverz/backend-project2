# Context Map — Что читать для какой задачи

> Чтобы не перегружать context: для каждой задачи — минимальный и расширенный список файлов.
> "Минимальный" = absolute must-read. "Расширенный" = добавь если задача нестандартная или есть открытые вопросы.

---

## Always (любая задача)

Эти 5 файлов читаются **всегда**, в каждой свежей сессии:

1. `_ai/AGENT.md` — кто ты
2. `_ai/WORKFLOW.md` — как работаешь
3. `00-brief/VISION.md` — продукт в одной странице
4. `00-brief/PRINCIPLES.md` — 10 правил
5. `00-brief/COPY-GUIDE.md` — voice + шаблоны

После этих 5 — добавь специфические по задаче (см. ниже).

---

## Task: Draw a screen

### Minimum

- Always (5 above)
- `02-strategy/MVP-SCOPE.md` — найти screen в списке, проверить, что в scope
- `03-tokens/colours.md`
- `03-tokens/typography.md`
- `03-tokens/spacing.md`
- `03-tokens/icons.md`
- `03-tokens/component-tokens.md`
- `04-components/` — все компоненты, которые будут на этом screen (если папка существует)

### Extended (если есть открытые вопросы)

- `01-research/personas.md` — кто primary user экрана
- `01-research/jtbd.md` — какие jobs этот screen решает
- `01-research/anti-patterns.md` — что **точно** не должно появиться
- `01-research/positive-patterns.md` — checklist для каждого экрана
- `02-strategy/POSITIONING.md` — если screen вызывает вопросы про брендирование

### Screen-specific дополнительные

| Screen | Доп файл |
|--------|---------|
| Profile (any) | `01-research/switch-triggers.md` (профиль = главная conversion поверхность) |
| Feed | `02-strategy/MVP-SCOPE.md` § Feed (детальные требования по chronology) |
| Search (recruiter) | `01-research/personas.md` § Persona 3 Anna |
| Compose | `03-tokens/code-theme.md` (code blocks) + `COPY-GUIDE.md` § placeholders |
| Post detail | `03-tokens/code-theme.md` |
| Score explanation | `00-brief/PRINCIPLES.md` § 7 trust by transparency |
| Notifications | `01-research/anti-patterns.md` AP-1.3, AP-1.4, AP-4.3 |

---

## Task: Create a component

### Minimum

- Always (5)
- `02-strategy/MVP-SCOPE.md` — нужен ли в MVP?
- `03-tokens/component-tokens.md` — есть ли token для него?
- `04-components/` — существующие (избегать дубликат)
- `_ai/FIGMA-RULES.md` — правила naming/variants

### Component-type-specific

| Type | Доп файл |
|------|---------|
| Button-variant | `03-tokens/colours.md` § component-tokens — buttons |
| Input | `03-tokens/colours.md` (focus states, disabled), `COPY-GUIDE.md` § labels |
| Score / Badge | `00-brief/VISION.md` § 5.1 Expertise Score, `03-tokens/typography.md` § serif-figure |
| Code block | `03-tokens/code-theme.md` целиком |
| Empty state | `COPY-GUIDE.md` § 4 |
| Confirm dialog | `COPY-GUIDE.md` § 8 |
| Avatar | `03-tokens/component-tokens.md` — Avatar section + fallback function note |
| Endorse button | `01-research/positive-patterns.md` PP-1.3, `03-tokens/motion.md` (burst animation) |

---

## Task: Validate existing screen / component

### Minimum

- Always (5)
- `01-research/anti-patterns.md` — что нельзя
- `01-research/positive-patterns.md` — что должно быть
- `03-tokens/` (все 8 файлов) — для проверки токенов

### Specific to validation type

- Validation copy → `COPY-GUIDE.md` § 10 banlist
- Validation a11y → `00-brief/PRINCIPLES.md` § 2
- Validation performance → `00-brief/PRINCIPLES.md` § 5
- Validation editorial direction → `02-strategy/CHOSEN-DIRECTION.md` + `visual-directions.md` § B

---

## Task: Write UI copy

### Minimum

- `00-brief/COPY-GUIDE.md` — primary
- `00-brief/PRINCIPLES.md` § 1 (tone)

Чаще всего этого достаточно. Расширь только если контекст незнакомый.

### Extended (для непростого копирайтинга)

- `01-research/personas.md` — для кого пишем (Marina, Vlad, Anna имеют разный голос)
- `01-research/anti-personas.md` — кому **не** угождаем (Greg = motivational не пишем)

---

## Task: Extend / refactor component

### Minimum

- Always (5)
- Существующий component spec (`04-components/<name>.md`)
- `03-tokens/component-tokens.md`
- `_ai/FIGMA-RULES.md`

### Extended

- Если нужен новый token → `03-tokens/colours.md` (для colour) или `typography.md` (для шрифта)
- Если меняется поведение → `WORKFLOW.md` § validate

---

## Task: Convert tokens to code (Flutter / Web / iOS)

### Minimum

- `03-tokens/` (все 8 файлов)
- `00-brief/PRINCIPLES.md` § 8 mobile-first

### Specific

- Flutter → README в `flutter/` репозитории + Flutter `ThemeData` paradigm
- Web → CSS custom properties + Tailwind config
- iOS → Asset catalog + UIColor extensions

---

## Task: Discovery / understanding the product

User задаёт вопросы типа "почему мы делаем X?", "что такое Bable?".

### Minimum

- `00-brief/VISION.md` (длинный нарратив, самое богатое объяснение)
- `02-strategy/POSITIONING.md` (one-liner + brand pillars)
- `01-research/jtbd.md` (что именно решаем)

Это лучшие три файла для общего ответа.

---

## Анти-pattern: что **не** читать без необходимости

- Не читай **весь** `01-research/competitors.md` если задача про composing — слишком много данных, отвлекает
- Не читай **все** `_ai/` файлы каждый раз — AGENT + WORKFLOW достаточно для процесса
- Не читай `flutter/` или `backend/` код для дизайн-задач — они вне дизайн-системы

---

## Heuristic — выбор файлов

Если задача про:

| Сигнал в задаче | Читай дополнительно |
|----------------|---------------------|
| "почему" / "обоснуй" | VISION, PRINCIPLES, jtbd |
| "выглядит как" / "стиль" | CHOSEN-DIRECTION, visual-directions, tokens |
| "что писать" / "label" / "error" | COPY-GUIDE |
| "нельзя" / "запрещено" | anti-patterns, anti-personas |
| "должно быть" / "always" | positive-patterns, PRINCIPLES |
| "для кого" | personas, anti-personas |
| "как привлечь" / "первый раз" | switch-triggers |
| "Score" / "Expertise" | VISION § 5.1, COPY-GUIDE § 9 |
| "code" / "syntax" | code-theme |
| "тёмная" / "light" | colours, CHOSEN-DIRECTION |
| "recruiter" | personas Anna, spacing § recruiter mode, MVP-SCOPE § Roles |

---

## Если не уверен — читай VISION

Если задача неясна, расплывчата, или ты потерялся — **VISION.md** даёт fastest re-grounding. Это always-on context document.

После VISION — приходишь к user с **уточняющим вопросом**, не делаешь предположений.
