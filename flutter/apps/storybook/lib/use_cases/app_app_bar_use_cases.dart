import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appAppBarUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Title only',
    builder: (_) => const AppAppBar(title: 'Вход'),
  ),
  WidgetbookUseCase(
    name: 'With actions',
    builder: (_) => AppAppBar(
      title: 'Профиль',
      actions: [
        GestureDetector(onTap: () {}, child: AppIcon(AppIcons.eyeOpen)),
      ],
    ),
  ),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final title = context.knobs.string(
        label: 'title',
        initialValue: 'Профиль',
      );
      final showLeading = context.knobs.boolean(
        label: 'leading (back)',
        initialValue: false,
      );
      final showAction = context.knobs.boolean(
        label: 'action (icon)',
        initialValue: true,
      );
      return AppAppBar(
        title: title,
        leading: showLeading
            ? GestureDetector(onTap: () {}, child: AppIcon(AppIcons.eyeClosed))
            : null,
        actions: showAction
            ? [GestureDetector(onTap: () {}, child: AppIcon(AppIcons.eyeOpen))]
            : null,
      );
    },
  ),
];
