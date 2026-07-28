import 'package:flame/components.dart';
import 'difficulty_manager.dart';
import '../enemies/crawler_enemy.dart';
import '../enemies/airborne_enemy.dart';
import '../../spider_slinger_game.dart';
import 'dart:math';

class SpawnerManager extends Component with HasGameRef<SpiderSlingerGame> {
  final DifficultyManager difficultyManager;
  double _timer = 0;
  final Random _random = Random();

  SpawnerManager({required this.difficultyManager});

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameState.isGameOver) return;

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
    
    if (spawnAirborne) {
      double initialY = gameRef.size.y / 2 - 100 + _random.nextDouble() * 200;
      gameRef.add(AirborneEnemy(speed: speed, initialY: initialY)
        ..position = Vector2(gameRef.size.x + 50, initialY));
    } else {
      // Spawn on the ground (assuming floor at gameRef.size.y - 100)
      gameRef.add(CrawlerEnemy(speed: speed)
        ..position = Vector2(gameRef.size.x + 50, gameRef.size.y - 116)); // 100 floor + 16 half size
    }
  }
}
