# Workflow: от бизнес-идеи до готовой фичи

> Команда: бизнес, менеджер, аналитик, дизайнер, бэкендер, фронтендер, тестировщик, ИИ.
> Каждый знает: что делает, в каком порядке, какие документы создаёт/проверяет.

---

## 1. Общая схема flow

```
Фаза 0: ИДЕЯ         Бизнес → 01-REQUIREMENTS.md (3-10 строк)
                         ↓
Фаза 1: АНАЛИЗ       Аналитик + AI → 02-SPEC.md
                     Аналитик → DATA-REQUIREMENTS.md
                         ↓
Фаза 2: ДИЗАЙН       Дизайнер → Figma
                     Дизайнер + AI → SCREENS.md
                     Дизайнер + AI → UI-STATES.md
                     Дизайнер + AI → WIDGET-STATES.md
                     Дизайнер → DESIGN-CONTRACT.md (если новый компонент)
                         ↓
Фаза 3: АРХИТЕКТУРА  Аналитик + AI → 03-ARCHITECTURE.md
                     Аналитик + AI → 08-BEHAVIOR.md
                         ↓
Фаза 4: ПРИЁМКА      Менеджер + Команда → Review всех документов
                         ↓
Фаза 5: РЕАЛИЗАЦИЯ   AI → код по документам
                     Бэкендер → проверяет backend-код
                     Фронтендер → проверяет frontend-код
                         ↓
Фаза 6: ТЕСТЫ        Тестировщик + AI → 07-TEST-CASES.md (до кода!)
                     Тестировщик → выполняет тесты
                     AI → исправляет баги
                         ↓
Фаза 7: ОБНОВЛЕНИЕ   AI → обновляет docs/feature-name/*.md
                     AI → обновляет SOUL.md (если изменилась архитектура)
```

---

## 2. Роли и ответственность

| Роль | Создаёт | Проверяет | Утверждает |
|------|---------|-----------|------------|
| **Бизнес** | 01-REQUIREMENTS.md | — | Готовую фичу в prod |
| **Менеджер** | Task в трекере | Все документы на фазе 4 | Переход между фазами |
| **Аналитик** | 02-SPEC.md, DATA-REQUIREMENTS.md, 03-ARCHITECTURE.md, 08-BEHAVIOR.md | 01-REQUIREMENTS.md | — |
| **Дизайнер** | Figma, DESIGN-CONTRACT.md | SCREENS.md, UI-STATES.md, WIDGET-STATES.md | — |
| **Бэкендер** | Backend-код | API.md, ERRORS.md, DATA-REQUIREMENTS.md | Backend-код |
| **Фронтендер** | Frontend-код | WIDGET-DATA-FLOW.md, SCREENS.md | Frontend-код |
| **Тестировщик** | 07-TEST-CASES.md | 05-VERIFICATION.md | Feature ready |
| **AI** | Черновики всех документов, код | — | — |

---

## 3. Фаза 0: Идея → Requirements

### Кто: Бизнес

**Что делает:** Пишет 3-10 строк о том, что должна делать фича.

**Шаблон:**

```markdown
# Feature: {Название}

## Требования

{3-10 строк}

## Критерии приёмки

- [ ] {критерий 1}
- [ ] {критерий 2}
```

**Пример:** docs/shared/auth-flow/01-REQUIREMENTS.md

**Куда сохраняет:** `docs/shared/{feature-name}/01-REQUIREMENTS.md`

**Проверяет:** Менеджер (согласуется с roadmap)

---

## 4. Фаза 1: Анализ → SPEC

### Кто: Аналитик + AI

**Что делает:**

1. AI читает 01-REQUIREMENTS.md
2. AI генерирует черновик 02-SPEC.md (API контракт)
3. Аналитик правит: уточняет поля, ошибки, ограничения
4. AI генерирует DATA-REQUIREMENTS.md (какие поля нужны UI)

**Шаблон 02-SPEC.md:**

```markdown
# {Feature} — SPEC

### POST /api/v1/{endpoint}

| Field | Type | Constraints |
|-------|------|-------------|

**Response 200/201:**
\`\`\`json
{}
\`\`\`

**Errors:** {HTTP statuses}
```

**Шаблон DATA-REQUIREMENTS.md:**

```markdown
# {Feature} — Data Requirements

## Screen: {ScreenName}

| Endpoint | Response field | UI element | Required |
|----------|---------------|------------|:--------:|
```

**Куда сохраняет:**
- `docs/shared/{feature-name}/02-SPEC.md`
- `docs/shared/DATA-REQUIREMENTS.md` (общий файл, добавляет секцию)

**Проверяет:** Бэкендер (реализуемо ли API?)

---

## 5. Фаза 2: Дизайн → Screens + Widgets

### Кто: Дизайнер + AI

**Что делает:**

1. Дизайнер рисует экраны в Figma
2. AI читает Figma (через Dev Mode или DESIGN-CONTRACT) и генерирует:
   - SCREENS.md (список экранов, элементы, состояния)
   - UI-STATES.md (таблица состояний каждого экрана)
   - WIDGET-STATES.md (таблица состояний каждого компонента)
