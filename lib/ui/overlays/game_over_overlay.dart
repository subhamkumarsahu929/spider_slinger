import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../../game/state/game_state.dart';
import '../widgets/comic_button.dart';

class GameOverOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white, // Solid white card
                // #11 — Green border on win, red on loss
                border: Border.all(
                  color: gameState.lives > 0 ? Colors.green : const Color(0xFFE23636),
                  width: 6,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: Offset(8, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameState.lives > 0 ? 'YOU WIN!' : 'GAME OVER',
                    style: GoogleFonts.bangers(
                      color: gameState.lives > 0 ? Colors.green : const Color(0xFFE23636),
                      fontSize: 64,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5D300), // Solid Action Yellow
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Text(
                      // #10 — Thousands separator
                      'FINAL SCORE: ${_formatScore(gameState.score)}',
                      style: GoogleFonts.bangers(
                        color: Colors.black,
                        fontSize: 32,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ComicButton(
                    label: 'RETURN TO MENU',
                    color: const Color(0xFF0B3D91), // Deep Blue
                    icon: Icons.replay,
                    onPressed: () {
                      gameState.resetGame();
                      game.overlays.remove(GameRoutes.gameOver);
                      // #4 — Tear down the old world so the next game starts fresh
                      game.resetWorld();
                      game.overlays.add(GameRoutes.mainMenu);
                    },
                  ),
                ],
              ),
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
