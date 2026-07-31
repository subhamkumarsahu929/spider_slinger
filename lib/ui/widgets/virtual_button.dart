import 'package:flutter/material.dart';

class VirtualButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final Color color;

  const VirtualButton({
    super.key,
    required this.icon,
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
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