3. Дизайнер правит: добавляет пропущенные состояния
4. Если новый компонент → DESIGN-CONTRACT.md (naming, export)

**Шаблон 06-UI-STATES.md:**

```markdown
## Screen: {ScreenName}

| # | State | Trigger | UI Elements | Error display | Navigation |
|---|-------|---------|-------------|---------------|------------|
| 1 | idle | ... | ... | ... | ... |
```

**Шаблон WIDGET-STATES.md (новая секция):**

```markdown
## {WidgetName}

| # | State | Trigger | Visual | Behaviour |
|---|-------|---------|--------|-----------|
| 1 | enabled | ... | ... | ... |
```

**Куда сохраняет:**
- `docs/shared/SCREENS.md` (обновляет секцию)
- `docs/shared/auth-flow/06-UI-STATES.md` (или соответствующий feature-flow)
- `docs/shared/WIDGET-STATES.md` (обновляет секцию)
- `docs/shared/DESIGN-CONTRACT.md` (если новые иконки/компоненты)

**Проверяет:** Фронтендер (реализуемо ли UI?)

---

## 6. Фаза 3: Архитектура → Behavior

### Кто: Аналитик + AI

**Что делает:**

1. AI читает 02-SPEC.md + SCREENS.md + UI-STATES.md
2. AI генерирует 03-ARCHITECTURE.md:
   - Sequence diagram (login flow, error flow, refresh flow)
   - Model structure (DTO, UI models)
   - State machine
   - Error propagation
3. Аналитик генерирует 08-BEHAVIOR.md:
   - Пошаговое описание User → System для каждого экрана
   - Business rules
   - Decision trees (if A then B else C)

**Шаблон 08-BEHAVIOR.md:**

```markdown
## Screen: {ScreenName}

### {Scenario name}

```
Пользователь:  {action}
Система:      {reaction}
              ┣━ {condition 1} → {result 1}
              ┗━ {condition 2} → {result 2}
```
```

**Куда сохраняет:**
- `docs/shared/{feature-name}/03-ARCHITECTURE.md`
- `docs/shared/{feature-name}/08-BEHAVIOR.md`

**Проверяет:** Вся команда (все видят, как будет работать)

---

## 7. Фаза 4: Приёмка (Review)

### Кто: Менеджер + вся команда

**Что проверяет каждый:**

| Роль | Проверяет | Ищет |
|------|-----------|------|
| **Бизнес** | 01-REQUIREMENTS.md → 08-BEHAVIOR.md | Соответствие идее |
| **Менеджер** | Все документы | Полнота, нет пропусков |
| **Аналитик** | 08-BEHAVIOR.md | Логические ошибки, пропущенные сценарии |
| **Дизайнер** | SCREENS.md, UI-STATES.md | Соответствие Figma |
| **Бэкендер** | 02-SPEC.md, DATA-REQUIREMENTS.md | Реализуемость API |
| **Фронтендер** | UI-STATES.md, WIDGET-DATA-FLOW.md | Реализуемость UI |
| **Тестировщик** | 07-TEST-CASES.md (если уже есть) | Полнота тестов |

**Процесс:**

```
1. Менеджер создаёт PR/MR в docs/ со всеми файлами
2. Каждый член команды оставляет комментарии
3. Автор (аналитик/дизайнер) правит
4. Когда все апрувнули → merge
5. Переход к реализации
```

---

## 8. Фаза 5: Реализация (Code)

### Кто: AI + Бэкендер + Фронтендер

**Что делает AI:**

```
AI получает задачу: "Реализуй {file} для {platform} по документации"
  → Читает 02-SPEC.md (API)
  → Читает 03-ARCHITECTURE.md (как устроено)
  → Читает 08-BEHAVIOR.md (логика)
  → Читает 06-UI-STATES.md (состояния)
  → Читает WIDGET-DATA-FLOW.md (какие поля куда)
  → Генерирует код
  → Бэкендер/фронтендер проверяет
```

**Правила:**

| Критерий | Что проверяет человек |
|----------|----------------------|
| Код компилируется | CI/CD |
| Код соответствует документации | Бэкендер/фронтендер |
| Код не ломает существующие тесты | CI/CD |
| Код покрыт новыми тестами | Тестировщик |

---

## 9. Фаза 6: Тесты

### Кто: Тестировщик + AI

**Процесс:**

```
До начала разработки:
  Тестировщик + AI → 07-TEST-CASES.md (precondition → step → expected)
  
После разработки:
  AI → генерирует unit tests из 07-TEST-CASES.md
  Тестировщик → выполняет manual тесты
  Тестировщик → выполняет integration тесты
  AI → исправляет баги
```

**Шаблон 07-TEST-CASES.md:**

```markdown
### TC-XXX: {Scenario name}

**Precondition:** {что должно быть до}

| Step | Action | Expected result |
|------|--------|----------------|
| 1 | {action} | {result} |
```

---

## 10. Фаза 7: Обновление документации

### Кто: AI

**Когда обновлять:** После каждого merge кода.

