import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../../game/state/game_state.dart';

class GameOverOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const GameOverOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red, width: 4),
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
                  'Final Score: ${gameState.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    gameState.resetGame();
                    // Just removing all components and reloading the engine might be needed,
                    // but for now, we'll reset state and go to main menu.
                    game.overlays.remove(GameRoutes.gameOver);
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
}
