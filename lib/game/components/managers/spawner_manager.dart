import 'package:flame/components.dart';
import 'difficulty_manager.dart';
import '../enemies/crawler_enemy.dart';
import '../enemies/airborne_enemy.dart';
import '../enemies/venom_boss.dart';
import '../../spider_slinger_game.dart';
import 'dart:math';

class SpawnerManager extends Component with HasGameReference<SpiderSlingerGame> {
  final DifficultyManager difficultyManager;
  double _timer = 0;
  final Random _random = Random();
  bool _venomSpawned = false;

  SpawnerManager({required this.difficultyManager});

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;

    if (difficultyManager.currentPhase == 3 && !_venomSpawned) {
      _venomSpawned = true;
      game.world.add(VenomBoss()
        ..position = Vector2(game.camera.viewfinder.position.x + game.size.x, game.size.y - 150));
        
      // Pause game and show Venom Intro Overlay
      game.pauseEngine();
      game.overlays.add('VenomIntro');
      
      return; // Give some time before spawning other enemies, or just let them spawn too.
    }

    _timer += dt;
    // #6 — No regular enemy spawning during the boss fight
    if (_venomSpawned) return;
    if (_timer >= difficultyManager.spawnRate) {
      _timer = 0;
      _spawnEnemy();
    }
  }

  void _spawnEnemy() {
    bool spawnAirborne = _random.nextBool();
    if (difficultyManager.currentPhase == 1) {
      // mostly crawlers in phase 1
      spawnAirborne = _random.nextDouble() > 0.8; 
    }

    double speed = difficultyManager.enemySpeedMultiplier * 150.0;
    
    // Spawn enemies relative to the camera's current position so they come from off-screen right
    double spawnX = game.camera.viewfinder.position.x + game.size.x;

    if (spawnAirborne) {
      double initialY = game.size.y / 2 - 100 + _random.nextDouble() * 200;
      game.world.add(AirborneEnemy(speed: speed, initialY: initialY)
        ..position = Vector2(spawnX, initialY));
    } else {
      // #1 — Spawn above the floor so gravity drops them onto whatever platform
      // is beneath spawnX — avoids floating in mid-air over procedural gaps.
      CrawlerType cType = _random.nextBool() ? CrawlerType.little : CrawlerType.tall;
      game.world.add(CrawlerEnemy(speed: speed, crawlerType: cType)
        ..position = Vector2(spawnX, game.size.y - 250));
    }
  }
}
