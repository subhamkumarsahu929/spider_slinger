import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/game_routes.dart';
import '../../game/spider_slinger_game.dart';
import '../widgets/comic_button.dart';

class PauseMenuOverlay extends StatelessWidget {
  final SpiderSlingerGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7), // Dim the background slightly
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white, // Solid white card
            border: Border.all(color: Colors.black, width: 4), // Stark black border
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
                'PAUSED',
                style: GoogleFonts.bangers(
                  color: Colors.black,
                  fontSize: 48,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              ComicButton(
                label: 'RESUME',
                color: const Color(0xFF0B3D91),
                icon: Icons.play_arrow,
                onPressed: () {
                  game.overlays.remove(GameRoutes.pauseMenu);
                  game.overlays.add(GameRoutes.hud);
                  game.resumeEngine();
                },
              ),
              const SizedBox(height: 16),
              ComicButton(
                label: 'QUIT TO MENU',
                color: const Color(0xFFE23636),
                icon: Icons.exit_to_app,
                onPressed: () {
                  game.gameState.resetGame();
                  game.overlays.remove(GameRoutes.pauseMenu);
                  game.overlays.add(GameRoutes.mainMenu);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
