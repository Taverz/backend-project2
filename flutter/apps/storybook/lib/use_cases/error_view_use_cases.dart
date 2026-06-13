import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final errorViewUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Default',
    builder: (_) => ErrorView(message: 'Что-то пошло не так', onRetry: () {}),
  ),
  WidgetbookUseCase(
    name: 'No retry',
    builder: (_) => const ErrorView(message: 'Нет соединения'),
  ),
];
