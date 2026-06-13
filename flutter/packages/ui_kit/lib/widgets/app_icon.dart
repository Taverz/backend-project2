import 'package:flutter/widgets.dart';

import '../gen/assets.gen.dart';

/// Иконка, отрисованная из SVG-ассета через flutter_svg.
/// Окрашивается через `colorFilter` (SVG должна быть с `stroke="currentColor"`
/// или `fill="currentColor"`).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color});

  final SvgGenImage icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? DefaultTextStyle.of(context).style.color;
    return icon.svg(
      width: size,
      height: size,
      colorFilter: resolved != null
          ? ColorFilter.mode(resolved, BlendMode.srcIn)
          : null,
    );
  }
}
