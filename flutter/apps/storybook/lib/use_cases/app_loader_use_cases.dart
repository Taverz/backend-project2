import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appLoaderUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Default',
    builder: (_) => const Center(child: AppLoader()),
  ),
  WidgetbookUseCase(
    name: 'Large',
    builder: (_) =>
        const Center(child: AppLoader(size: 48, strokeWidth: 4)),
  ),
];
