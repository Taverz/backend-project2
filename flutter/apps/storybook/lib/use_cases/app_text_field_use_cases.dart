import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appTextFieldUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Default',
    builder: (_) => const Padding(
      padding: EdgeInsets.all(24),
      child: AppTextField(label: 'Email'),
    ),
  ),
  WidgetbookUseCase(
    name: 'With error',
    builder: (_) => const Padding(
      padding: EdgeInsets.all(24),
      child: AppTextField(label: 'Email', errorText: 'Неверный формат email'),
    ),
  ),
  WidgetbookUseCase(
    name: 'Disabled',
    builder: (_) => const Padding(
      padding: EdgeInsets.all(24),
      child: AppTextField(label: 'Email', enabled: false),
    ),
  ),
  WidgetbookUseCase(
    name: 'Password with suffix',
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: AppTextField(
        label: 'Пароль',
        obscureText: true,
        suffix: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AppIcon(AppIcons.eyeOpen),
        ),
      ),
    ),
  ),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final label = context.knobs.stringOrNull(
        label: 'label',
        initialValue: 'Email',
      );
      final errorText = context.knobs.stringOrNull(
        label: 'errorText',
        defaultToNull: true,
      );
      final obscureText = context.knobs.boolean(
        label: 'obscureText',
        initialValue: false,
      );
      final enabled = context.knobs.boolean(
        label: 'enabled',
        initialValue: true,
      );
      return Padding(
        padding: const EdgeInsets.all(24),
        child: AppTextField(
          label: label,
          errorText: errorText,
          obscureText: obscureText,
          enabled: enabled,
        ),
      );
    },
  ),
];
