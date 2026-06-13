import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Показывает SnackBar-подобный тост через `Overlay`, без Material.
/// Возвращает текущий entry, чтобы можно было его закрыть досрочно.
abstract final class AppSnackBar {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _current?.remove();

    final entry = OverlayEntry(
      builder: (ctx) {
        final padding = MediaQuery.of(ctx).viewPadding.bottom + 16;
        return Positioned(
          left: 16,
          right: 16,
          bottom: padding,
          child: _SnackContent(message: message, isError: isError),
        );
      },
    );
    _current = entry;
    overlay.insert(entry);
    Future.delayed(duration, () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? AppColors.error : AppColors.textPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: AppTypography.body2.copyWith(color: AppColors.background),
      ),
    );
  }
}
