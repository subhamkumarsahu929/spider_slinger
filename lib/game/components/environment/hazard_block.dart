import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';

class HazardBlock extends PositionComponent with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  HazardBlock({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = Colors.red.shade900);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      if (!gameRef.gameState.isInvulnerable) {
        other.hit();
      }
    }
  }
}
