import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../../game/state/game_state.dart';

class GameOverOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              // #11 — Green border on win, red on loss
              border: Border.all(
                color: gameState.lives > 0 ? Colors.green : Colors.red,
                width: 4,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameState.lives > 0 ? 'YOU WIN!' : 'GAME OVER',
                  style: TextStyle(
                    color: gameState.lives > 0 ? Colors.green : Colors.red,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  // #10 — Thousands separator
                  'Final Score: ${_formatScore(gameState.score)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    gameState.resetGame();
                    game.overlays.remove(GameRoutes.gameOver);
                    // #4 — Tear down the old world so the next game starts fresh
                    game.resetWorld();
                    game.overlays.add(GameRoutes.mainMenu);
                  },
                  child: const Text('Return to Menu', style: TextStyle(fontSize: 24)),
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
