import 'package:flutter/material.dart';
import 'dart:math';

class ComicBackgroundPainter extends CustomPainter {
  final Color bgColor;
  final Color dotColor;
  final Color lineColor;

  ComicBackgroundPainter({
    this.bgColor = const Color(0xFFF5D300), // Yellow
    this.dotColor = const Color(0x33000000), // Semi-transparent black
    this.lineColor = const Color(0x44000000), 
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw Halftone dots
    final dotPaint = Paint()..color = dotColor;
    const double dotSpacing = 16.0;
    const double maxRadius = 4.0;
    
    // Draw dots only in the top-left area to simulate a gradient/shadow effect
    for (double y = 0; y < size.height; y += dotSpacing) {
      for (double x = 0; x < size.width; x += dotSpacing) {
        // Dot size shrinks as it goes down and right
        final dist = (x + y) / (size.width + size.height);
        final r = maxRadius * (1.0 - dist);
        if (r > 0.5) {
          canvas.drawCircle(Offset(x, y), r, dotPaint);
        }
      }
    }

    // 3. Draw radiating action lines from the center-left
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.3, size.height * 0.5);
    final int numLines = 24;
    final double radius = size.width;

    for (int i = 0; i < numLines; i++) {
      final angle = (i * 2 * pi) / numLines;
      
      // Skip some angles for a jagged, comic burst effect
      if (i % 5 == 0) continue;

      final startOffset = Offset(
        center.dx + cos(angle) * 80, // Start away from center
        center.dy + sin(angle) * 80,
      );
      final endOffset = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );

      // Varying thickness
      linePaint.strokeWidth = (i % 3 == 0) ? 6.0 : 2.0;
      canvas.drawLine(startOffset, endOffset, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
