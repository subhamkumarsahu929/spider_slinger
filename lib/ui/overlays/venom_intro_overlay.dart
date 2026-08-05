import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/spider_slinger_game.dart';
import '../../config/game_routes.dart';

class VenomIntroOverlay extends StatefulWidget {
  final SpiderSlingerGame game;

  const VenomIntroOverlay({super.key, required this.game});

  @override
  State<VenomIntroOverlay> createState() => _VenomIntroOverlayState();
}

class _VenomIntroOverlayState extends State<VenomIntroOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      widget.game.overlays.remove(GameRoutes.venomIntro);
      widget.game.resumeEngine();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        color: const Color(0xAA08070C), // Semi-transparent Ink
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform(
                    transform: Matrix4.skewX(-0.15)..rotateZ(-0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08070C), // Ink background
                        border: Border.all(color: const Color(0xFFFF3B3B), width: 8), // Crimson border
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFF3B3B),
                            blurRadius: 0,
                            offset: Offset(8, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.game.gameState.currentBossTaunt,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bangers(
                          color: Colors.white,
                          fontSize: 60,
                          letterSpacing: 4.0,
                          shadows: const [
                            Shadow(offset: Offset(4, 4), color: Color(0xFFFF2F92)), // Magenta shadow
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
