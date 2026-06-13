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
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final icons = <(String, SvgGenImage)>[
        ('eyeOpen', AppIcons.eyeOpen),
        ('eyeClosed', AppIcons.eyeClosed),
        ('errorOutline', AppIcons.errorOutline),
        ('inboxOutline', AppIcons.inboxOutline),
      ];
      final pick = context.knobs.object.dropdown(
        label: 'icon',
        options: icons,
        labelBuilder: (e) => e.$1,
        initialOption: icons.first,
      );
      final size = context.knobs.double.slider(
        label: 'size',
        initialValue: 24,
        min: 12,
        max: 96,
      );
      final color = context.knobs.color(
        label: 'color',
        initialValue: AppColors.textPrimary,
      );
      return Center(
        child: AppIcon(pick.$2, size: size, color: color),
      );
    },
  ),
];
