import 'dart:math';
import 'package:flame/components.dart';
import '../../spider_slinger_game.dart';
import '../environment/platform_block.dart';
import '../environment/hazard_block.dart';
import '../enemies/crawler_enemy.dart';
import 'spawner_manager.dart';

class ProceduralSpawner extends Component with HasGameReference<SpiderSlingerGame> {
  double _lastSpawnX = 0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    // Generate initial flat ground for the player to start on safely
    for (double x = 0; x <= 800; x += 32) {
      game.world.add(PlatformBlock(
        position: Vector2(x, game.size.y - 100),
        theme: TileTheme.blue,
        platformType: PlatformType.groundBlock,
      ));
    }
    _lastSpawnX = 832;
  }

  @override
  void update(double dt) {
    super.update(dt);
    double screenRightEdge = game.camera.viewfinder.position.x + game.size.x;
    
    // Procedurally spawn ahead of the camera
    while (_lastSpawnX < screenRightEdge + 400) {
      _spawnNextSegment();
    }
  }

  void _spawnNextSegment() {
    int numBlocks = 3 + _random.nextInt(8);
    double floorY = game.size.y - 100; // Solid continuous floor height
    TileTheme theme = _random.nextBool() ? TileTheme.blue : TileTheme.purple;
    
    double startX = _lastSpawnX;
    
    // 1. ALWAYS build a continuous solid floor segment
    for (int i = 0; i < numBlocks; i++) {
      game.world.add(PlatformBlock(position: Vector2(_lastSpawnX, floorY), theme: theme, platformType: PlatformType.groundBlock));
      // Small chance for ground hazard (avoiding edges to be fair)
      if (i > 0 && i < numBlocks - 1 && _random.nextDouble() < 0.15) {
        _spawnHazardOptionally(Vector2(_lastSpawnX + 8, floorY - 16), theme);
      }
      _lastSpawnX += 32;
    }
    
    // Feature 2: Spawn crawler enemy on the ground occasionally
    if (_random.nextDouble() < 0.4) {
      double speedMult = 1.0;
      final sm = game.world.children.whereType<SpawnerManager>().firstOrNull;
      if (sm != null) {
        speedMult = sm.difficultyManager.enemySpeedMultiplier;
      }
      
      CrawlerType cType = _random.nextBool() ? CrawlerType.little : CrawlerType.tall;
      game.world.add(CrawlerEnemy(
        speed: 150.0 * speedMult, 
        crawlerType: cType,
        patrolMinX: startX,
        patrolMaxX: _lastSpawnX,
      )..position = Vector2(startX + 16, floorY - 48));
    }
    
    // 2. 40% chance to spawn a floating platform hovering over this ground segment
    if (_random.nextDouble() < 0.4) {
      // Pushed floating platforms higher up (130 to 230 pixels above ground)
      double floatingY = floorY - (130 + _random.nextDouble() * 100);
      double currentX = startX;
      
      // Spawn left edge
      game.world.add(PlatformBlock(position: Vector2(currentX, floatingY), theme: theme, platformType: PlatformType.thinLedgeLeft));
      currentX += 16;
      
      // Spawn mid blocks
      int midBlocks = numBlocks - 1;
      for (int i = 0; i < midBlocks; i++) {
        game.world.add(PlatformBlock(position: Vector2(currentX, floatingY), theme: theme, platformType: PlatformType.thinLedgeMid));
        if (i > 0 && i < midBlocks - 1 && _random.nextDouble() < 0.2) {
          _spawnHazardOptionally(Vector2(currentX + 8, floatingY - 16), theme);
        }
        currentX += 32;
      }
      
      // Spawn right edge
      game.world.add(PlatformBlock(position: Vector2(currentX, floatingY), theme: theme, platformType: PlatformType.thinLedgeRight));
      
      // Feature 3: Spawn down-facing spikes occasionally on the bottom of floating platforms
      if (_random.nextDouble() < 0.25) {
        int randomMidBlock = 1 + _random.nextInt(midBlocks > 0 ? midBlocks : 1);
        game.world.add(HazardBlock(
          position: Vector2(startX + (randomMidBlock * 32) + 8, floatingY + 16),
          theme: theme,
          direction: SpikeDirection.down,
        ));
      }

      // Feature 3: Spawn left-facing spike on the left edge sometimes
      if (_random.nextDouble() < 0.1) {
        game.world.add(HazardBlock(
          position: Vector2(startX - 16, floatingY),
          theme: theme,
          direction: SpikeDirection.left,
        ));
      }

      // Feature 3: Spawn right-facing spike on the right edge sometimes
      if (_random.nextDouble() < 0.1) {
        game.world.add(HazardBlock(
          position: Vector2(currentX + 16, floatingY),
          theme: theme,
          direction: SpikeDirection.right,
        ));
      }
      
      // Feature 2: Spawn platform-bound crawler enemy occasionally
      if (_random.nextDouble() < 0.4) { // Increased from 0.3
        // Query speed multiplier from SpawnerManager if possible
        double speedMult = 1.0;
        final sm = game.world.children.whereType<SpawnerManager>().firstOrNull;
        if (sm != null) {
          speedMult = sm.difficultyManager.enemySpeedMultiplier;
        }
        
        CrawlerType cType = _random.nextBool() ? CrawlerType.little : CrawlerType.tall;
        game.world.add(CrawlerEnemy(
          speed: 150.0 * speedMult, 
          crawlerType: cType,
          patrolMinX: startX,
          patrolMaxX: currentX + 16,
        )..position = Vector2(startX + 16, floatingY - 48)); // Spawn on left edge
      }
    }
    
    // Feature 4: Introduce gaps between segments occasionally (pits)
    if (_random.nextDouble() < 0.5) {
      int gapBlocks = 3 + _random.nextInt(3); // 3 to 5 block gap
      _lastSpawnX += gapBlocks * 32.0;
    }
  }
  
  void _spawnHazardOptionally(Vector2 position, TileTheme theme) {
    // 20% chance to spawn an upward spike on the platform
    if (_random.nextDouble() < 0.2) {
      game.world.add(HazardBlock(
        position: position,
        theme: theme,
        direction: SpikeDirection.up,
      ));
    }
  }
}
