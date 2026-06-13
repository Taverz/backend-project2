import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

/// Меняет цвет фона canvas независимо от темы виджета.
/// Полезно проверить как виджет выглядит на разных фонах (контраст,
/// прозрачные части и т.п.).
class BackgroundAddon extends WidgetbookAddon<BackgroundOption> {
  BackgroundAddon() : super(name: 'Background');

  static const _options = <BackgroundOption>[
    BackgroundOption('White', AppColors.background),
    BackgroundOption('Surface', AppColors.surface),
    BackgroundOption('Dark surface', AppColors.surfaceDark),
    BackgroundOption('Background dark', AppColors.backgroundDark),
    BackgroundOption('Brand primary', AppColors.primary),
  ];

  @override
  List<Field> get fields => [
    ObjectDropdownField<BackgroundOption>(
      name: 'color',
      values: _options,
      initialValue: _options.first,
      labelBuilder: (o) => o.label,
    ),
  ];

  @override
  BackgroundOption valueFromQueryGroup(Map<String, String> group) {
    return valueOf<BackgroundOption>('color', group) ?? _options.first;
  }

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    BackgroundOption setting,
  ) {
    return ColoredBox(color: setting.color, child: child);
  }
}

class BackgroundOption {
  const BackgroundOption(this.label, this.color);

  final String label;
  final Color color;

  // ObjectDropdownField сравнивает значения через labelBuilder, но toString
  // используется как fallback id в URL query — даём стабильный slug.
  @override
  String toString() => label;
}
