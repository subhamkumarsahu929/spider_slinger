import 'package:flame/components.dart';
import 'difficulty_manager.dart';
import '../enemies/crawler_enemy.dart';
import '../enemies/airborne_enemy.dart';
import '../enemies/venom_boss.dart';
import '../../spider_slinger_game.dart';
import 'dart:math';

class SpawnerManager extends Component with HasGameRef<SpiderSlingerGame> {
  final DifficultyManager difficultyManager;
  double _timer = 0;
  final Random _random = Random();
  bool _venomSpawned = false;

  SpawnerManager({required this.difficultyManager});

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameState.isGameOver) return;

    if (difficultyManager.currentPhase == 3 && !_venomSpawned) {
      _venomSpawned = true;
      gameRef.world.add(VenomBoss()
        ..position = Vector2(gameRef.camera.viewfinder.position.x + gameRef.size.x, gameRef.size.y - 150));
      return; // Give some time before spawning other enemies, or just let them spawn too.
    }

    _timer += dt;
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
    double spawnX = gameRef.camera.viewfinder.position.x + gameRef.size.x;

    if (spawnAirborne) {
      double initialY = gameRef.size.y / 2 - 100 + _random.nextDouble() * 200;
      gameRef.world.add(AirborneEnemy(speed: speed, initialY: initialY)
        ..position = Vector2(spawnX, initialY));
    } else {
      // Spawn on the ground (assuming floor at gameRef.size.y - 100)
      CrawlerType cType = _random.nextBool() ? CrawlerType.little : CrawlerType.tall;
      gameRef.world.add(CrawlerEnemy(speed: speed, crawlerType: cType)
        ..position = Vector2(spawnX, gameRef.size.y - 116)); // 100 floor + 16 half size
    }
  }
}
