import 'package:flutter/widgets.dart';

import '../icons/app_icon_data.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'app_icon.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              AppIcons.errorOutline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: 'Повторить', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
