# Figma v0.1 — Senior UX/UI Review (2026-06-15)

> Ревью первой AI-сборки дизайн-файла Bable в Figma через MCP.
> Цель: зафиксировать ошибки и встроить уроки в `_ai/FIGMA-RULES.md` и `_ai/AGENT.md`,
> чтобы следующая итерация не повторяла их.

---

## TL;DR

**Файл выглядит как design system, но не работает как design system.**

- Styles созданы, но компоненты используют raw hex вместо привязки → токены не работают.
- "Компоненты" — это фреймы с правильными именами, не реальные Figma components (нет `component_create`).
- Tokens-страница показывает устаревшую палитру первой итерации (фиолетовая) — file lies.
- Text styles созданы, но в текстах используется прямой `fontFamily`/`fontSize`.
- Atomic-иерархии (atom→molecule→organism) нет — только 3 атома, и те мокапы.

**Completion: ~40% от заявленного "полного паспорта".**

---

## Findings (по severity)

### ⛔ Blocking — система не работает

#### B1. Raw hex вместо style binding
В Figma созданы paint styles `bable/semantic/accent` и др., но в `node_create_frame` и `text_create` передавался `color: "#C45A3D"` напрямую. Связь компонент ↔ токен **отсутствует**.

**Правило:** после создания paint style — каждый `fill`/`stroke` бьётся через `style_apply(nodeId, styleId)`. Если стиль ещё не создан — создаём его сначала.

#### B2. Фреймы выдают себя за компоненты
Ни на одном master-фрейме (Button/Avatar/ScoreFigure) не был вызван `component_create`. Это значит:
- Нельзя сделать instance.
- Нет component properties panel.
- Нет variant override (`variant=primary`, `state=hover`).
- Нет `label` text property, нет `instance swap` для иконок.

**Правило:** после построения структуры мастера — `component_create(masterFrameId)` → `component_add_property_definition(...)` для каждой переменной из spec. Затем variant-наборы превращаются в `component_create_set`.

#### B3. Tokens-страница показывает устаревшую палитру
На странице `🎨 Tokens` нарисованы swatches первой (фиолетовой) итерации. Bable terra/warm/forest существуют только как styles — без визуальной репрезентации. Дизайнер видит фиолет → доверие к файлу нулевое.

**Правило:** при смене палитры **первым** действием — перерисовать визуальные tokens-фреймы, не последним.

#### B4. Text вне text styles
`heading/h1`, `body/md`, `caption/md` созданы как text styles, но текст в Cover/Buttons/Tokens создавался напрямую через `fontFamily`/`fontStyle`/`fontSize`. То же что B1, но для типографики.

**Правило:** каждое `text_create` сопровождается `style_apply` с соответствующим text style.

---

### 🟧 Architectural — иерархия и переиспользование

#### A1. Нет atomic-иерархии
По `04-components/README.md`: atom → molecule → organism. В файле — только 3 атома (Button/Avatar/ScoreFigure). Molecules (PostCard, ProfileHeader, EndorseButton) и organisms (Feed, Composer) отсутствуют.

Даже если бы они были — Avatar внутри PostCard был бы клоном, а не instance (см. B2). Single source of truth не работает.

**Правило:** Molecule создаётся после того, как атомы — настоящие компоненты. Avatar в PostCard добавляется через placement instance master'а Avatar, не созданием нового frame.

#### A2. Discoverability на странице Components отсутствует
Фреймы Button/Avatar/ScoreFigure стоят на канвасе без структуры. Нет:
- Figma **Sections** (`Atoms`, `Molecules`, `Organisms`).
- Index/sitemap фрейма наверху страницы.
- Component descriptions (мандатны по `FIGMA-RULES §8`).
- Tags / Status в descriptions для поиска.

**Правило:** на странице Components обязательны Sections по layer и index frame. Каждый master — с заполненным description (шаблон в `FIGMA-RULES §8`).

#### A3. Avatar `hasImage=true` — фейк
В моей реализации это просто другой цвет fallback. По спеке должен быть `image fill` с placeholder.

**Правило:** для image-вариантов использовать `paint_set_image` или `paint_set_image_url` с placeholder URL. Никаких "переоформленных fallback" под видом image.

#### A4. ScoreFigure inline нарушает spec
Spec `score-figure.md §4`: "justify-content: space-between". У меня — простой gap. Для коротких topic это ломает выравнивание в ряду. Плюс hover/pressed для `isClickable=true` не реализованы.

**Правило:** перечитать §4-5 спека компонента **перед** конструированием master frame. Проверить spec checklist в конце реализации.

---

### 🟨 Quality

#### Q1. Старая палитра не удалена
MCP не предоставляет команду удаления styles. В Figma остались `brand/primary/*`, `neutral/*`, `text/*`, `border/*` от первой итерации.

**Правило:** **до** начала смены палитры — предупредить пользователя об ограничении и попросить ручную очистку через UI. Не лить новое поверх.

#### Q2. Naming с префиксом `bable/`
По `FIGMA-RULES §6` стили именуются `surface / surface`, `accent / accent` — без brand-префикса (файл и так Bable). Я использовал `bable/...` чтобы обойти конфликт со старыми styles — это костыль, не норма.

