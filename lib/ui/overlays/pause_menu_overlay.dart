import 'package:flutter/material.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';

class PauseMenuOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const PauseMenuOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove(GameRoutes.pauseMenu);
                game.overlays.add(GameRoutes.hud);
                game.resumeEngine();
              },
              child: const Text('Resume', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.gameState.resetGame();
                game.overlays.remove(GameRoutes.pauseMenu);
                game.overlays.add(GameRoutes.mainMenu);
              },
              child: const Text('Quit', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
