import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_loader.dart';

enum AppButtonKind { primary, secondary }

/// Кнопка без зависимости от Material. Ripple намеренно не делаем.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final bool isLoading;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = kind == AppButtonKind.primary;
    final bg = isPrimary
        ? (_enabled ? AppColors.primary : AppColors.border)
        : const Color(0x00000000);
    final fg = isPrimary
        ? AppColors.background
        : (_enabled ? AppColors.primary : AppColors.textSecondary);
    final border = isPrimary
        ? null
        : Border.all(color: AppColors.border, width: 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _enabled ? onPressed : null,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? AppLoader(size: 20, color: fg, strokeWidth: 2)
            : Text(
                label,
                style: AppTypography.button.copyWith(color: fg),
              ),
      ),
    );
  }
}

/// Текстовая кнопка-ссылка (без фона, без рамки).
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body2.copyWith(
            color: enabled
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
