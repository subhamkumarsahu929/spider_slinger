import 'dart:math';
import 'package:flame/components.dart';
import '../../spider_slinger_game.dart';
import '../environment/platform_block.dart';
import '../environment/hazard_block.dart';

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
    // 1. Decide if we want a gap
    bool isGap = _random.nextDouble() < 0.2;
    
    if (isGap) {
      // Create a jumpable gap (60 to 120 pixels)
      _lastSpawnX += 60 + _random.nextDouble() * 60;
    } else {
      // 2. Spawn a platform segment
      int numBlocks = 3 + _random.nextInt(10);
      bool isFloating = _random.nextDouble() < 0.4;
      double yPos = game.size.y - 100; // Floor height
      
      if (isFloating) {
        // Floating platform: height between 50 and 150 pixels above the floor
        yPos -= (50 + _random.nextDouble() * 100);
      }
      
      TileTheme theme = _random.nextBool() ? TileTheme.blue : TileTheme.purple;
      
      if (isFloating) {
        // Spawn left edge
        game.world.add(PlatformBlock(position: Vector2(_lastSpawnX, yPos), theme: theme, platformType: PlatformType.thinLedgeLeft));
        _lastSpawnX += 16;
        
        // Spawn mid blocks
        for (int i = 0; i < numBlocks; i++) {
          game.world.add(PlatformBlock(position: Vector2(_lastSpawnX, yPos), theme: theme, platformType: PlatformType.thinLedgeMid));
          _spawnHazardOptionally(Vector2(_lastSpawnX + 8, yPos - 16), theme);
          _lastSpawnX += 32;
        }
        
        // Spawn right edge
        game.world.add(PlatformBlock(position: Vector2(_lastSpawnX, yPos), theme: theme, platformType: PlatformType.thinLedgeRight));
        _lastSpawnX += 16;
        
      } else {
        // Spawn solid ground blocks
        for (int i = 0; i < numBlocks; i++) {
          game.world.add(PlatformBlock(position: Vector2(_lastSpawnX, yPos), theme: theme, platformType: PlatformType.groundBlock));
          _spawnHazardOptionally(Vector2(_lastSpawnX + 8, yPos - 16), theme);
          _lastSpawnX += 32;
        }
      }
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
