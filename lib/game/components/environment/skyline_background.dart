import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';

class SkylineBackground extends Component with HasGameReference<SpiderSlingerGame> {
  final List<Offset> _stars = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {

    // Pre-populate random stars
    for (int i = 0; i < 40; i++) {
      _stars.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }

    // Add three layers of buildings with increasing speed and scale
    // Far layer (slowest, pushed high up to occupy upper screen)
    add(SkylineLayer(
      parallaxSpeed: 0.08,
      scaleFactor: 1.5,
      yOffset: 250.0,
      baseOpacity: 1.0,
    ));

    // Mid layer (medium, pushed up slightly less)
    add(SkylineLayer(
      parallaxSpeed: 0.18,
      scaleFactor: 2.0,
      yOffset: 120.0,
      baseOpacity: 1.0,
    ));

    // Near layer (fastest, huge scale, anchored to ground)
    add(SkylineLayer(
      parallaxSpeed: 0.32,
      scaleFactor: 2.5,
      yOffset: -20.0,
      baseOpacity: 1.0,
    ));
  }

  @override
  void render(Canvas canvas) {
    final dayTop = const Color(0xFF1E88E5);
    final dayMid = const Color(0xFF42A5F5);
    final dayBottom = const Color(0xFF90CAF9);

    final h3 = game.size.y / 3;
    
    // Top third
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, h3 + 1), Paint()..color = dayTop);
    // Middle third
    canvas.drawRect(Rect.fromLTWH(0, h3, game.size.x, h3 + 1), Paint()..color = dayMid);
    // Bottom third
    canvas.drawRect(Rect.fromLTWH(0, h3 * 2, game.size.x, h3), Paint()..color = dayBottom);
  }
}

class SkylineLayer extends Component with HasGameReference<SpiderSlingerGame> {
  final double parallaxSpeed;
  final double scaleFactor;
  final double yOffset;
  final double baseOpacity;

  double _lastSpawnX = 0.0;
  final Random _random = Random();

  SkylineLayer({
    required this.parallaxSpeed,
    required this.scaleFactor,
    required this.yOffset,
    required this.baseOpacity,
  });

  @override
  Future<void> onLoad() async {
    _lastSpawnX = game.camera.viewfinder.position.x;
  }

  @override
  void update(double dt) {
    super.update(dt);

    double cameraRightEdge = game.camera.viewfinder.position.x + game.size.x;
    // Calculate the trigger range for this parallax layer
    double targetSpawnX = (cameraRightEdge * parallaxSpeed) + game.size.x;

    final validIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14];
    while (_lastSpawnX < targetSpawnX) {
      int buildingId = validIds[_random.nextInt(validIds.length)];

      final daySprite = Sprite(game.images.fromCache('buildings/build_day_$buildingId.png'));
      final spriteSize = daySprite.srcSize * scaleFactor;

      final building = BuildingPairComponent(
        buildingId: buildingId,
        spawnX: _lastSpawnX,
        parallaxSpeed: parallaxSpeed,
        scaleFactor: scaleFactor,
        yOffset: yOffset,
        baseOpacity: baseOpacity,
        spriteSize: spriteSize,
      );
      add(building);

      _lastSpawnX += spriteSize.x;
    }
  }
}

class BuildingPairComponent extends PositionComponent with HasGameReference<SpiderSlingerGame> {
  final int buildingId;
  final double spawnX;
  final double parallaxSpeed;
  final double scaleFactor;
  final double yOffset;
  final double baseOpacity;
  final Vector2 spriteSize;

  late SpriteComponent dayBuilding;
  late SpriteComponent nightBuilding;

  BuildingPairComponent({
    required this.buildingId,
    required this.spawnX,
    required this.parallaxSpeed,
    required this.scaleFactor,
    required this.yOffset,
    required this.baseOpacity,
    required this.spriteSize,
  });

  @override
  Future<void> onLoad() async {
    final daySprite = Sprite(game.images.fromCache('buildings/build_day_$buildingId.png'));
    final nightSprite = Sprite(game.images.fromCache('buildings/build_night_$buildingId.png'));

    size = spriteSize;
    
    // Bottom-align building based on screen bottom minus yOffset
    // (Ensure we use game.size.y which represents the screen height)
    position.y = game.size.y - size.y - yOffset;

    dayBuilding = SpriteComponent(sprite: daySprite, size: size);
    nightBuilding = SpriteComponent(sprite: nightSprite, size: size); // Kept for structure, but visually we use flat silhouettes now

    add(dayBuilding);
    add(nightBuilding);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Tint into solid comic silhouettes using BlendMode.srcIn
    final currentTint = (parallaxSpeed < 0.1) 
        ? const Color(0xFF84FFFF) // Far: Light Cyan
        : (parallaxSpeed < 0.2) 
            ? const Color(0xFFFFF59D) // Mid: Light Yellow
            : const Color(0xFFF5F5F5); // Near: Off-White

    final filter = ColorFilter.mode(currentTint, BlendMode.srcIn);
    
    // We apply the silhouette filter at full opacity.
    dayBuilding.paint.colorFilter = filter;
    dayBuilding.paint.color = dayBuilding.paint.color.withValues(alpha: 1.0);
    
    // Hide the night building since the silhouette mask is identical
    nightBuilding.paint.color = nightBuilding.paint.color.withValues(alpha: 0.0);

    // Parallax movement formula
    double cameraX = game.camera.viewfinder.position.x;
    position.x = spawnX - (cameraX * parallaxSpeed);

    // Despawn when the building rolls completely off-screen left
    if (position.x + size.x < -100) {
      removeFromParent();
    }
  }
}
