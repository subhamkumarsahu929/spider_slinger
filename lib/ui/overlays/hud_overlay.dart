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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeartCounter(lives: gameState.lives, maxLives: GameConstants.maxLives),
                    Text(
                      'Score: ${gameState.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
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
                      children: [
                        VirtualButton(
                          icon: Icons.arrow_back,
                          color: Colors.orange,
                          onPointerDown: game.startMovingLeft,
                          onPointerUp: game.stopMoving,
                        ),
                        const SizedBox(width: 16),
                        VirtualButton(
                          icon: Icons.arrow_forward,
                          color: Colors.orange,
                          onPointerDown: game.startMovingRight,
                          onPointerUp: game.stopMoving,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        VirtualButton(
                          icon: Icons.arrow_upward,
                          color: Colors.green,
                          onPressed: game.jump,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VirtualButton(
                              icon: Icons.upload,
                              color: Colors.blue,
                              onPressed: game.shootVerticalWeb,
                            ),
                            const SizedBox(height: 16),
                            VirtualButton(
                              icon: Icons.arrow_forward,
                              color: Colors.red,
                              onPressed: game.shootHorizontalWeb,
                            ),
                          ],
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
}
