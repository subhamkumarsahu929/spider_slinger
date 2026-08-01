import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/spider_slinger_game.dart';
import '../../game/state/game_state.dart';
import '../../config/game_routes.dart';
import '../../config/game_constants.dart';
import '../widgets/heart_counter.dart';
import '../widgets/virtual_button.dart';

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
        
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    HeartCounter(lives: gameState.lives, maxLives: GameConstants.maxLives),
                    const Spacer(),
                    if (gameState.isInvulnerable) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade700.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'SHIELD: ${gameState.invulnerabilityTime.toStringAsFixed(1)}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Text(
                      // #10 — Thousands separator (12500 → 12,500)
                      'Score: ${_formatScore(gameState.score)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white, size: 32),
                      onPressed: () {
                        game.pauseEngine();
                        game.overlays.remove(GameRoutes.hud);
                        game.overlays.add(GameRoutes.pauseMenu);
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        VirtualButton(
                          icon: Icons.arrow_back_rounded,
                          label: 'LEFT',
                          color: Colors.orange,
                          onPointerDown: game.startMovingLeft,
                          onPointerUp: game.stopMoving,
                        ),
                        const SizedBox(width: 16),
                        VirtualButton(
                          icon: Icons.arrow_forward_rounded,
                          label: 'RIGHT',
                          color: Colors.orange,
                          onPointerDown: game.startMovingRight,
                          onPointerUp: game.stopMoving,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        VirtualButton(
                          icon: Icons.arrow_upward_rounded,
                          label: 'JUMP',
                          color: Colors.green,
                          onPointerDown: game.jump,
                          onPointerUp: game.onJumpReleased,
                        ),
                        const SizedBox(width: 24),
                        VirtualButton(
                          icon: Icons.gps_fixed_rounded,
                          label: 'SHOOT',
                          color: Colors.red,
                          onPressed: game.shootHorizontalWeb,
                        ),
                        const SizedBox(width: 16),
                        VirtualButton(
                          icon: Icons.waves_rounded,
                          label: 'SWING',
                          color: Colors.purple,
                          onPointerDown: game.shootVerticalWeb,
                          onPointerUp: game.triggerSwing,
                        ),
                      ],
                    ),
                  ],
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
