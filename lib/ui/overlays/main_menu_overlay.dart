import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../../services/audio_service.dart';
import '../widgets/comic_button.dart';
import '../widgets/comic_background_painter.dart';

class MainMenuOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Painter (Yellow with halftones & lines)
          Positioned.fill(
            child: CustomPaint(
              painter: ComicBackgroundPainter(),
            ),
          ),

          // Right Panel Clip (Blue)
          Positioned.fill(
            child: ClipPath(
              clipper: _RightPanelClipper(),
              child: Container(
                color: const Color(0xFF0B3D91), // Deep Blue
              ),
            ),
          ),

          // Thick black divider line to act as a comic gutter
          Positioned.fill(
            child: CustomPaint(
              painter: _DividerPainter(),
            ),
          ),

          // Title (Left side)
          Positioned(
            left: 50,
            top: 40,
            child: Transform(
              transform: Matrix4.skewX(-0.15)..rotateZ(-0.05),
              child: Stack(
                children: [
                  // Text Outline/Shadow
                  Text(
                    'SPIDER-SLINGER:\nINSECT BLITZ',
                    style: GoogleFonts.bangers(
                      fontSize: 72,
                      height: 1.0,
                      letterSpacing: 4.0,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 10
                        ..color = Colors.black,
                    ),
                  ),
                  // Solid Text
                  Text(
                    'SPIDER-SLINGER:\nINSECT BLITZ',
                    style: GoogleFonts.bangers(
                      fontSize: 72,
                      height: 1.0,
                      letterSpacing: 4.0,
                      color: const Color(0xFFE23636), // Crimson Red
                      shadows: const [
                        Shadow(offset: Offset(-3, -3), color: Colors.white),
                        Shadow(offset: Offset(6, 6), color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buttons (Right side)
          Positioned(
            right: 60,
            bottom: 40,
            child: Transform(
              transform: Matrix4.skewX(-0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ComicButton(
                    label: 'TAP TO PLAY',
                    color: const Color(0xFFF5D300), // Yellow
                    textColor: Colors.black,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () async {
                      game.overlays.remove(GameRoutes.mainMenu);
                      
                      final prefs = await SharedPreferences.getInstance();
                      final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;

                      if (!tutorialCompleted) {
                        game.overlays.add(GameRoutes.hud); // Add HUD so it's visible in background
                        game.overlays.add(GameRoutes.tutorial);
                      } else {
                        game.overlays.add(GameRoutes.hud);
                        game.resumeEngine();
                      }
                      
                      AudioService.initialize();
                    },
                  ),
                  const SizedBox(height: 24),
                  ComicButton(
                    label: 'HOW TO PLAY',
                    color: const Color(0xFFE23636), // Red
                    icon: Icons.help_outline,
                    onPressed: () {
                      game.overlays.remove(GameRoutes.mainMenu);
                      game.overlays.add(GameRoutes.howToPlay);
                    },
                  ),
                  const SizedBox(height: 24),
                  ComicButton(
                    label: 'LEADERBOARD',
                    color: Colors.white,
                    textColor: Colors.black,
                    icon: Icons.leaderboard,
                    onPressed: () {
                      Navigator.pushNamed(context, '/leaderboard');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Clips a slanted polygon for the right side of the screen
    final path = Path();
    path.moveTo(size.width * 0.45, size.height);
    path.lineTo(size.width * 0.65, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(size.width * 0.45, size.height);
    path.lineTo(size.width * 0.65, 0);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
