# Session Status — 2026-06-15

> Где остановились, что сделано, что осталось.
> Работа в Figma в этой сессии **остановлена пользователем**.

---

## Контекст

Сессия началась с критики и ревью первой Figma-сборки v0.1
(см. [`REVIEW-2026-06-15-figma-v0.1.md`](REVIEW-2026-06-15-figma-v0.1.md)).
В ревью было **14 findings** + **13-пунктовый remediation roadmap**.
Пользователь дал команду пройти roadmap. Прошли частично, потом стоп.

---

## Что реально исправлено (из 14 findings)

| # | Finding | Severity | Status |
|---|---------|---------|--------|
| B1 | Raw hex вместо style binding | ⛔ | 🟡 **Частично** — Tokens page (48 swatches) привязаны. На компонентах привязано только 2 fills (primary default md, primary hover md). Остальные **по-прежнему raw hex.** |
| B2 | Frame ≠ Component (нет `component_create`) | ⛔ | ✅ **Исправлено** — все 3 atom set'а превращены в реальные Component Sets: `Atom/Button` (32), `Atom/Avatar` (8), `Atom/ScoreFigure` (12). |
| B3 | Tokens page показывает старую фиолетовую палитру | ⛔ | ✅ **Исправлено** — старые swatches удалены, нарисованы новые Bable (warm/terra/status/semantic), все привязаны к paint styles. |
| B4 | Text вне text styles | ⛔ | ❌ **Не исправлено** — text styles в файле остаются пустышками (`style_create_text` принимает только name+description, не font properties — известное ограничение MCP). |
| A1 | Нет atomic-иерархии (только атомы, без molecules) | 🟧 | ❌ Молекул нет — но это и не входило в roadmap для этой сессии. |
| A2 | Discoverability на Components отсутствует (нет Sections, index, descriptions) | 🟧 | ❌ **Не исправлено**. |
| A3 | Avatar `hasImage=true` — фейк | 🟧 | ❌ **Не исправлено**. |
| A4 | ScoreFigure inline — нет space-between, нет hover/pressed | 🟧 | ❌ **Не исправлено**. |
| Q1 | Старая фиолетовая палитра не удалена | 🟨 | ❌ **Не получится через MCP** — нет команды удаления styles. Только пользователь вручную через Figma UI. |
| Q2 | Naming с префиксом `bable/` | 🟨 | ❌ **Не получится через MCP** — `node_rename` не работает на style ID (Node not found). Проверено. |
| Q3 | Полнота 32/72 кнопок (44%) | 🟨 | ❌ **Не исправлено** — sm/lg остальные states не добавлены (40 кнопок). |
| Q4 | Cover минималистичен | 🟨 | ❌ **Не исправлено**. |
| P1 | Не опросил доступные шрифты | 🟦 | ✅ В этой сессии сделано — `text_list_fonts` + установлено что Inter имеет "Semi Bold" с пробелом, Source Serif Pro не имеет Medium. |
| P2 | Не использовал spec template как чек-лист | 🟦 | ⚪ Process — применяется в будущей работе. |

**Итог: из 14 findings → 3 ✅ исправлено, 2 ❌ заблокированы MCP, 1 🟡 частично, 8 ❌ остались.**

---

## Что реально сделано в roadmap (из 13 пунктов)

| # | Action | Status |
|---|--------|--------|
| 1 | Удалить старые `brand/*`, `neutral/*`, `text/*`, `border/*`, `surface/*`, `elevation/*` styles | ❌ Пользователь не делал. MCP не может. |
| 2 | Renamed `bable/...` → без префикса | ❌ **MCP не позволяет.** Проверено — `node_rename` на style ID отдаёт "Node not found". |
| 3 | Перерисовать `🎨 Tokens` swatches на Bable + style_apply | ✅ Сделано. 48 swatches привязаны к styles. |
| 4 | `component_create` на каждом master + property definitions | 🟡 **Частично.** `component_create` и `component_create_set` сделаны на всех 52 фреймах → 3 Component Sets. Property definitions через `component_add_property_definition` **не добавлены** — variant properties Figma вывела автоматически из формата имён `variant=X, state=Y, size=Z`. Boolean (`hasLeadingIcon`, `fullWidth`), Text (`label`), Instance swap (`leadingIcon`) — **не добавлены**. |
| 5 | Все fills/strokes → `style_apply` | 🟡 **Только 2 из ~60.** Primary md default + Primary md hover. Остальные кнопки, аватары, ScoreFigure — по-прежнему raw hex. |
| 6 | Все texts → `style_apply` к text styles | ❌ Не делалось. Text styles всё равно пустые shells (см. B4). |
| 7 | Доделать sm/lg state matrix Button (+40 кнопок) | ❌ |
| 8 | Figma Sections (Atoms/Molecules/Organisms) + index frame на Components | ❌ |
| 9 | Avatar real image fill | ❌ |
| 10 | ScoreFigure inline space-between + hover/pressed | ❌ |
| 11 | Component descriptions у каждого master | ❌ |
| 12 | Cover update (version, date, status, repo link) | ❌ |
| 13 | Начать molecules (`ProfileHeader`, `PostCard`) | ❌ |

