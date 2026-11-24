import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Boş durum (web `.empty-state`): kesik çizgili kart; ne olduğunu söyler,
/// varsa sonraki adımı ([action]) verir. Henüz yapılmamış ekranlarda da kullanılır.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          painter: _DashedBorder(color: p.lineStrong, fill: p.surface),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: p.muted),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(color: p.muted),
                  textAlign: TextAlign.center,
                ),
                if (action != null) ...[const SizedBox(height: 16), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color, required this.fill});

  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(rrect.deflate(0.5));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 8) {
        canvas.drawPath(metric.extractPath(d, d + 4), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) =>
      old.color != color || old.fill != fill;
}
