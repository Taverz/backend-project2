# ui_kit — правила построения виджетов

Гайд для авторов и ревьюеров. Общие правила Flutter-монорепо — в [`../../../CLAUDE.md`](../../../CLAUDE.md); этот файл — про специфику ui_kit.

> **TL;DR**
> - Сюда попадают только переиспользуемые UI-примитивы без бизнес-логики и без знания о state-manager.
> - Внутри `ui_kit` Material использовать можно (как обёртку), за пределами `ui_kit` — только `Scaffold` и `AppTextField`.
> - Все цвета — `AppColors`, типографика — `AppTypography`, иконки — `AppIcons`.
> - Каждый виджет должен иметь widget-тест и storybook use-case (минимум один информативный).

---

## 1. Что попадает в ui_kit, а что нет

### Сюда

- UI-примитивы без бизнес-логики (кнопка, поле ввода, иконка, индикатор, аватар, скелетон).
- Темы, цвета, типографика, иконки — единый источник истины.
- Виджеты, использующиеся в 2+ местах **или** заведомо переиспользуемые.

### Не сюда

- Виджеты, связанные с сущностями фичи (`TweetCard`, `FollowButton`) — это `features/<feature>/presentation/widgets/`.
- Виджеты, импортирующие state-manager (`flutter_bloc` и т.п.).
- Виджеты с сетевыми вызовами или навигацией внутри.
- Одноразовые блоки одного экрана.

### Тест на «нужно ли в ui_kit»

Если виджет работает в storybook без `AppScope`, без Bloc, без конкретной фичи — он подходит. Если без этого окружения виджет не имеет смысла — это виджет фичи.

---

## 2. Структура виджета

