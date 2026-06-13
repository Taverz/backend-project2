import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final emptyViewUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Default',
    builder: (_) => const EmptyView(message: 'Пока ничего нет'),
  ),
];
