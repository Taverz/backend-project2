import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Собственный header вместо Material `AppBar`. Использует только flutter/widgets.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key, required this.title, this.leading, this.actions});

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    decoration: const BoxDecoration(
      color: AppColors.background,
      border: Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Text(
            title,
            style: AppTypography.headline2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actions != null) ...actions!,
      ],
    ),
  );
}