```dart
import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Однострочное описание: что виджет делает и когда его использовать.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final bool isLoading;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

**Порядок членов класса:** конструктор → `final`-поля → public-getter'ы → `@override build` → private-методы.

**Один публичный класс — один файл**, имя файла = `snake_case(имя класса)`.

**Виджет должен принимать всё что ему нужно как параметры конструктора.** Никакого `AppScope.of(context)` или `Provider.of` внутри виджета ui_kit.

---

## 3. Темы и цвета

### Правила

- Цвета — только `AppColors.*` (`primary`, `error`, `textPrimary`, ...).
- Текст — только `AppTypography.*` (`body1`, `headline2`, `label`, ...).
- Новый цвет добавляется в `AppColors` с **семантическим** именем (`surfaceElevated`, не `lightGrey2`).
- Не используем `Theme.of(context).colorScheme` — у нас своя дизайн-система, не Material `ThemeData`.

### Что запрещено

- Хардкод `Color(0xFF...)` в виджете.
- Inline `TextStyle(fontSize: 14, ...)` в виджете.

---

## 4. Иконки

Иконки — SVG-ассеты в `assets/icons/`, доступ через каталог `AppIcons` (типизированно, через `flutter_gen`).

### Добавить иконку

1. SVG в `assets/icons/<name>.svg`. Внутри должен быть `stroke="currentColor"` или `fill="currentColor"` — это позволяет окрашивать через `colorFilter`.
2. `cd packages/ui_kit && fluttergen` — обновит `lib/gen/assets.gen.dart`.
3. Getter в `lib/icons/app_icon_data.dart`:
   ```dart
   static SvgGenImage get heartFilled => Assets.icons.heartFilled;
   ```
4. Use-case в `apps/storybook/lib/use_cases/app_icon_use_cases.dart` (хотя бы добавить в существующий «Catalog»).

### Правила

- Использование: `AppIcon(AppIcons.eyeOpen, size: 24, color: AppColors.textSecondary)`.
- SVG одноцветные через `currentColor` — иначе `colorFilter` сломает их.
- Не использовать `Icons.X` (Material) и не делать `Image.asset(...)` напрямую — обходит каталог `AppIcons` и теряет типизацию.

---

## 5. Что можно импортировать в ui_kit

| Импорт | Разрешено? |
|--------|-----------|
| `package:flutter/widgets.dart` | да |
| `package:flutter/services.dart` | да (`TextInputAction`, `TextInputFormatter`) |
| `package:flutter/material.dart` | да, но **только** для обёрток (например, `AppTextField` оборачивает Material `TextField`). Цель: чтобы экраны вне ui_kit не пользовались Material. |
| `package:flutter/cupertino.dart` | как Material — только для обёрток |
| `package:flutter_svg/flutter_svg.dart` | да |
| Любой state-manager (`flutter_bloc`, ...) | **нет** — ui_kit чистый |
| `package:app_api/...` | нет, обратная зависимость |
| `apps/chirp/...` или `features/...` | нет, обратная зависимость |

---

## 6. State в виджетах

- `StatelessWidget` если виджет не держит UI-стейт — ≈90% случаев.
- `StatefulWidget` + `ValueNotifier` для локальной UI-логики (анимация, переключатель видимости пароля, hover-состояние).
- Бизнес-данные (списки твитов, пользователь, токены) в виджете ui_kit не хранятся — это props in.
- После `await` обязательна проверка `if (!mounted) return` перед `setState`.

---

## 7. Анимации

- `AnimationController` создаётся в `initState` (с `vsync: this`), **обязательно** диспозится в `dispose`.
- `SingleTickerProviderStateMixin` если контроллер один, `TickerProviderStateMixin` если их несколько.
- Бесконечные `repeat()`-анимации без dispose → утечка. Чек-лист ревью это ловит.

---

## 8. Доступность

Минимальный набор; пока без жёстких метрик контраста.

- Иконка-действие без видимого текста — оборачивай в `Semantics(label: '...', button: true, child: ...)`.
- Минимальный hit-target — 44×44 (`GestureDetector` без размера фактически берёт размер ребёнка; если визуально меньше, добавь `SizedBox` или `Padding`).
- Информация не должна передаваться только цветом (рамка ошибки красная + текст ошибки).

---

## 9. Тесты и storybook

Каждый новый виджет требует:

1. **Widget-тест** в `test/widgets/<name>_test.dart` — рендер + основные взаимодействия (tap, состояния enabled/disabled/loading).
2. **Storybook use-case** в `apps/storybook/lib/use_cases/<name>_use_cases.dart`. Минимум один информативный вариант; если у виджета есть значимые состояния (loading/disabled/error) — отдельный use-case на каждое.

Пример теста:

```dart
testWidgets('AppButton: tap вызывает onPressed', (tester) async {
  var tapped = false;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: AppButton(label: 'Tap', onPressed: () => tapped = true),
    ),
  );
  await tester.tap(find.byType(AppButton));
  expect(tapped, isTrue);
});
```

Что **не** тестируем: конкретные пиксели/размеры, golden-снапшоты (пока).

---

## 10. Чек-лист ревью

### Контракт
- [ ] Один публичный класс — один файл, snake_case.
- [ ] Конструктор `const`, если поля позволяют.
- [ ] Все настройки — named-параметры конструктора. Виджет не лезет в `BuildContext` за зависимостями.
- [ ] Виджет не зависит от конкретной фичи.

### Темы и иконки
- [ ] Нет `Color(0xFF...)` в коде — только `AppColors.*`.
- [ ] Нет inline `TextStyle(...)` — только `AppTypography.*`.
- [ ] Иконки — через `AppIcons.<name>`, SVG с `currentColor`.
- [ ] `fluttergen` запущен, `lib/gen/assets.gen.dart` свежий.

### Импорты
- [ ] Нет state-manager.
- [ ] Нет импортов из `app_api`, `chirp/features/*`.
- [ ] Material — только внутри обёртки.

### Жизненный цикл
- [ ] `AnimationController` и `ValueNotifier` диспозятся в `dispose`.
- [ ] Парные `addListener`/`removeListener`.
- [ ] `setState` после async — с проверкой `mounted`.

### A11y
- [ ] Иконки-действия имеют `Semantics`.
- [ ] Hit-target ≥ 44×44.

### Тесты и storybook
- [ ] Widget-тест есть.
- [ ] Storybook use-case есть, отражает основные состояния.
- [ ] `flutter analyze` чист.

---

## 11. Анти-паттерны (немедленный reject)

| Симптом | Как исправить |
|---------|--------------|
| `import 'package:flutter_bloc/...'` в `lib/widgets/` | вынеси Bloc-логику в фичу, виджет принимает только props |
| `Color(0xFF...)` в build | добавь в `AppColors` |
| `Theme.of(context).colorScheme.primary` | `AppColors.primary` |
| `Icons.X` из material | заведи SVG, используй `AppIcons.<name>` |
| Виджет хранит данные в state (`final _tweets = [...]`) | данные — props in |
| `AnimationController` без `dispose` | добавь dispose |
| `setState` после `await` без `if (!mounted) return` | добавь проверку |
| `XxxBloc` или `XxxScope.of(context)` внутри виджета ui_kit | это виджет фичи, не ui_kit |
| `context.go(...)` / `Navigator.push(...)` внутри виджета | виджет эмитит callback (`onTap`), решает caller |
| 15+ named-параметров | разбей виджет на несколько вариантов или вынеси конфиг в отдельный класс |
| Прячет состояние в глобальном static | `StatefulWidget` + `ValueNotifier`, или подними состояние наверх |

---

## 12. Обновление и рефакторинг

Проект в активной разработке, релизов как стабильных тегов пока нет — изменения катятся в `main`.

### Не ломающее изменение

Добавил опциональный пропс с дефолтом → существующие места не сломаются → добавь use-case в storybook на новое поведение → готово.

### Ломающее изменение

1. Поправь виджет.
2. Прогон `flutter analyze` — анализатор покажет все места использования, где сломалась сигнатура.
3. Обнови их за один PR. Поскольку у нас монорепо и нет внешних потребителей `ui_kit`, deprecation cycle не нужен.

### Удаление виджета

```bash
grep -rln "AppOldButton" apps/ packages/
```

Если 0 использований — удаляй файл, тест, use-case в storybook, экспорт из `lib/ui_kit.dart`.

### Когда обновляется Figma

1. Сначала — токены (`AppColors`, `AppTypography`). Виджеты подхватят сами.
2. Если изменился сам виджет — правь его, прогоняй storybook, сравнивай с дизайном.
3. Если редизайн крупный — допустимо завести `AppButtonV2` и параллельно мигрировать места использования.
