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

    // 0 to 27: Day time
    // 27 to 30: Transition Day -> Night (3 seconds)
    // 30 to 57: Night time
    // 57 to 60: Transition Night -> Day (3 seconds)
    
    if (cycleTimer < 27.0) {
      dayNightProgress = 0.0;
    } else if (cycleTimer < 30.0) {
      dayNightProgress = (cycleTimer - 27.0) / 3.0;
    } else if (cycleTimer < 57.0) {
      dayNightProgress = 1.0;
    } else {
      dayNightProgress = 1.0 - ((cycleTimer - 57.0) / 3.0);
    }
    
    dayNightProgress = dayNightProgress.clamp(0.0, 1.0);
  }
}

class SkylineBackground extends Component with HasGameReference<SpiderSlingerGame> {
  late final DayNightManager dayNightManager;
  final List<Offset> _stars = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    dayNightManager = DayNightManager();
    add(dayNightManager);

    // Pre-populate random stars
    for (int i = 0; i < 40; i++) {
      _stars.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }

    // Add three layers of buildings with increasing speed, scale, and base opacity
    // Far layer (slowest, smallest, most faint)
    add(SkylineLayer(
      parallaxSpeed: 0.08,
      scaleFactor: 0.5,
      yOffset: 80.0,
      baseOpacity: 0.35,
    ));

    // Mid layer (medium)
    add(SkylineLayer(
      parallaxSpeed: 0.18,
      scaleFactor: 0.75,
      yOffset: 35.0,
      baseOpacity: 0.65,
    ));

    // Near layer (fastest, full size, full opacity)
    add(SkylineLayer(
      parallaxSpeed: 0.32,
      scaleFactor: 1.0,
      yOffset: 0.0,
      baseOpacity: 1.0,
    ));
  }

  @override
  void render(Canvas canvas) {
    final progress = dayNightManager.dayNightProgress;
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);

    // Linear gradient for Day and Night sky
    // Day Sky: Sky blue -> lighter sunset horizon
    // Night Sky: Deep dark indigo -> dark purple
    final dayTop = const Color(0xFF1E88E5);
    final dayBottom = const Color(0xFF90CAF9);
    final nightTop = const Color(0xFF030712);
    final nightBottom = const Color(0xFF1E1E2E);

    final lerpedTop = Color.lerp(dayTop, nightTop, progress)!;
    final lerpedBottom = Color.lerp(dayBottom, nightBottom, progress)!;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lerpedTop, lerpedBottom],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Render stars when progress > 0
    if (progress > 0.05) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: progress * 0.7);
      for (final star in _stars) {
        // Draw star in top 60% of the screen
        canvas.drawCircle(
          Offset(star.dx * game.size.x, star.dy * game.size.y * 0.6),
          1.5,
          starPaint,
        );
      }
    }
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
    nightBuilding = SpriteComponent(sprite: nightSprite, size: size);

    add(dayBuilding);
    add(nightBuilding);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final layer = parent as SkylineLayer;
    final parentSkyline = layer.parent as SkylineBackground;
    final progress = parentSkyline.dayNightManager.dayNightProgress;

    dayBuilding.paint.color = dayBuilding.paint.color.withValues(alpha: (1.0 - progress) * baseOpacity);
    nightBuilding.paint.color = nightBuilding.paint.color.withValues(alpha: progress * baseOpacity);

    // Parallax movement formula
    double cameraX = game.camera.viewfinder.position.x;
    position.x = spawnX - (cameraX * parallaxSpeed);

    // Despawn when the building rolls completely off-screen left
    if (position.x + size.x < -100) {
      removeFromParent();
    }
  }
}
