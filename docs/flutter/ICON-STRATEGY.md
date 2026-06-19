# Flutter — Icon Strategy

> Как иконки попадают из дизайна в Flutter-приложение.
> Источник истины по набору и naming — `design/03-tokens/icons.md`.

---

## Решение

| Вопрос | Решение |
|--------|---------|
| Набор иконок | **Phosphor Icons**, Regular weight |
| Способ доставки | **Self-host SVG в asset-bundle**. Никакого CDN, никакого runtime fetch. |
| Pub-пакет | **Не используем** `phosphor_flutter` |
| Формат в asset | SVG (24×24 viewBox), `currentColor` для fill/stroke |
| Renderer | `flutter_svg` (читает SVG, рендерит как widget) |
| Где живут asset'ы | `packages/ui_kit/assets/icons/*.svg` |
| Где живёт API | `packages/ui_kit/lib/src/icons/` |
| Codegen | Генератор `_icons.g.dart` из имён файлов (build_runner-task) |

---

## Почему self-host, а не CDN / pub-package

| Вариант | Плюс | Минус | Вердикт |
|---------|------|-------|---------|
| **Self-host SVG в asset** | Offline-first, нет runtime-зависимости, контроль над набором, размер бандла растёт только от используемых иконок (tree-shake assets) | Нужна процедура добавления иконки | ✅ выбран |
| `phosphor_flutter` pub-package | Полный набор сразу | +~2 MB на бандл за весь Phosphor, привязка к чужому релиз-циклу, нельзя кастомизировать stroke | ❌ |
| CDN runtime fetch | Можно менять набор без релиза | Зависимость от сети, мигание плейсхолдеров, оффлайн = пустой UI, риск 3-rd party uptime | ❌ |
| Material `Icons.*` | Готовые имена, no asset | Стиль не соответствует editorial calm (см. `design/03-tokens/icons.md`), Material weight `400` ≠ Phosphor Regular 1.5px | ❌ |
| SF Symbols (iOS) / Material (Android) per-platform | Native feel | Двойное поддержание + расхождение визуала между платформами — нарушает контракт | ❌ |

**Главное:** consistency editorial calm важнее, чем native feel. Phosphor Regular 1.5px — точка истины.

---

## Процесс добавления иконки

1. Иконка появляется в `design/03-tokens/icons.md` секции "Canonical icon vocabulary".
2. Дизайнер экспортирует SVG из Figma (или скачивает с phosphoricons.com).
3. Кладёт в `packages/ui_kit/assets/icons/<phosphor-name-kebab>.svg`.
   Пример: `ArrowFatUp` → `arrow-fat-up.svg`.
4. Запуск `dart run build_runner build --delete-conflicting-outputs` в
   `packages/ui_kit`.
5. Codegen создаёт `lib/src/icons/_icons.g.dart` с enum-like API:
   ```dart
   abstract class UiIcons {
     static const arrowFatUp = UiIconAsset('assets/icons/arrow-fat-up.svg');
     static const chatText  = UiIconAsset('assets/icons/chat-text.svg');
     ...
   }
   ```
6. Виджет потребления:
   ```dart
   UiIcon(UiIcons.arrowFatUp, size: UiIconSize.sm, color: context.colors.textSecondary)
   ```
7. Тесты `packages/ui_kit/test/icons/icon_inventory_test.dart`
   проверяют: каждое имя из `design/03-tokens/icons.md` имеет файл.
   Без файла — тест падает.

---

## SVG требования к экспорту

| Параметр | Значение |
|----------|---------|
| viewBox | `0 0 24 24` (Phosphor canonical) |
| Stroke | 1.5px (Regular weight). Не outline'им — оставляем stroke. |
| Stroke linecap / linejoin | `round` / `round` |
| Цвет | `currentColor` для всех stroke/fill |
| Filled варианты | Используем Phosphor `Fill` weight только для selected nav (см. icons.md §5 исключение) |
| Размер файла | < 2 KB (без metadata, без editor comments) |
| Optimization | `svgo` с пресетом `default`. Скрипт: `tools/svgo-icons.sh`. |

Pre-commit hook (`tools/check-svg.sh`) валидирует viewBox и currentColor
перед коммитом — иначе CI падает.

---

## API в коде

### Размеры

`UiIconSize` маппит токены из `design/03-tokens/icons.md`:

```dart
enum UiIconSize {
  xs(12), sm(16), md(20), lg(24), xl(32), xxl(48);

  final double px;
  const UiIconSize(this.px);
}
```

### Цвет

По умолчанию — `text-secondary` (`context.colors.textSecondary`).
Никогда не хардкодим hex. Цвет передаётся через `currentColor`, который
SVG наследует от `color` параметра flutter_svg.

### Виджет

```dart
class UiIcon extends StatelessWidget {
  final UiIconAsset icon;
  final UiIconSize size;
  final Color? color;

  const UiIcon(this.icon, {this.size = UiIconSize.sm, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      package: 'ui_kit',
      width: size.px,
      height: size.px,
      colorFilter: ColorFilter.mode(
        color ?? context.colors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }
}
```

---

## Что НЕ делаем

- ❌ Не используем `Icon(Icons.foo)` Material Icons где-либо в UI-коде
  фичей. Lint-rule в `analysis_options.yaml` запрещает import
  `package:flutter/material.dart` Icons-класса из feature-кода.
- ❌ Не кладём иконки в feature-пакеты (`apps/chirp/lib/features/.../icons/`).
  Всё через `ui_kit`.
- ❌ Не подключаем `font_awesome_flutter` или другие icon-fonts —
  размер шрифта раздувает бандл и плохо контрастирует с editorial UI.
- ❌ Не рендерим emoji в качестве иконки UI chrome.
  См. `design/03-tokens/icons.md` § 4 (Никаких emoji в UI chrome).

---

## Tree-shaking

Flutter не shake'ит asset'ы автоматически. Используем
`flutter_assets_filter` или ручную проверку:

```bash
flutter build apk --analyze-size
```

В отчёте видны все включённые SVG. Иконка без `UiIcons.xxx` reference —
кандидат на удаление. CI-job `tools/unused-icons.sh` запускается
еженедельно.

---

## Связанные документы

- `design/03-tokens/icons.md` — canonical vocabulary, размеры, цвета
- `packages/ui_kit/README.md` — package-level usage
- `docs/shared/DESIGN-CONTRACT.md` § 3 — общий контракт по иконкам между
  дизайном и кодом
- `docs/flutter/ARCHITECTURE_RULES.md` — где лежат UI-примитивы
