import 'package:flutter/material.dart';

class VirtualButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final Color color;

  const VirtualButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.onPointerDown,
    this.onPointerUp,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: onPointerDown != null ? (_) => onPointerDown!() : null,
      onTapUp: onPointerUp != null ? (_) => onPointerUp!() : null,
      onTapCancel: onPointerUp,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
