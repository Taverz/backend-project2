# ui_kit

Дизайн-система Chirp: темы, иконки, виджеты. Все экраны приложения собираются из примитивов этого пакета.

## Зачем существует

Внутри `ui_kit` Material **можно** использовать — это слой, который оборачивает Material своим API (`AppButton`, `AppTextField`, `AppAppBar`). Снаружи (в `apps/chirp`) Material **нельзя**, кроме `Scaffold`. Граница ровно одна: импорт `package:flutter/material.dart` разрешён только внутри `packages/ui_kit/lib/widgets/...`.

Это даёт три вещи: единый визуал, возможность когда-нибудь сменить базу (Material → собственная отрисовка), и тестируемость дизайн-системы изолированно через storybook.

## Что внутри

- **Темы** (`lib/theme/`): `AppColors`, `AppTypography`, `AppTheme`.
- **Иконки** (`lib/icons/`, `assets/icons/`): SVG-ассеты + типизированный каталог `AppIcons` через `flutter_gen`.
- **Виджеты-примитивы** (`lib/widgets/`): `AppButton`, `AppTextField`, `AppIcon`, `AppLoader`, `AppAppBar`, `AppSnackBar`.
- **Виджеты-композиты**: `ErrorView`, `EmptyView`, `Avatar`, `Skeleton`, `InfiniteScrollList`.
- **Extension'ы** (`lib/extensions/`): `ContextX` (`context.theme`, `context.showSnackBar` через `AppSnackBar`).
- **Генерация** (`lib/gen/`): `Assets` от `flutter_gen` (НЕ редактировать руками — перегенерируется через `fluttergen`).

## Использование

```dart
import 'package:ui_kit/ui_kit.dart';

AppButton(label: 'Войти', onPressed: () => ...);
AppTextField(label: 'Email', controller: ...);
AppIcon(AppIcons.eyeOpen, size: 24, color: AppColors.primary);
```

## Документация для контрибьюторов

- **[`docs/WIDGET_GUIDELINES.md`](docs/WIDGET_GUIDELINES.md)** — правила построения виджетов: что попадает в ui_kit, do/don't, чек-лист ревью.
- **[`docs/MAINTENANCE.md`](docs/MAINTENANCE.md)** — справочник: как добавить иконку, цвет, виджет.

## Команды

```bash
# Регенерация Assets из SVG в assets/icons/
cd packages/ui_kit && fluttergen

# Тесты
flutter test packages/ui_kit

# Просмотр в каталоге компонентов
cd apps/storybook && flutter run
```
