import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Кастомный спиннер на CustomPaint — без Material.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.size = 24, this.color, this.strokeWidth = 2});

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _SpinnerPainter(
            progress: _controller.value,
            color: widget.color ?? AppColors.primary,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - strokeWidth,
    );
    final start = progress * 2 * math.pi;
    canvas.drawArc(rect, start, math.pi * 1.2, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.progress != progress;
}
