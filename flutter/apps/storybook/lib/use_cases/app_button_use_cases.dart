import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appButtonUseCases = <WidgetbookUseCase>[
  // ── Статичные варианты — быстрый обзор основных состояний ────────────────
  WidgetbookUseCase(
    name: 'Primary',
    builder: (_) => _Wrap(
      child: AppButton(label: 'Войти', onPressed: () {}),
    ),
  ),
  WidgetbookUseCase(
    name: 'Primary loading',
    builder: (_) => _Wrap(
      child: AppButton(label: 'Войти', isLoading: true, onPressed: () {}),
    ),
  ),
  WidgetbookUseCase(
    name: 'Primary disabled',
    builder: (_) =>
        const _Wrap(child: AppButton(label: 'Войти', onPressed: null)),
  ),
  WidgetbookUseCase(
    name: 'Secondary',
    builder: (_) => _Wrap(
      child: AppButton(
        label: 'Отмена',
        kind: AppButtonKind.secondary,
        onPressed: () {},
      ),
    ),
  ),
  WidgetbookUseCase(
    name: 'Text button',
    builder: (_) => _Wrap(
      child: AppTextButton(label: 'Нет аккаунта?', onPressed: () {}),
    ),
  ),

  // ── Interactive — все props через knobs ──────────────────────────────────
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final label = context.knobs.string(label: 'label', initialValue: 'Войти');
      final kind = context.knobs.object.dropdown<AppButtonKind>(
        label: 'kind',
        options: AppButtonKind.values,
        labelBuilder: (k) => k.name,
        initialOption: AppButtonKind.primary,
      );
      final isLoading = context.knobs.boolean(
        label: 'isLoading',
        initialValue: false,
      );
      final enabled = context.knobs.boolean(
        label: 'enabled',
        initialValue: true,
      );
      return _Wrap(
        child: AppButton(
          label: label,
          kind: kind,
          isLoading: isLoading,
          onPressed: enabled ? () {} : null,
        ),
      );
    },
  ),
];

class _Wrap extends StatelessWidget {
  const _Wrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(24), child: child);
}
