import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../game/spider_slinger_game.dart';
import '../../game/state/game_state.dart';
import '../../config/game_routes.dart';
import '../../config/game_constants.dart';
import '../widgets/heart_counter.dart';
import '../widgets/virtual_button.dart';
import '../widgets/comic_burst_painter.dart';

class HudOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.isGameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            game.overlays.remove(GameRoutes.hud);
            game.overlays.add(GameRoutes.gameOver);
            game.pauseEngine();
          });
        }
        
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.height < 400;
        final isLargeScreen = screenSize.height > 700;

        final double burstWidth = isSmallScreen ? 90 : (isLargeScreen ? 170 : 120);
        final double burstHeight = isSmallScreen ? 50 : (isLargeScreen ? 95 : 70);
        final double fontSize = isSmallScreen ? 18 : (isLargeScreen ? 34 : 24);
        final double shadowOffset1 = isSmallScreen ? 1.0 : (isLargeScreen ? 2.0 : 1.5);
        final double shadowOffset2 = isSmallScreen ? 2.0 : (isLargeScreen ? 4.0 : 3.0);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [
                // Top Left: Hearts
                Positioned(
                  top: 0,
                  left: 0,
                  child: HeartCounter(lives: gameState.lives, maxLives: GameConstants.maxLives),
                ),

                // Top Center: Score Burst
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: burstWidth,
                    height: burstHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(burstWidth, burstHeight),
                          painter: ComicBurstPainter(),
                        ),
                        Transform(
                          transform: Matrix4.skewX(-0.1)..rotateZ(-0.05),
                          child: Text(
                            _formatScore(gameState.score),
                            style: GoogleFonts.bangers(
                              color: Colors.white,
                              fontSize: fontSize,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(offset: Offset(shadowOffset1, shadowOffset1), color: Colors.black),
                                Shadow(offset: Offset(-shadowOffset1, -shadowOffset1), color: Colors.black),
                                Shadow(offset: Offset(shadowOffset2, shadowOffset2), color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right: Pause & Shield
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      if (gameState.isInvulnerable) ...[
                        Transform(
                          transform: Matrix4.skewX(-0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26E0FF), // Cyan
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 0,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Transform(
                              transform: Matrix4.skewX(0.1),
                              child: Text(
                                'SHIELD: ${gameState.invulnerabilityTime.toStringAsFixed(1)}s',
                                style: GoogleFonts.bangers(
                                  color: Colors.black,
                                  fontSize: 20,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      GestureDetector(
                        onTap: () {
                          game.pauseEngine();
                          game.overlays.remove(GameRoutes.hud);
                          game.overlays.add(GameRoutes.pauseMenu);
                        },
                        child: Transform(
                          transform: Matrix4.skewX(-0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B3B), // Crimson
                              border: Border.all(color: Colors.black, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 0,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Transform(
                              transform: Matrix4.skewX(0.1),
                              child: Text(
                                'PAUSE',
                                style: GoogleFonts.bangers(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 2.0,
                                  shadows: const [
                                    Shadow(offset: Offset(2, 2), color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Left Controls
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VirtualButton(
                        icon: Icons.arrow_back_rounded,
                        label: 'LEFT',
                        color: const Color(0xFF0B3D91), // Deep Blue
                        onPointerDown: game.startMovingLeft,
                        onPointerUp: game.stopMoving,
                      ),
                      const SizedBox(width: 24),
                      VirtualButton(
                        icon: Icons.arrow_forward_rounded,
                        label: 'RIGHT',
                        color: const Color(0xFF0B3D91), // Deep Blue
                        onPointerDown: game.startMovingRight,
                        onPointerUp: game.stopMoving,
                      ),
                    ],
                  ),
                ),

                // Bottom Right Controls
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VirtualButton(
                        icon: Icons.arrow_upward_rounded,
                        label: 'JUMP',
                        color: const Color(0xFFFFD23F), // Gold
                        onPointerDown: game.jump,
                        onPointerUp: game.onJumpReleased,
                      ),
                      const SizedBox(width: 24),
                      VirtualButton(
                        icon: Icons.gps_fixed_rounded,
                        label: 'SHOOT',
                        color: const Color(0xFFFF3B3B), // Crimson
                        onPressed: game.shootHorizontalWeb,
                      ),
                      const SizedBox(width: 24),
                      VirtualButton(
                        icon: Icons.waves_rounded,
                        label: 'SWING',
                        color: const Color(0xFF3A1C8C), // Indigo
                        onPointerDown: game.shootVerticalWeb,
                        onPointerUp: game.triggerSwing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formats an integer with thousands separators: 12500 → 12,500
  static String _formatScore(int score) {
    final s = score.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
