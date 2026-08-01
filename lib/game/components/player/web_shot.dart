import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../enemies/enemy.dart';
import '../enemies/venom_boss.dart';
import '../../spider_slinger_game.dart';
import '../../../config/game_constants.dart';

class WebShot extends PositionComponent with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  final double speed = 600.0;
  final double direction; // 1.0 for right, -1.0 for left
  double _verticalVelocity = 0.0; // #9 — arc gravity

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
    // #12 — Draw an oval web blob with a centre thread for a more web-like look
    final cx = size.x / 2;
    final cy = size.y / 2;
    // Filled oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.x, height: size.y * 0.55),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    // Centre thread line
    canvas.drawLine(
      Offset(0, cy),
      Offset(size.x, cy),
      Paint()
        ..color = const Color(0xFFBBBBBB)
        ..strokeWidth = 1.5,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // #9 — Arc: apply gentle downward gravity so long shots drop
    _verticalVelocity += GameConstants.webArcGravity * dt;
    position.x += speed * direction * dt;
    position.y += _verticalVelocity * dt;
    
    // Despawn if it goes too far left or right offscreen relative to the camera
    if (position.x > game.camera.viewfinder.position.x + game.size.x * 2 ||
        position.x < game.camera.viewfinder.position.x - game.size.x * 2) {
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
