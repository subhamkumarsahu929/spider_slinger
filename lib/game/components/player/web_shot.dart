import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../enemies/enemy.dart';
import '../enemies/venom_boss.dart';
import '../../spider_slinger_game.dart';
import '../../../config/game_constants.dart';

class WebShot extends PositionComponent with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  final double speed = 600.0;
  final double direction; // 1.0 for right, -1.0 for left

  WebShot({required Vector2 position, this.direction = 1.0}) 
      : super(position: position, size: Vector2(20, 10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    if (direction < 0) {
      flipHorizontallyAroundCenter(); // Flip the web graphic if shooting left
    }
  }

  @override
  void render(Canvas canvas) {
    // Fallback render
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * direction * dt;
    
    // Despawn if it goes too far left or right offscreen relative to the camera
    if (position.x > gameRef.camera.viewfinder.position.x + gameRef.size.x * 2 ||
        position.x < gameRef.camera.viewfinder.position.x - gameRef.size.x * 2) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      if (!other.isDying) {
        other.hitByWeb(GameConstants.webShotDamage);
        removeFromParent();
        if (other.type == EnemyType.crawler) {
          game.gameState.addScore(GameConstants.scoreCrawler);
        } else {
          game.gameState.addScore(GameConstants.scoreAirborne);
        }
      }
    } else if (other is VenomBoss) {
      if (!other.isDying) {
        other.hitByWeb(GameConstants.webShotDamage);
        removeFromParent();
      }
    }
  }
}
