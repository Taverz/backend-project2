import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appIconUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Catalog',
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          AppIcon(AppIcons.eyeOpen),
          AppIcon(AppIcons.eyeClosed),
          AppIcon(AppIcons.errorOutline),
          AppIcon(AppIcons.inboxOutline),
        ],
      ),
    ),
  ),
  WidgetbookUseCase(
    name: 'Sizes',
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        children: [
          AppIcon(AppIcons.eyeOpen, size: 16),
          AppIcon(AppIcons.eyeOpen, size: 24),
          AppIcon(AppIcons.eyeOpen, size: 32),
          AppIcon(AppIcons.eyeOpen, size: 48),
        ],
      ),
    ),
  ),
];
