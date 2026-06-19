# Prompt Templates — Chirp

> Шаблоны промтов для AI-агента по типам задач.
> Использовать как starting point, заменять `<placeholder>` на свои значения, добавлять контекст-ссылки.
> Все шаблоны рассчитаны на агента, у которого есть доступ к репозиторию (Claude Code или аналог).

---

## Содержание

1. [Универсальная структура промта](#1-универсальная-структура-промта)
2. [Code — написание новой функциональности](#2-code--написание-новой-функциональности)
3. [Code review](#3-code-review)
4. [Refactoring](#4-refactoring)
5. [Bug fix / debugging](#5-bug-fix--debugging)
6. [Tests](#6-tests)
7. [Design — экран](#7-design--экран)
8. [Design — компонент](#8-design--компонент)
9. [Design review / validation](#9-design-review--validation)
10. [Конвертация: Figma → код](#10-конвертация-figma--код)
11. [Конвертация: код / спека → Figma](#11-конвертация-код--спека--figma)
12. [Research](#12-research)
13. [Briefing — постановка задачи на фичу](#13-briefing--постановка-задачи-на-фичу)
14. [Analysis — анализ существующего кода/дизайна](#14-analysis--анализ-существующего-кодадизайна)
15. [Documentation](#15-documentation)
16. [Migration / breaking change](#16-migration--breaking-change)
17. [Quick prompts (one-liners)](#17-quick-prompts-one-liners)

---

## 1. Универсальная структура промта

Любая задача укладывается в **7 блоков**. Не все нужны каждый раз, но порядок одинаков:

```
[РОЛЬ]        — кто ты в этой задаче (sr. Go dev / product designer / reviewer)
[КОНТЕКСТ]    — что за проект, где смотреть, что считать каноном
[ЦЕЛЬ]        — конкретный результат, который ждём (не процесс — результат)
[ВВОД]        — какие данные / файлы / ссылки / Figma-ноды есть
[ОГРАНИЧЕНИЯ] — что нельзя, что обязательно, какие правила
[ФОРМАТ]      — как должен выглядеть ответ (diff / md-таблица / Figma / PR)
[ПРОВЕРКА]    — self-check перед сдачей: что должно сойтись
```

### Принципы

- **Один промт = один результат.** Не миксуем "напиши код + ревью + тесты + дизайн".
- **Каноны через ссылки.** Не пересказывай правила — отсылай к файлу (`/SOUL.md §4`).
- **Запрети галлюцинации явно.** "Не выдумывай endpoints / токены / методы — если нет в `<file>`, спроси."
- **Финальная самопроверка.** Дай агенту чеклист, по которому он подтвердит готовность.
- **Ограничь скоуп.** "Если по ходу видишь N другую проблему — занеси в `### Followups`, не чини сейчас."

### Универсальный header (вставлять перед задачей)

```
Ты работаешь в репозитории Chirp (Twitter-like соцсеть).
Canonical product spec: /SOUL.md и docs/shared/FEATURES.md.
Architecture rules backend: docs/flutter/ARCHITECTURE_RULES.md (для Flutter)
и backend/CLAUDE.md / SOUL.md §2 (для Go).
Visual design canon: design/03-tokens/ и design/04-components/.

Не выдумывай endpoints, тип-сигнатуры, токены, имена файлов.
Если данных нет — спрашивай или фиксируй открытый вопрос в `### Открытые вопросы`.
Прежде чем писать код, прочитай файлы, на которые ссылается задача.
```

---

## 2. Code — написание новой функциональности

### Шаблон

```
[РОЛЬ]
Senior Go backend dev (или Flutter dev, или web dev) в проекте Chirp.

[КОНТЕКСТ]
Каноны:
- /SOUL.md §3-§4 — доменные модули
- docs/shared/FEATURES.md — что за фича
- docs/shared/API.md — формат HTTP-эндпоинтов
- docs/shared/ERRORS.md — формат ошибок
- backend/ — слои transport/usecase/port/adapter/domain
- docs/examples/follow-timeline/ — образец полной фичи

[ЦЕЛЬ]
Реализовать фичу <название> в модуле <модуль>.
Конкретно: <одно предложение того, что должно работать>.

[ВВОД]
- Спека: <ссылка на md или коммит / Linear>
- Связанные тесты: <если есть>
- Затрагиваемые файлы: <список или "найди сам через grep">

[ОГРАНИЧЕНИЯ]
- Чистая архитектура: domain не импортирует ничего, usecase зависит только от port
- Не править adapter без необходимости — сначала port → usecase
- Все новые endpoints — под /api/v1/, swagger-аннотации обязательны
- Логирование через log/slog, structured fields
- Никакого panic в usecase — всё через ошибки
- Имена тестов: TestUsecase_<Method>_<Scenario>

[ФОРМАТ]
1. План: какие файлы создаются/меняются, по слоям
2. Реализация: коммитабельный diff
3. Тесты: unit для usecase, integration для adapter (postgres + in-memory)
4. Документация: обновить docs/shared/API.md если новые endpoints

[ПРОВЕРКА — пройди перед сдачей]
- [ ] make test проходит локально
- [ ] swagger.json пересобран (если поменялись handlers)
- [ ] In-memory adapter обновлён симметрично postgres
- [ ] Нет magic strings — все статусы/коды через константы
- [ ] Логи без PII (email/password/token)
- [ ] Открытые вопросы вынесены в финальную секцию

[FOLLOWUPS]
Если попутно нашёл refactor-возможности или баги вне скоупа — занеси сюда списком, не чини.
```

### Мини-вариант (для маленьких задач)

```
Добавь endpoint POST /api/v1/tweets/{id}/bookmark в модуль tweet.
Спека: docs/shared/FEATURES.md § Bookmarks.
Полный набор: domain entity + port interface + usecase + http handler + in-memory adapter + postgres adapter + миграция + unit тесты.
Не править остальные модули. Если конфликт со спекой — спроси.
```

---

## 3. Code review

### Шаблон

```
[РОЛЬ]
Опытный code-reviewer, фокус на корректность, безопасность, чистоту архитектуры.

[КОНТЕКСТ]
Архитектурные правила: /SOUL.md §2, docs/flutter/ARCHITECTURE_RULES.md.
Стиль: смотри как написаны соседние модули.

[ЦЕЛЬ]
Ревью PR <#NN> или diff <ссылка / "текущий branch против main">.
Вернуть список конкретных замечаний с приоритетами.

[ВВОД]
- Diff: <git diff main...HEAD или ссылка>
- Описание PR: <copy/paste>
- Связанная спека: <если есть>

[ОГРАНИЧЕНИЯ]
- Не nitpick стиль, который не нарушает rules
- Замечание = конкретная строка + конкретное предложение
- Не предлагай рефакторинг, если он out of scope PR

[ФОРМАТ]
Таблица:
| Приоритет | Файл:строка | Проблема | Предложение |
|-----------|-------------|----------|-------------|
| 🔴 must  | … | … | … |
| 🟡 should | … | … | … |
| 🟢 nice   | … | … | … |

Плюс краткое summary: общая оценка + 1-2 главных риска.

[ПРОВЕРКА]
- [ ] Каждое 🔴 имеет цитату правила или ссылку на бажный сценарий
- [ ] Архитектурные нарушения подсвечены (domain зависит от транспорта и т.п.)
- [ ] Security: SQL injection, log injection, IDOR, leaked secrets
- [ ] Concurrency: гонки, забытые контексты, не отменённые горутины
- [ ] Тесты покрывают изменения
```

### Чеклист-вариант (для быстрого ревью)

```
Просмотри текущий diff. Сверь по чеклисту, верни только нарушения:

Architecture
- domain не импортирует ничего за пределами domain
- usecase не импортирует adapter (только port)
- transport не вызывает adapter напрямую

Errors
- ошибки оборачиваются с контекстом (fmt.Errorf("%w: %s", ...))
- 4xx vs 5xx статусы корректны
- формат ответа = docs/shared/ERRORS.md

Tests
- новые публичные функции покрыты
- table-driven где >= 3 кейсов
- нет httptest без teardown

Security
- нет hardcoded secrets
- bcrypt cost >= 10
- input validation на границе transport
- никакого PII в логах
```

---

## 4. Refactoring

### Шаблон

```
[РОЛЬ]
Сеньор-разработчик, специализация на refactoring без изменения поведения.

[КОНТЕКСТ]
- Архитектура: /SOUL.md §2
- Существующие тесты — твой safety net

[ЦЕЛЬ]
Зарефакторить <модуль / функцию / файл> так, чтобы <конкретное улучшение>.
Поведение НЕ меняется. Внешний API НЕ меняется.

[ВВОД]
- Что: <конкретный файл/функция>
- Почему: <ссылка на code-review замечание или техдолг>
- Метрика успеха: читаемость / производительность / тестабельность

[ОГРАНИЧЕНИЯ]
- Не менять публичный интерфейс
- Все существующие тесты должны проходить без правки
- Если без правки теста никак — это сигнал, что API меняется → STOP, спроси
- Не миксуй refactoring с feature/bugfix — отдельный коммит

[ФОРМАТ]
1. Before/after: что было, что стало (короткий пример)
2. Diff
3. Подтверждение: `make test` зелёный
4. Перечень что НЕ трогал и почему (чтобы scope был виден)

[ПРОВЕРКА]
- [ ] Все существующие тесты проходят без правки
- [ ] Coverage не упал (если есть coverage-tool)
- [ ] Цикломатическая сложность функций не выросла
- [ ] Никаких TODO/FIXME без issue/контекста
```

### Анти-паттерн (предупреждение в промте)

```
Запреты на refactoring:
- ❌ "Заодно" не переименовывай переменные в соседних функциях
- ❌ Не добавляй новые абстракции "на будущее" (premature abstraction)
- ❌ Не меняй formatting во всём файле — только в трогаемых строках
```

---

## 5. Bug fix / debugging

### Шаблон

```
[РОЛЬ]
Дебагер. Фокус — найти root cause, не симптом.

[КОНТЕКСТ]
Каноны архитектуры — те же.
История — `git log` затронутых файлов.

[ЦЕЛЬ]
Починить баг: <одно предложение, что воспроизводится>.

[ВВОД]
- Симптом: <логи / скриншот / шаги воспроизведения>
- Версия: <commit hash>
- Окружение: <prod / dev / local>
- Что уже пробовали: <если есть>

[ОГРАНИЧЕНИЯ]
- Сначала reproduce, потом fix
- Сначала root cause, потом patch
- Регрессионный тест ОБЯЗАТЕЛЕН (тест, который падает до фикса, проходит после)
- Минимальный diff. Не "заодно почисти"

[ФОРМАТ]
1. **Reproduce.** Шаги или тест, который ловит баг.
2. **Root cause.** Что именно ломается и почему. Цитаты из кода.
3. **Fix.** Diff.
4. **Regression test.** Код теста.
5. **Risk.** Что ещё могло этот код задеть?

[ПРОВЕРКА]
- [ ] Тест из шага 4 падает на pre-fix коммите
- [ ] Тест проходит на post-fix коммите
- [ ] make test зелёный
- [ ] Соседние тесты не сломались
- [ ] Если фикс затронул общий код — пробежался по другим вызывающим
```

---

## 6. Tests

### Шаблон

```
[РОЛЬ]
Tester. Покрываешь функцию/модуль тестами.

[КОНТЕКСТ]
Стиль тестов: см. docs/flutter/TESTING.md (для Flutter) или соседние *_test.go (для Go).
Не используем моки там, где можно in-memory adapter.

[ЦЕЛЬ]
Покрыть <функция / usecase / экран> тестами.

[ВВОД]
- Что тестируем: <ссылка>
- Тип теста: unit / integration / widget / golden

[ОГРАНИЧЕНИЯ]
- Table-driven при >= 3 кейсах
- Не тестируем приватные функции напрямую — через публичный API
- Не моки БД — используем in-memory adapter
- Нет фейк-ассертов (assert.True(true))

[ФОРМАТ]
1. Список кейсов (happy + error + edge)
2. Код тестов
3. Команда запуска: `go test -run TestX ./...`

[ПРОВЕРКА]
- [ ] Happy path
- [ ] Каждая ветка ошибок
- [ ] Boundary (пустой ввод, max длина, nil)
- [ ] Concurrency, если применимо
- [ ] Тест не зависит от порядка запуска
- [ ] Нет sleep — используем синхронизацию
```

---

## 7. Design — экран

### Шаблон

```
[РОЛЬ]
Product designer Chirp. Рисуешь в Figma через MCP-tool (или описываешь спекой).

[КОНТЕКСТ]
- Продукт: /SOUL.md, docs/shared/FEATURES.md
- Tokens: design/03-tokens/ (КАНОН — никаких raw hex/px)
- Компоненты: design/04-components/ (используем существующие, не дублируем)
- Naming в Figma: design/_ai/FIGMA-RULES.md
- Контракт design↔code: docs/shared/DESIGN-CONTRACT.md

[ЦЕЛЬ]
Нарисовать экран <ScreenName> для платформы <Mobile/Web>.

[ВВОД]
- Экран: <название из docs/shared/SCREENS.md>
- Behavior: <ссылка>
- Состояния обязательны: Default, Loading, Empty, Error, (LoadingMore если список)
- Размер: Mobile 390×844, Web 1440×900 (по умолчанию)
- Тема: Light по умолчанию, Dark при запросе

[ОГРАНИЧЕНИЯ]
- Только токены из design/03-tokens/ (никаких raw hex/px/font-name)
- Только компоненты из design/04-components/ (новые — отдельно согласовать)
- Все состояния — отдельными фреймами в одном Page
- Иконки — Phosphor Regular, см. design/03-tokens/icons.md
- Никаких emoji в UI chrome
- Auto-layout везде, magic numbers запрещены

[ФОРМАТ]
1. План: фреймы, какие компоненты используются, какие токены
2. Diff: что меняется в design/<feature>/
3. Открытые вопросы (если есть)
4. Self-validation чеклист (см. ПРОВЕРКА)

[ПРОВЕРКА]
- [ ] Все states присутствуют
- [ ] Каждый цвет/шрифт — token (Figma style), не raw
- [ ] Каждый интерактивный элемент — instance компонента
- [ ] Naming в Figma совпадает с docs/shared/DESIGN-CONTRACT.md §1
- [ ] Иконки — из design/03-tokens/icons.md vocabulary
- [ ] Empty/Error копи — по docs/shared/ERRORS.md и copy-guide (если есть)
- [ ] Контраст текста >= AA (см. design/03-tokens/colours.md §7)
- [ ] Touch-targets >= 44×44 на mobile
```

### Compact-вариант

```
Нарисуй TimelineScreen mobile (390×844), light theme.
Состояния: Loading (3 skeleton PostCard), Empty ("No tweets yet" + CTA "Find people"), Error (retry), Data (список PostCard), LoadingMore (spinner внизу).
Все токены — из design/03-tokens/. Все компоненты — из design/04-components/.
Финальный self-check по чеклисту экрана.
```

---

## 8. Design — компонент

### Шаблон

```
[РОЛЬ]
Component designer. Создаёшь atomic компонент с variants/states.

[КОНТЕКСТ]
- Atomic уровень: design/04-components/README.md
- Tokens: design/03-tokens/component-tokens.md и semantic-mappings.md
- Spec template: design/04-components/README.md § Spec template

[ЦЕЛЬ]
Создать компонент <ComponentName> уровня <atom/molecule/organism>.

[ВВОД]
- Tier (из README.md): 1/2/3/4
- Where used: <список экранов>
- Layer (atom/molecule/organism)
- Похожие референсы: <если есть>

[ОГРАНИЧЕНИЯ]
- Один md-spec + один Figma master
- Spec следует template из README.md (Anatomy, Properties, Variants, States, Behaviour, Token references, A11y, Do/Don't)
- Каждый part компонента ссылается на component-token (НЕ на semantic напрямую)
- Если нужен новый component-token — добавь его в component-tokens.md и semantic-mappings.md одной правкой
- Variants только если визуально отличны (не плодить close-twins)

[ФОРМАТ]
1. md-spec по template
2. Figma master с variants (или текстовое описание variants для конвертера)
3. Update component-tokens.md / semantic-mappings.md если новые токены
4. Self-validation

[ПРОВЕРКА]
- [ ] Все 8 секций spec'а заполнены
- [ ] A11y секция: role, aria-label, keyboard, focus
- [ ] Все цвета — через component-token → semantic → primitive
- [ ] Disabled / focus / hover / pressed states описаны
- [ ] Don't section не пустая
- [ ] Naming в Figma соответствует FIGMA-RULES.md
```

---

## 9. Design review / validation

### Шаблон

```
[РОЛЬ]
Дизайн-ревьюер. Проверяешь Figma frame или md-спеку против системы правил.

[КОНТЕКСТ]
- Правила: design/03-tokens/, design/04-components/, docs/shared/DESIGN-CONTRACT.md
- Anti-patterns: <если применимо к продуктовой области>

[ЦЕЛЬ]
Дать список нарушений правил для <frame / экран / компонент>.

[ВВОД]
- Figma URL / node ID или путь к md-спеке
- Тип проверки: full / quick / accessibility-only / tokens-only

[ОГРАНИЧЕНИЯ]
- Каждое замечание = конкретная цитата правила
- Не "красиво/некрасиво" — только нарушение правил
- Разделяй blocker vs nice-to-have

[ФОРМАТ]
| Тяжесть | Где | Что | Правило | Как исправить |
|---------|-----|-----|---------|---------------|
| 🔴 blocker | TimelineScreen/Loading top bar | raw hex #1A91DA | colours.md §5 | use `accent-hover` |

[ПРОВЕРКА]
- [ ] Tokens (нет raw hex/px/font-family)
- [ ] Naming (фреймы и слои по контракту)
- [ ] States (все обязательные присутствуют)
- [ ] Иконки (из canonical vocabulary)
- [ ] Contrast (через инструмент)
- [ ] Auto-layout (нет absolute positioning без нужды)
- [ ] Components (instances, не detach'нутые)
- [ ] Copy (по copy-guide / без emoji в chrome / без banlist слов)
```

---

## 10. Конвертация: Figma → код

### Шаблон

```
[РОЛЬ]
Дев-конвертер: переводишь Figma frame/component в код целевой платформы.

[КОНТЕКСТ]
- Figma naming = code naming: docs/shared/DESIGN-CONTRACT.md §1
- Tokens mapping: design/03-tokens/semantic-mappings.md
- Цель: <Flutter / React / SwiftUI / Kotlin>
- Архитектура UI-кода: packages/ui_kit (Flutter), либо аналог

[ЦЕЛЬ]
Сконвертировать <Figma node URL / id> в <язык> компонент.

[ВВОД]
- Figma URL / node-id
- Целевой файл: <если знаешь> или "создай по convention"
- Какие токены уже есть в коде: <ссылка на theme.dart / variables.css>

[ОГРАНИЧЕНИЯ]
- ВСЕ цвета — через `context.colors.<semantic>` (не hex)
- ВСЕ размеры — через `Spacing.<token>` (не px)
- ВСЕ шрифты — через `TextStyles.<token>`
- Компоненты — из ui_kit, не дублировать
- Auto-layout → Row/Column с правильным MainAxisSize
- Padding/Margin → EdgeInsets через токены
- Иконки → UiIcon(UiIcons.<name>) (см. docs/flutter/ICON-STRATEGY.md)
- Если в Figma найден raw hex / magic number — НЕ копировать как есть, спросить какой токен использовать

[ФОРМАТ]
1. Mapping table: Figma layer → code element + token
2. Код (полный файл)
3. Список новых токенов, если они отсутствуют
4. Расхождения с Figma (если что-то невозможно/нерекомендуемо)
5. Скриншот или golden test (если есть инструмент)

[ПРОВЕРКА]
- [ ] Никаких hex-литералов в коде
- [ ] Никаких magic numbers > 0 (кроме 0, 1, 100% и т.п.)
- [ ] Все интерактивы имеют semantic label (Semantics widget)
- [ ] Touch target >= 44 на mobile
- [ ] State variants (hover/pressed/disabled) реализованы
- [ ] Golden test или скриншот совпадает с Figma при допуске 2-3 px
```

---

## 11. Конвертация: код / спека → Figma

### Шаблон

```
[РОЛЬ]
Дизайнер-реверс-инженер: переносишь существующий код или md-спеку в Figma.

[КОНТЕКСТ]
- Naming: docs/shared/DESIGN-CONTRACT.md §1 (одинаковые имена в Figma и коде)
- Tokens в Figma — styles + variables, см. design/_ai/FIGMA-RULES.md
- Если код хардкодит значения — НЕ переносить как primitive, найти ближайший semantic-token

[ЦЕЛЬ]
Создать Figma-master компонента <Name>, эквивалентный <путь к dart/swift/tsx файлу или md-спеке>.

[ВВОД]
- Source: <путь>
- Текущие Figma-styles: design/03-tokens/* (canonical)
- Платформа источника: <Flutter / React / native>

[ОГРАНИЧЕНИЯ]
- Layer naming = code class name
- Все цвета — Figma styles из design/03-tokens/colours.md
- Все text styles — из design/03-tokens/typography.md
- Все радиусы/отступы — variables из 03-tokens
- Variants по props компонента, в формате `Property=Value`
- Auto-layout direction = Row/Column из кода

[ФОРМАТ]
1. Mapping: code prop → Figma property
2. Описание frame'а или live Figma node (через MCP)
3. Список расхождений, которые потребовали интерпретации
4. Список новых variables/styles, если нужны

[ПРОВЕРКА]
- [ ] Каждый visible part = именованный слой
- [ ] Variants покрывают все states из кода
- [ ] Token-references вместо raw values
- [ ] Component description заполнено (1 предложение что это и где используется)
```

---

## 12. Research

### Шаблон

```
[РОЛЬ]
Product researcher. Не пишешь маркетинг — собираешь evidence.

[КОНТЕКСТ]
Скоуп исследования = одна гипотеза или вопрос.

[ЦЕЛЬ]
Ответить на вопрос: <вопрос>.

[ВВОД]
- Доступные источники: web (если разрешён), документы проекта
- Глубина: quick (1-2 источника) / standard (3-5) / deep (>= 6 + cross-check)

[ОГРАНИЧЕНИЯ]
- Каждое утверждение — с источником (ссылка / цитата / файл:строка)
- Не делай выводов без evidence
- Различай "проверено фактом" vs "гипотеза"
- Не пиши длинные эссе — bullet-list евиденса

[ФОРМАТ]
1. Вопрос (полная формулировка)
2. Краткий ответ (1-3 предложения)
3. Evidence (таблица: утверждение | источник | дата)
4. Контр-евиденс (что НЕ подтверждается / противоречия)
5. Открытые вопросы (что не удалось ответить)
6. Рекомендация (если задача требует решения)

[ПРОВЕРКА]
- [ ] Нет утверждений без ссылок
- [ ] Источники не самоповторяющиеся (один блогпост ≠ 5 ссылок)
- [ ] Указаны даты публикаций (свежесть)
- [ ] Контр-евиденс не подавлен
```

---

## 13. Briefing — постановка задачи на фичу

### Шаблон

```
[РОЛЬ]
Product / tech-lead, пишешь brief, по которому AI или другой человек реализуют фичу.

[ЦЕЛЬ]
Создать brief фичи <название>, по которому исполнитель должен суметь начать работу без уточнений.

[ВВОД]
- Идея/проблема (от заказчика)
- Связанные ранее решения

[ФОРМАТ]
Стандартный brief-шаблон:

## Контекст
<Откуда задача, какую проблему решает, чьи это слова>

## Цель (Outcome)
<Что должно измениться в продукте / метрике / поведении пользователя.
 НЕ "сделать кнопку" — а "пользователь может совершить X быстрее на Y%".>

## Скоуп
### In
- <bullet>
### Out (явно)
- <bullet>

## User flow
<Шаги пользователя 1-2-3-4. С состояниями.>

## Контракт данных
- API endpoints (новые / меняющиеся): <ссылки на docs/shared/API.md>
- Схема: <модели / поля>
- Errors: <ссылки на ERRORS.md>

## Дизайн
- Экраны: <ссылки на design/<feature>/ или TODO>
- Состояния обязательные: Default, Loading, Empty, Error
- Tokens / Components: только из 03-tokens/04-components

## Acceptance criteria
- [ ] <конкретное проверяемое условие>
- [ ] …

## Не делать
- <конкретные вещи, на которые легко скатиться "заодно">

## Open questions
- <вопросы, которые надо решить до старта>

[ПРОВЕРКА — brief готов когда]
- [ ] Outcome измерим
- [ ] Out-of-scope явно перечислен
- [ ] Acceptance criteria checkable, не маркетинговы
- [ ] Контракт данных ссылается на каноны, не описывает с нуля
- [ ] Нет фраз "красиво/удобно/современно" без определения
```

---

## 14. Analysis — анализ существующего кода/дизайна

### Шаблон

```
[РОЛЬ]
Аналитик. Не правишь — оцениваешь.

[ЦЕЛЬ]
<Аудит / discovery / what's here>: <конкретная область>.

[ВВОД]
- Что смотрим: <папка / модуль / Figma file>
- Глубина: surface (структура) / deep (логика + примеры) / forensic (git-history + декомпозиция решений)
- Целевая аудитория отчёта: <дев / дизайнер / PM>

[ОГРАНИЧЕНИЯ]
- Факты от мнений отделять
- Не предлагать рефакторинг внутри отчёта — это отдельная задача
- Размер ответа — ограничить (например, "до 800 слов")

[ФОРМАТ]
1. Tree (структура)
2. Inventory (что есть, по категориям)
3. Strengths (3-5 пунктов)
4. Weaknesses (3-5 пунктов)
5. Gaps (что отсутствует / упомянуто но не реализовано)
6. Risks (опасные места, не баги, а зоны риска)
7. Recommendations (только high-level, без подробной проработки)

[ПРОВЕРКА]
- [ ] Каждый пункт привязан к файлу/коду
- [ ] Нет дублирования между секциями
- [ ] Объективные метрики где возможно (LOC, count, depth)
```

---

## 15. Documentation

### Шаблон

```
[РОЛЬ]
Технический писатель. Цель — чтобы новый человек/AI понял и применил.

[ЦЕЛЬ]
Написать/обновить документацию по <теме>.

[ВВОД]
- Существующий код / спека / поведение
- Целевой читатель: <dev / designer / PM / AI>

[ОГРАНИЧЕНИЯ]
- Не описывай WHAT (это видно из кода) — описывай WHY и HOW USE
- Примеры обязательны
- Ссылки на каноны вместо пересказа
- Не плодить дубликат: если уже есть в SOUL.md — сослаться

[ФОРМАТ]
1. Title + одно-предложение TL;DR
2. When to use / when NOT
3. Пример (минимальный рабочий)
4. Reference / API table
5. Related / см. также

[ПРОВЕРКА]
- [ ] TL;DR < 200 символов
- [ ] Пример копируется и работает
- [ ] Нет пересказа кода
- [ ] Все ссылки рабочие
- [ ] Дата последнего обновления (или git-aware)
```

---

## 16. Migration / breaking change

### Шаблон

```
[РОЛЬ]
Maintainer. Готовишь breaking change с миграционным гайдом.

[КОНТЕКСТ]
- Policy: docs/BREAKING-CHANGES.md
- Текущая версия API: v1

[ЦЕЛЬ]
Внести breaking change: <что меняется>.

[ВВОД]
- Что: <endpoint / поле / схема>
- Почему: <ссылка на обоснование>

[ОГРАНИЧЕНИЯ]
- ОБЯЗАТЕЛЬНО запись в docs/BREAKING-CHANGES.md по шаблону
- Параллельная поддержка старого минимум 1 фазу (см. SOUL.md §5)
- Deprecation/Sunset headers
- Клиентский гайд миграции

[ФОРМАТ]
1. Запись в BREAKING-CHANGES.md по шаблону
2. Реализация:
   - Старая версия живёт под /api/v1/
   - Новая — под /api/v2/ или поведение по версии header
3. Миграционный snippet для Flutter / Web / iOS
4. Sunset-date
5. PR description с ссылкой на запись

[ПРОВЕРКА]
- [ ] Запись в BREAKING-CHANGES.md создана
- [ ] Старая версия не удалена
- [ ] Sunset header возвращается
- [ ] Клиентские модели обновлены
- [ ] Тест на оба варианта payload
```

---

## 17. Quick prompts (one-liners)

Короткие промты для ежедневных задач. Подходят, когда контекст уже разогрет.

### Code

```
Add field `bookmarked_count` (int, default 0) to Tweet domain entity, port, postgres+in-memory adapters, и response DTO. Без новых endpoints. Тесты по соседним добавь.
```

```
В модуле user найди дубликат валидации username (regex повторяется?). Если да — вынеси в одну функцию domain.ValidateUsername. Тесты обнови.
```

### Review

```
Просмотри текущий branch против main. Верни только 🔴 must-fix замечания, без 🟡/🟢. Если нет 🔴 — скажи "clean".
```

```
Sanity-check последнего коммита: nil-checks, error wrapping, log fields. Список или "clean".
```

### Bug

```
Воспроизведи: <шаги>. Найди root cause. Покажи fix + регрессионный тест. Минимальный diff.
```

### Design

```
Нарисуй TimelineScreen mobile, light, все states. Только токены и компоненты из design/. Self-validate в конце.
```

```
Валидируй TimelineScreen/Loading фрейм в Figma. Верни таблицу нарушений или "clean".
```

### Convert

```
Сконвертируй Figma node <id> в lib/widgets/post_card.dart. Используй ui_kit токены и UiIcon. Никаких hex и magic numbers.
```

### Research

```
Quick research (max 5 источников): <вопрос>. Формат — bullet-evidence с ссылками. Дай рекомендацию в 1 предложение.
```

### Brief

```
Сделай brief из идеи: <идея>. По шаблону §13 этого файла. Open questions выдели явно.
```

### Analyze

```
Surface-аудит /flutter (структура только). Tree + strengths/weaknesses/gaps. До 500 слов.
```

### Document

```
Документация для модуля <name>: TL;DR + when-to-use + минимальный пример. Не пересказывай код.
```

### Refactor

```
Зарефактори <функция> для читаемости. Поведение не меняется, тесты без правки. Минимальный diff.
```

---

## Anti-patterns в промтах (не делать)

| Анти-паттерн | Почему плохо | Как лучше |
|--------------|--------------|-----------|
| "Сделай красиво" | AI выдаст галлюцинации | "Через токены из design/03-tokens/" |
| "Как считаешь правильным" | Размывает scope | Чёткий формат + чеклист |
| "И ещё посмотри, может, рефакторинг" | Скоуп взрывается | "Followups в отдельную секцию, не чинить" |
| Без указания канона | AI выдумает | Всегда `см. <file>` |
| Без формата ответа | Получишь эссе | Таблица / diff / md-секции |
| Без самопроверки | Срываются скрытые баги | `[ПРОВЕРКА]` блок обязателен |
| "Используй best practices" | Best practices — фантом | Конкретные правила из docs/ |
| Несколько задач в одном промте | Размытое внимание AI | Один промт = один результат |

---

## Maintenance

Когда обновлять этот файл:

- Появился новый тип частых задач → новая секция
- Шаблон перестал работать (AI стабильно ошибается) → пересмотреть ограничения и формат
- Появились новые каноны (новые файлы в `docs/shared/`, `design/03-tokens/` и т.п.) → обновить ссылки в `[КОНТЕКСТ]` блоках
- Banlist промтов растёт → пополнять секцию anti-patterns

Связанные документы:
- `/SOUL.md` — продуктовый канон
- `docs/shared/` — функциональные спеки
- `design/_ai/` — AI-инструкции по design-работе
- `docs/WORKFLOW.md` — общий процесс работы над фичей
- `docs/BREAKING-CHANGES.md` — policy ломающих изменений
