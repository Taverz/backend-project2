import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final avatarUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(
    name: 'Initials',
    builder: (_) => const Center(child: Avatar(initials: 'NK')),
  ),
  WidgetbookUseCase(
    name: 'With image (placeholder url)',
    builder: (_) =>
        const Center(child: Avatar(url: 'https://i.pravatar.cc/200', size: 64)),
  ),
  WidgetbookUseCase(
    name: 'Sizes (28 / 40 / 64 / 96)',
    builder: (_) => const Center(
      child: Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Avatar(initials: 'A', size: 28),
          Avatar(initials: 'B', size: 40),
          Avatar(initials: 'C', size: 64),
          Avatar(initials: 'D', size: 96),
        ],
      ),
    ),
  ),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final initials = context.knobs.string(
        label: 'initials',
        initialValue: 'NK',
      );
      final size = context.knobs.double.slider(
        label: 'size',
        initialValue: 40,
        min: 16,
        max: 160,
      );
      final useImage = context.knobs.boolean(
        label: 'use image (pravatar)',
        initialValue: false,
      );
      return Center(
        child: Avatar(
          initials: initials,
          url: useImage ? 'https://i.pravatar.cc/200' : null,
          size: size,
        ),
      );
    },
  ),
];