**Правило:** держаться `FIGMA-RULES §6` naming. Если префикс нужен — это симптом проблемы.

#### Q3. Полнота: 32/72 кнопок (44%)
Заявил "полный паспорт" — сделал md state matrix (24) + sm/lg default state (8). Не хватает sm × {hover, pressed, focused, disabled, loading} + lg × то же = 40 кнопок.

**Правило:** если spec говорит 72 — либо делаем 72, либо честно сразу заявляем "deliver 32 как Tier 1, остальное — следующая итерация".

#### Q4. Cover минималистичен
`FIGMA-RULES §9` требует version, date, repo link, status. У меня — title + subtitle.

---

### 🟦 Process

#### P1. Не опросил доступные шрифты
Ошибки "Inter SemiBold not loaded", "Source Serif Pro Medium not loaded" приходили посреди работы. Надо было через `text_list_fonts` сразу узнать загруженные.

**Правило:** в начале сессии — `text_list_fonts`. Если нужный шрифт не загружен — `text_load_font`. Если не получается — флагнуть пользователю до старта работ.

#### P2. Не использовал шаблон component spec при сборке
В `04-components/README.md` есть spec template — он не использовался как чек-лист при сборке master frame. Поэтому я забыл про `hasLeadingIcon`, `instance swap`, `label` property.

**Правило:** при сборке компонента — открыть его md-spec и пройтись по `§2. Properties` + `§3. Variants` + `§5. Sizes` как по чек-листу. Каждый property — это либо variant, либо boolean, либо text, либо instance swap в Figma.

---

## Remediation plan (приоритет сверху вниз)

| # | Action | Severity | Owner |
|---|--------|---------|-------|
| 1 | Удалить старые `brand/*`, `neutral/*`, `text/*`, `border/*`, `surface/*`, `elevation/*` styles | ⛔ B3, Q1 | User (через Figma UI) |
| 2 | Renamed `bable/...` → без префикса (`semantic/accent`, `terra/500`) | ⛔ Q2 | AI (через MCP rename) |
| 3 | На `🎨 Tokens` перерисовать swatches на Bable, привязать через `style_apply` | ⛔ B3 | AI |
| 4 | `component_create` на каждом master + property definitions | ⛔ B2 | AI |
| 5 | Все fills/strokes в кнопках/аватарах/ScoreFigure → `style_apply` (вместо raw hex) | ⛔ B1 | AI |
| 6 | Все texts → `style_apply` к text styles | ⛔ B4 | AI |
| 7 | Доделать sm/lg state matrix Button (+40 кнопок) | 🟧 Q3 | AI |
| 8 | Figma Sections на Components: `Atoms` / `Molecules` / `Organisms` + index frame | 🟧 A2 | AI |
| 9 | Avatar `hasImage=true` — реальный image fill / placeholder | 🟧 A3 | AI |
| 10 | ScoreFigure inline — `primaryAxisAlignItems: SPACE_BETWEEN` | 🟧 A4 | AI |
| 11 | Component descriptions у каждого master (по `FIGMA-RULES §8`) | 🟨 A2 | AI |
| 12 | Обновить Cover (version, date, status, repo link) | 🟨 Q4 | AI |
| 13 | Начать molecules: `Molecule/ProfileHeader` (Avatar+ScoreFigure as instances), `Molecule/PostCard` | 🟨 A1 | AI |

---

## Lessons → встроить в `_ai/FIGMA-RULES.md`

Добавляется секция §14 "Common AI/MCP pitfalls":

1. **Paint style ≠ apply.** Создание style не привязывает его к ноде. Каждый fill/stroke — `style_apply(nodeId, styleId)`.
2. **Frame ≠ Component.** Без `component_create` это не компонент.
3. **Properties — это контракт.** Каждый property из md-spec должен стать variant/boolean/text/instance swap в Figma master.
4. **Tokens page обновляется первой**, не последней.
5. **Шрифты — opt-in.** `text_list_fonts` в начале сессии. `text_load_font` при необходимости.
6. **MCP не удаляет styles.** Если меняем палитру — пользователь чистит вручную **до** начала, не после.
7. **Sections + descriptions** на Components page для discoverability.
8. **Honest deliverables.** "Полный паспорт" — это полный паспорт. Если не можем — сразу обозначаем Tier 1 / Tier 2.

---

## Что переделать в файле перед "v0.2"

В порядке исполнения:

```
1. [User]   Delete old styles in Figma UI
2. [AI]     Rename bable/* → without prefix
3. [AI]     Repaint Tokens page swatches on Bable palette
4. [AI]     style_apply на 100% fills/strokes/texts в существующих фреймах
5. [AI]     component_create + property definitions на 3 atom-master'ах
6. [AI]     Sections + index + descriptions на Components page
7. [AI]     Avatar real image fill
8. [AI]     ScoreFigure space-between для inline + hover/pressed states
9. [AI]     +40 buttons (sm/lg остальные states)
10. [AI]    Molecules: ProfileHeader, PostCard
```

Только после п.6 имеет смысл делать molecules — иначе они снова будут моками с raw hex.
