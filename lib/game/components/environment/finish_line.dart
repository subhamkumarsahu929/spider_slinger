import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';

class FinishLine extends PositionComponent with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  FinishLine({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    // Checkerboard or yellow line fallback
    canvas.drawRect(size.toRect(), Paint()..color = Colors.yellow);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      game.gameState.triggerWin();
    }
  }
}
