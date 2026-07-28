import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../enemies/enemy.dart';
import '../../spider_slinger_game.dart';
import '../../../config/game_constants.dart';

class WebShot extends PositionComponent with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  final double speed = 600.0;

  WebShot({required Vector2 position}) : super(position: position, size: Vector2(20, 10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    // Fallback render
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    if (position.x > gameRef.size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      other.die();
      removeFromParent();
      if (other.type == EnemyType.crawler) {
        gameRef.gameState.addScore(GameConstants.scoreCrawler);
      } else {
        gameRef.gameState.addScore(GameConstants.scoreAirborne);
      }
    }
  }
}
