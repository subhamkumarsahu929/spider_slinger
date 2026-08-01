import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualButton extends StatefulWidget {
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
  State<VirtualButton> createState() => _VirtualButtonState();
}

class _VirtualButtonState extends State<VirtualButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (widget.onPointerDown != null) widget.onPointerDown!();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (widget.onPointerUp != null) widget.onPointerUp!();
    if (widget.onPressed != null) widget.onPressed!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    if (widget.onPointerUp != null) widget.onPointerUp!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Transform.translate(
        offset: _isPressed ? const Offset(4, 4) : Offset.zero,
        child: Transform(
          transform: Matrix4.skewX(-0.15), // Comic skew
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.color, // Solid color
              border: Border.all(color: Colors.black, width: 4), // Heavy black border
              boxShadow: _isPressed
                  ? [] // Hide shadow when pressed
                  : [
                      const BoxShadow(
                        color: Colors.black, // Solid black shadow, no blur
                        blurRadius: 0,
                        offset: Offset(6, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform(
                  transform: Matrix4.skewX(0.15), // Counter-skew the icon
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                if (widget.label != null) ...[
                  const SizedBox(width: 8),
                  Transform(
                    transform: Matrix4.skewX(0.15), // Counter-skew the text
                    child: Text(
                      widget.label!,
                      style: GoogleFonts.bangers(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(offset: Offset(2, 2), color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
