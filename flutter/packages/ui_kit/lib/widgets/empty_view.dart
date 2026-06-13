import 'package:flutter/widgets.dart';

import '../gen/assets.gen.dart';
import '../icons/app_icon_data.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon});

  final String message;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          icon ?? AppIcons.inboxOutline,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 12),
        Text(message),
      ],
    ),
  );
}
