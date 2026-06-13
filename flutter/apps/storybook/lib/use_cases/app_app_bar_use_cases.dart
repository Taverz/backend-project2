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
        GestureDetector(
          onTap: () {},
          child: AppIcon(AppIcons.eyeOpen),
        ),
      ],
    ),
  ),
];
