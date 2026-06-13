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
    builder: (_) => const Center(child: AppLoader(size: 48, strokeWidth: 4)),
  ),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final size = context.knobs.double.slider(
        label: 'size',
        initialValue: 24,
        min: 12,
        max: 96,
      );
      final strokeWidth = context.knobs.double.slider(
        label: 'strokeWidth',
        initialValue: 2,
        min: 1,
        max: 8,
      );
      final color = context.knobs.color(
        label: 'color',
        initialValue: AppColors.primary,
      );
      return Center(
        child: AppLoader(size: size, strokeWidth: strokeWidth, color: color),
      );
    },
  ),
];
