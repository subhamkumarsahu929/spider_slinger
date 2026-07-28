import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/state/game_state.dart';
import 'game/spider_slinger_game.dart';
import 'config/game_routes.dart';
import 'ui/overlays/main_menu_overlay.dart';
import 'ui/overlays/hud_overlay.dart';
import 'ui/overlays/pause_menu_overlay.dart';
import 'ui/overlays/game_over_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Firebase initialization is commented out as requested.
  // await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const SpiderSlingerApp(),
    ),
  );
}

class SpiderSlingerApp extends StatelessWidget {
  const SpiderSlingerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // Auth logic could go here to update gameState.setUser() once Firebase is ready.

    return MaterialApp(
      title: 'Spider-Slinger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Courier',
      ),
      home: Scaffold(
        body: GameWidget<SpiderSlingerGame>(
          game: SpiderSlingerGame(gameState: gameState),
          initialActiveOverlays: const [GameRoutes.mainMenu],
          overlayBuilderMap: {
            GameRoutes.mainMenu: (context, game) => MainMenuOverlay(game: game),
            GameRoutes.hud: (context, game) => HudOverlay(game: game),
            GameRoutes.pauseMenu: (context, game) => PauseMenuOverlay(game: game),
            GameRoutes.gameOver: (context, game) => GameOverOverlay(game: game),
          },
        ),
      ),
    );
  }
}
