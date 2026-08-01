import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';

class DayNightManager extends Component {
  double cycleTimer = 0.0;
  double dayNightProgress = 0.0; // 0.0 = Full Day, 1.0 = Full Night

  @override
  void update(double dt) {
    super.update(dt);
    
    // 60 second cycle
    cycleTimer += dt;
    if (cycleTimer >= 60.0) {
      cycleTimer -= 60.0;
    }

    // 0 to 30: Day time (transition to night at the end)
    // 30 to 60: Night time (transition to day at the end)
    
    if (cycleTimer < 27.0) {
      // Full Day
      dayNightProgress = 0.0;
    } else if (cycleTimer < 30.0) {
      // Transition Day -> Night (3 seconds)
      dayNightProgress = (cycleTimer - 27.0) / 3.0;
    } else if (cycleTimer < 57.0) {
      // Full Night
      dayNightProgress = 1.0;
    } else {
      // Transition Night -> Day (3 seconds)
      dayNightProgress = 1.0 - ((cycleTimer - 57.0) / 3.0);
    }
    
    // Clamp to be safe
    dayNightProgress = dayNightProgress.clamp(0.0, 1.0);
  }
}

class SkylineBackground extends Component with HasGameReference<SpiderSlingerGame> {
  late final DayNightManager dayNightManager;
  final Random _random = Random();
  double _lastSpawnX = 0.0;

  @override
  Future<void> onLoad() async {
    dayNightManager = DayNightManager();
    add(dayNightManager);

    // Initial spawn to fill the screen
    _lastSpawnX = game.camera.viewfinder.position.x;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Spawn buildings ahead of the camera
    // Since buildings move at 0.3x speed relative to the camera, we need to spawn them
    // based on their parallax position. But to keep it simple, we can spawn them in world space
    // and adjust their position inside the BuildingPairComponent itself, OR we just position them 
    // in a pseudo-world space where they govern their own X position based on camera.
    // Actually, if we just spawn them using a tracker _lastSpawnX, they can move at 0.7x speed leftwards.
    // Let's spawn them in their own local coordinate system.
    
    // Camera right edge in standard world space
    double cameraRightEdge = game.camera.viewfinder.position.x + game.size.x;
    
    // We want to fill the background. The background moves at 0.3x camera speed.
    // So the background's right edge needs to cover the camera's right edge.
    // We can just keep spawning buildings until _lastSpawnX > cameraRightEdge * 0.3 + game.size.x
    double targetSpawnX = (cameraRightEdge * 0.3) + game.size.x;

    final validIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14];
    while (_lastSpawnX < targetSpawnX) {
      int buildingId = validIds[_random.nextInt(validIds.length)];
      final building = BuildingPairComponent(
        buildingId: buildingId,
        spawnX: _lastSpawnX,
      );
      add(building);
      
      // We don't know the exact width until it loads, but we can assume an average width to advance
      // the tracker, or we can await the sprite. Since we can't await in update(), we will pass 
      // a callback to the building to advance _lastSpawnX once it loads, OR we can just use a fixed width 
      // if all buildings share a similar width (e.g. 256).
      // Let's use a fixed assumed width for the tracker, and the building can just snap to _lastSpawnX.
      // Wait, it's better to just load the sprite in the spawner?
      // Since assets are pre-cached, game.images.fromCache is synchronous!
      final daySprite = Sprite(game.images.fromCache('buildings/build_day_$buildingId.png'));
      building.spriteSize = daySprite.srcSize;
      
      _lastSpawnX += building.spriteSize.x;
    }
  }

  @override
  void render(Canvas canvas) {
    // Render the Sky gradient/color
    // Day: 0xFF87CEEB, Night: 0xFF0B0C10
    final dayColor = const Color(0xFF87CEEB);
    final nightColor = const Color(0xFF0B0C10);
    
    final skyColor = Color.lerp(dayColor, nightColor, dayNightManager.dayNightProgress)!;
    
    // Fill the entire screen
    // We need to render this independent of the camera position if this component is added to the world.
    // Wait, if it's added to the game root (not world), it renders in screen space.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()..color = skyColor,
    );
  }
}

class BuildingPairComponent extends PositionComponent with HasGameReference<SpiderSlingerGame> {
  final int buildingId;
  final double spawnX;
  
  late SpriteComponent dayBuilding;
  late SpriteComponent nightBuilding;
  Vector2 spriteSize = Vector2.zero();

  BuildingPairComponent({required this.buildingId, required this.spawnX});

  @override
  Future<void> onLoad() async {
    final daySprite = Sprite(game.images.fromCache('buildings/build_day_$buildingId.png'));
    final nightSprite = Sprite(game.images.fromCache('buildings/build_night_$buildingId.png'));
    
    if (spriteSize == Vector2.zero()) {
      spriteSize = daySprite.srcSize;
    }
    
    size = spriteSize;
    
    // Position it so the bottom aligns with the screen bottom, or at a fixed Y.
    // Let's align bottom to game.size.y
    position.y = game.size.y - size.y;

    dayBuilding = SpriteComponent(sprite: daySprite, size: size);
    nightBuilding = SpriteComponent(sprite: nightSprite, size: size);

    add(dayBuilding);
    add(nightBuilding);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Adjust opacity based on dayNightProgress
    // We can get the manager from the parent
    final parentSkyline = parent as SkylineBackground;
    final progress = parentSkyline.dayNightManager.dayNightProgress;
    
    dayBuilding.paint.color = dayBuilding.paint.color.withValues(alpha: 1.0 - progress);
    nightBuilding.paint.color = nightBuilding.paint.color.withValues(alpha: progress);

    // Parallax Effect
    // The camera moves right. To create depth, buildings should move slower than the foreground.
    // If foreground speed is 1.0, and building speed is 0.3.
    // We calculate position based on camera position.
    double cameraX = game.camera.viewfinder.position.x;
    
    // position.x is updated to create the parallax scroll
    position.x = spawnX - (cameraX * 0.3);

    // Despawn if it falls completely off the left of the screen
    if (position.x + size.x < -100) {
      removeFromParent();
    }
  }
}