**Что обновляет AI:**

| Файл | Когда обновляется | Что меняется |
|------|-------------------|-------------|
| `docs/shared/{feature-name}/*.md` | Фича реализована | Статусы: ⬜ → ✅ |
| `docs/shared/SOUL.md` | Изменилась архитектура | Секция "Статус", новые модули |
| `docs/shared/API.md` | Добавился/изменился эндпоинт | Новая секция |
| `docs/shared/ERRORS.md` | Добавилась ошибка | Новая строка в таблице |
| `docs/shared/SCREENS.md` | Изменился экран | Новая секция или правка |
| `docs/shared/FEATURES.md` | Новый acceptance criteria | Новый чекбокс |
| `docs/shared/WIDGET-STATES.md` | Новый компонент | Новая секция |
| `TECHDEBT.md` | Найден техдолг | Новая запись |

**Процесс:**

```
1. Код замержен
2. Менеджер: "AI, обнови документацию по задаче TASK-123"
3. AI читает git diff изменённых файлов
4. AI определяет, какие документы нужно обновить
5. AI вносит изменения (создаёт PR в docs/)
6. Менеджер аппрувит → merge
```

**Шаблон промпта для AI:**

```
Задача: TASK-123 — Добавить rate limiting на /auth/login

Что изменилось в коде:
{git diff}

Обнови следующие документы:
- docs/shared/ERRORS.md: добавить 429 строчку
- docs/shared/auth-flow/02-SPEC.md: добавить rate limit в ошибки
- docs/shared/auth-flow/08-BEHAVIOR.md: добавить сценарий rate limiting
- docs/shared/auth-flow/06-UI-STATES.md: добавить состояние rate_limited

Не меняй ничего, что не связано с TASK-123.
```

---

## 11. Сводная таблица: файл → кто создаёт → кто проверяет

| Файл | Создаёт | AI помогает | Проверяет | Фаза |
|------|---------|:-----------:|-----------|:----:|
| 01-REQUIREMENTS.md | Бизнес | ❌ | Менеджер | 0 |
| 02-SPEC.md | Аналитик + AI | ✅ черновик | Бэкендер | 1 |
| DATA-REQUIREMENTS.md | Аналитик + AI | ✅ черновик | Фронтендер | 1 |
| Figma | Дизайнер | ❌ | — | 2 |
| SCREENS.md | Дизайнер + AI | ✅ из Figma | Фронтендер | 2 |
| 06-UI-STATES.md | Дизайнер + AI | ✅ из Figma | Фронтендер | 2 |
| WIDGET-STATES.md | Дизайнер + AI | ✅ из Figma | Фронтендер | 2 |
| DESIGN-CONTRACT.md | Дизайнер | ❌ | Фронтендер | 2 |
| 03-ARCHITECTURE.md | Аналитик + AI | ✅ черновик | Команда | 3 |
| 08-BEHAVIOR.md | Аналитик + AI | ✅ черновик | Команда | 3 |
| 07-TEST-CASES.md | Тестировщик + AI | ✅ черновик | Тестировщик | 3/6 |
| Backend-код | AI | ✅ генерирует | Бэкендер | 5 |
| Frontend-код | AI | ✅ генерирует | Фронтендер | 5 |
| Обновление docs | AI | ✅ выполняет | Менеджер | 7 |

---

## 12. Template: Task description для трекера

```markdown
## TASK-123: {Краткое название}

### Feature: {Название фичи}
Ссылка: docs/shared/{feature-name}/FLOW-README.md

### Что нужно сделать
{описание задачи}

### Документация
- [ ] READ (прочитать): docs/shared/{feature-name}/02-SPEC.md
- [ ] READ (прочитать): docs/shared/{feature-name}/08-BEHAVIOR.md
- [ ] UPDATE (обновить): docs/shared/{feature-name}/06-UI-STATES.md (новое состояние)
- [ ] UPDATE (обновить): docs/shared/API.md (если меняется API)

### Критерии готовности
- [ ] Код написан и закоммичен
- [ ] Тесты проходят
- [ ] Документация обновлена
- [ ] Тестировщик подтвердил

### Кто делает
Роль: {бэкендер / фронтендер / аналитик}
```

---

## 13. Полный flow в одном файле (checklist для менеджера)

```
[ ] Фаза 0: Бизнес написал 01-REQUIREMENTS.md
[ ] Фаза 1: Аналитик + AI → 02-SPEC.md, DATA-REQUIREMENTS.md
[ ] Фаза 2: Дизайнер → Figma. Дизайнер + AI → SCREENS, UI-STATES, WIDGET-STATES
[ ] Фаза 3: Аналитик + AI → 03-ARCHITECTURE.md, 08-BEHAVIOR.md
[ ] Фаза 4: Review всей командой → approve
[ ] Фаза 5: AI → код. Бэкендер/фронтендер → review
[ ] Фаза 6: Тестировщик → 07-TEST-CASES.md (если не сделано). AI → тесты → багфикс
[ ] Фаза 7: AI → обновление docs
[ ] ✅ Фича готова
```
