# ui_kit — обслуживание

Справочник рутинных операций. Правила построения виджетов — в [`WIDGET_GUIDELINES.md`](WIDGET_GUIDELINES.md), общие правила монорепо — в [`../../../CLAUDE.md`](../../../CLAUDE.md). Этот файл — только про «как». Зачем — там.

---

## Иконки

### Добавить

1. SVG в `assets/icons/<name>.svg` (один цвет, `currentColor`).
2. `cd packages/ui_kit && fluttergen` — обновит `lib/gen/assets.gen.dart`.
3. Getter в `lib/icons/app_icon_data.dart`:
   ```dart
   static SvgGenImage get newIcon => Assets.icons.newIcon;
   ```
4. Use-case в `apps/storybook/lib/use_cases/app_icon_use_cases.dart` (как минимум — в существующий «Catalog»).
5. Коммит — SVG, `assets.gen.dart`, getter и use-case одной правкой.

### Удалить

1. `grep -rln "AppIcons.<name>" apps/ packages/` — не должно ничего найти.
2. Удали SVG, getter в `app_icon_data.dart`, упоминание в use-case.
3. `fluttergen` — `assets.gen.dart` обновится.

### Перегенерировать

После любой правки в `assets/icons/` или в секции `flutter_gen:` в `pubspec.yaml`:

```bash
cd packages/ui_kit && fluttergen
```

`assets.gen.dart` коммитится в git вместе с правкой. Это часть публичного API пакета — не временный артефакт. Если кто-то отредактировал `assets.gen.dart` руками — просто перегенерируй.

---

## Темы

### Добавить цвет

1. В `lib/theme/app_colors.dart`:
   ```dart
   static const surfaceAccent = Color(0xFFE8F5FE);
   ```
2. Имя семантическое (`surfaceAccent`, `borderFocused`), не визуальное (`lightBlue2`).
3. Если цвет должен попасть в Material `ThemeData` (потому что Material-обёртка его подхватывает) — добавь маппинг в `app_theme.dart`.

### Добавить стиль текста

1. В `lib/theme/app_typography.dart`:
   ```dart
   static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4);
   ```
2. Имя семантическое (`caption`, `labelLarge`), не «по размеру» (`text11px`).
3. Использование везде через `AppTypography.<name>`.

### Сменить брендовый цвет

Затрагивает большинство экранов:

1. Обнови `AppColors.primary` (и dark-вариант, если различаются).
2. Прогон `grep -rn "0xFF1DA1F2" apps/ packages/` — не должно ничего быть; если есть, замени на `AppColors.primary`.
3. Обнови `AppTheme.light()` / `.dark()` если там Material-токены ссылаются на старый цвет напрямую.
4. Прогон тестов: нет проверки конкретных пикселей, всё должно остаться зелёным.

---

## Виджеты

Полный жизненный цикл — в [`WIDGET_GUIDELINES.md`](WIDGET_GUIDELINES.md). Здесь — короткие команды.

### Добавить

Чек-лист — в `WIDGET_GUIDELINES.md` §10.

```bash
# Новый файл
touch packages/ui_kit/lib/widgets/<name>.dart
touch packages/ui_kit/test/widgets/<name>_test.dart
touch apps/storybook/lib/use_cases/<name>_use_cases.dart
# Не забудь добавить экспорт в lib/ui_kit.dart и регистрацию use-cases в apps/storybook/lib/main.dart
flutter analyze
flutter test packages/ui_kit
```

### Удалить

```bash
grep -rln "<WidgetName>" apps/ packages/    # должно быть 0 (кроме самого файла)
rm packages/ui_kit/lib/widgets/<name>.dart
rm packages/ui_kit/test/widgets/<name>_test.dart
rm apps/storybook/lib/use_cases/<name>_use_cases.dart
# Удалить экспорт из lib/ui_kit.dart и регистрацию в apps/storybook/lib/main.dart
flutter analyze
```

### Рефакторинг — см. `WIDGET_GUIDELINES.md` §12.

---

## Зависимости пакета

`ui_kit` минималистичен:

- `flutter` SDK
- `flutter_svg` — отрисовка SVG-иконок

### Запрещено

- `flutter_bloc` / `provider` / любой state-manager
- `dio` / `http` / любой HTTP-клиент
- Зависимости от `app_api`, `apps/chirp/...`

Новая зависимость — обсуждается в PR.

---

## Тесты и каталог локально

```bash
# Все тесты ui_kit
flutter test packages/ui_kit

# Конкретный
flutter test packages/ui_kit/test/widgets/app_button_test.dart

# Storybook на устройстве
cd apps/storybook && flutter run -d <device>

# Storybook в web (для Figma / AI / ревью внешнему человеку без устройства)
cd apps/storybook && flutter run -d chrome
```

---

## CI и pre-commit — план, пока не настроено

Сейчас всё руками — никакого CI на проекте нет. Когда заведём, минимальный набор проверок для `ui_kit`:

- `flutter analyze` (per-package — у `ui_kit` свой `analysis_options.yaml`).
- `flutter test packages/ui_kit`.
- Сверка что `assets.gen.dart` свежий: после `fluttergen` `git diff` должен быть пустым (если есть diff — забыли перегенерировать перед коммитом).

`fluttergen` не имеет встроенного `--check`-режима; проверка делается через `git diff` после прогона.
