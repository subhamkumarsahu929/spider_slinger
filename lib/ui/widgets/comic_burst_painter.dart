import 'package:flutter/material.dart';
import 'dart:math';

class ComicBurstPainter extends CustomPainter {
  final Color burstColor;
  final Color borderColor;

  ComicBurstPainter({
    this.burstColor = const Color(0xFFFFD23F), // Gold
    this.borderColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = burstColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4.0
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final innerRadius = size.height * 0.45;
    final outerRadius = size.height * 0.65;
    final int points = 14;

    final path = Path();

    // Create a jagged star/burst shape
    for (int i = 0; i < points * 2; i++) {
      final double radius = (i.isEven) ? outerRadius : innerRadius;
      final double angle = (i * pi) / points;
      
      // Add a little randomness for organic comic feel
      final double randOffset = (i.isEven) ? (sin(i * 123.45) * 4) : 0;
      
      final x = center.dx + cos(angle) * (radius + randOffset);
      final y = center.dy + sin(angle) * (radius + randOffset);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw hard drop shadow
    canvas.save();
    canvas.translate(4, 4);
    canvas.drawPath(path, Paint()..color = Colors.black);
    canvas.restore();

    // Draw fill
    canvas.drawPath(path, paint);
    
    // Draw thick border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
