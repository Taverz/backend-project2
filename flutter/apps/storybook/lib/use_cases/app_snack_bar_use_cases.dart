import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

final appSnackBarUseCases = <WidgetbookUseCase>[
  WidgetbookUseCase(name: 'Trigger', builder: (_) => const _SnackTrigger()),
  WidgetbookUseCase(
    name: '🎛️ Interactive (knobs)',
    builder: (context) {
      final message = context.knobs.string(
        label: 'message',
        initialValue: 'Сохранено',
      );
      final isError = context.knobs.boolean(
        label: 'isError',
        initialValue: false,
      );
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: AppButton(
            label: 'Показать snack',
            onPressed: () =>
                AppSnackBar.show(context, message: message, isError: isError),
          ),
        ),
      );
    },
  ),
];

class _SnackTrigger extends StatelessWidget {
  const _SnackTrigger();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: 'Показать info-snack',
          onPressed: () => AppSnackBar.show(context, message: 'Сохранено'),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Показать error-snack',
          kind: AppButtonKind.secondary,
          onPressed: () => AppSnackBar.show(
            context,
            message: 'Что-то пошло не так',
            isError: true,
          ),
        ),
      ],
    ),
  );
}
