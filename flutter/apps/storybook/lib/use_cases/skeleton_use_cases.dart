import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final skeletonUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Default',
    builder: (_) => const Center(child: Skeleton(width: 200, height: 20)),
  ),
  WidgetbookUseCase(
    name: 'List item mock',
    builder: (_) => const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 120, height: 16),
          SizedBox(height: 8),
          Skeleton(width: 240, height: 14),
          SizedBox(height: 4),
          Skeleton(width: 180, height: 14),
        ],
      ),
    ),
  ),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final width = context.knobs.double.slider(
        label: 'width',
        initialValue: 200,
        min: 24,
        max: 360,
      );
      final height = context.knobs.double.slider(
        label: 'height',
        initialValue: 20,
        min: 4,
        max: 120,
      );
      final radius = context.knobs.double.slider(
        label: 'borderRadius',
        initialValue: 8,
        min: 0,
        max: 60,
      );
      return Center(
        child: Skeleton(width: width, height: height, borderRadius: radius),
      );
    },
  ),
];
