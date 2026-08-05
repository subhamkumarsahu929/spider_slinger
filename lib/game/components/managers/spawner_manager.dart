import 'package:flame/components.dart';
import 'difficulty_manager.dart';
import '../enemies/airborne_enemy.dart';
import '../enemies/venom_boss.dart';
import '../enemies/rhino_boss.dart';
import '../enemies/electro_boss.dart';
import '../enemies/vulture_boss.dart';
import '../../spider_slinger_game.dart';
import 'dart:math';

class SpawnerManager extends Component with HasGameReference<SpiderSlingerGame> {
  final DifficultyManager difficultyManager;
  double _timer = 0;
  final Random _random = Random();
  bool _venomSpawned = false;
  int _lastLoopCount = 0;

  SpawnerManager({required this.difficultyManager});

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;

    if (game.gameState.loopCount > _lastLoopCount) {
      _lastLoopCount = game.gameState.loopCount;
      _venomSpawned = false;
      difficultyManager.resetPhase();
    }

    if (difficultyManager.currentPhase == 3 && !_venomSpawned) {
      _venomSpawned = true;
      int bossType = _random.nextInt(4);
      PositionComponent boss;
      if (bossType == 0) {
        boss = VenomBoss();
        game.gameState.setBossInfo('VENOM', 'WE ARE VENOM');
      } else if (bossType == 1) {
        boss = RhinoBoss();
        game.gameState.setBossInfo('RHINO', 'You fight me now!');
      } else if (bossType == 2) {
        boss = ElectroBoss();
        game.gameState.setBossInfo('ELECTRO', 'You are gonna FRY tonight!');
      } else {
        boss = VultureBoss();
        game.gameState.setBossInfo('VULTURE', 'Good ol\' spiderman.');
      }

      game.world.add(boss
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

    double initialY = game.size.y / 2 - 100 + _random.nextDouble() * 200;
    game.world.add(AirborneEnemy(speed: speed, initialY: initialY)
      ..position = Vector2(spawnX, initialY));
  }
}
