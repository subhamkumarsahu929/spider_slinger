import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../../services/audio_service.dart';

class MainMenuOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Spider-Slinger:\nInsect Blitz',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                game.overlays.remove(GameRoutes.mainMenu);
                
                final prefs = await SharedPreferences.getInstance();
                final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;

                if (!tutorialCompleted) {
                  game.overlays.add(GameRoutes.tutorial);
                } else {
                  game.overlays.add(GameRoutes.hud);
                  game.resumeEngine();
                }
                
                AudioService.initialize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('TAP TO PLAY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    game.overlays.remove(GameRoutes.mainMenu);
                    game.overlays.add(GameRoutes.tutorial);
                  },
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  label: const Text('HOW TO PLAY', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/leaderboard');
                  },
                  icon: const Icon(Icons.leaderboard, color: Colors.white),
                  label: const Text('LEADERBOARD', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