**Итог: 1 ✅ + 2 🟡 + 10 ❌.**

---

## Что было заблокировано инструментом

Эти проблемы AI **не может** решить через MCP — нужно вручную в Figma UI:

1. **Удаление старых styles** — нет команды.
2. **Переименование styles** — `node_rename` не работает на style ID.
3. **Настройка text styles** — `style_create_text` принимает только name + description, без font properties. Тексты остаются shells даже после `style_apply`.

Эти ограничения добавлены в [`FIGMA-RULES.md §14`](FIGMA-RULES.md) (14.1–14.10).

---

## Конкретно где остановились в Figma

Последнее действие в Figma в этой сессии:
- `style_apply` к компоненту `4:67` (variant=primary, state=hover, size=md) → fill = `bable/semantic/accent-hover`.

После этого пользователь сказал **СТОП**. Дальше не делалось.

---

## TODO для следующей сессии

### Сначала вручную пользователь (через Figma UI):
1. Удалить старые фиолетовые styles: `brand/primary/*`, `brand/secondary/*`, `neutral/0..1000`, `surface/{background,subtle,elevated,overlay}`, `text/{primary,secondary,muted,inverse,brand}`, `border/{subtle,default,strong,focus}`, `semantic/{success,warning,error,info}/*`, `elevation/{xs,sm,md,lg,xl}`, `focus/ring`.
2. Переименовать Bable styles: убрать префикс `bable/` (`bable/terra/500` → `terra/500`, `bable/semantic/accent` → `semantic/accent`, и т.д.).
3. Настроить text styles вручную: открыть каждый (`heading/h1`, `body/md` и т.д.) → задать font family + size + weight + line height согласно описанию в name.

### Потом AI (через MCP) может:
4. Привязать оставшиеся fills/strokes на ~58 фреймах компонентов к `semantic/*` styles.
5. Добавить property definitions:
   - Button: boolean `hasLeadingIcon`, `hasTrailingIcon`, `fullWidth` + text `label` + instance swap `leadingIcon`, `trailingIcon`.
   - Avatar: text `username`, `imageUrl`, boolean `withBorder`.
   - ScoreFigure: text `topic`, `value`.
6. Доделать sm/lg state matrix для Button (+40 кнопок).
7. Создать Figma Sections (`Atoms`, `Molecules`, `Organisms`) на странице Components + index frame наверху.
8. Заполнить component description у каждого master (по шаблону `FIGMA-RULES §8`).
9. Avatar `hasImage=true` — заменить mock на реальный image fill (`paint_set_image_url` с placeholder).
10. ScoreFigure inline — `primaryAxisAlignItems: SPACE_BETWEEN`. Добавить состояния hover/pressed для `isClickable=true`.
11. Обновить Cover: version, date, status, repo link.
12. Создать molecules `ProfileHeader`, `PostCard` (Avatar+ScoreFigure as instances).

---

## 4 блокера к molecules — статус по каждому

Это узкое горлышко: пока эти 4 пункта не закрыты, строить molecules (PostCard, ProfileHeader) **нельзя** — иначе блокеры наследуются.

| Блокер | Статус | Детали |
|--------|--------|--------|
| Атомы — не Components (нет `component_create`) | ✅ **Снят** | Все 52 фрейма → 3 Component Sets: `Atom/Button` (32), `Atom/Avatar` (8), `Atom/ScoreFigure` (12). Полноценные Figma Components, можно делать instances. |
| Все цвета — raw hex, не styles | 🟡 **Начал и бросил** | Tokens page (48 swatches) — ✅ привязаны. Компоненты — привязал только 2 fills из ~60 (primary default md + primary hover md). Остальные 58 — по-прежнему raw hex. **Блокер не снят.** |
| Text styles не применены | ❌ **Не исправлял** | `style_apply` на text nodes не делался. Плюс text styles в файле — пустые shells (MCP не задаёт font properties через `style_create_text`). Даже если бы применил — визуально не дало бы эффекта. |
| Старая фиолетовая палитра не очищена | ❌ **Вне возможностей MCP** | `style_remove` удаляет binding с ноды, не сам стиль. `node_rename` на style ID → "Node not found". Только вручную через Figma UI. |

**Итог по блокерам: 1 снят, 1 начат-брошен, 1 не сделан, 1 невозможен через MCP.**

К molecules переходить **нельзя**: 58 raw hex в компонентах никуда не делись + старая палитра живёт в файле. Если построить PostCard сейчас — Avatar как instance подхватит свои raw hex (не styles), и проблема унаследуется.

---

## Файлы документации в design/_ai/

- [`REVIEW-2026-06-15-figma-v0.1.md`](REVIEW-2026-06-15-figma-v0.1.md) — изначальный ревью с 14 findings + 13 пунктов roadmap.
- [`FIGMA-RULES.md`](FIGMA-RULES.md) — обновлены §13 (self-check) и добавлен §14 (MCP pitfalls).
- [`SESSION-STATUS-2026-06-15.md`](SESSION-STATUS-2026-06-15.md) — **этот файл**, snapshot где остановились.
