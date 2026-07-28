import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';

enum EnemyType { crawler, airborne }

abstract class Enemy extends SpriteComponent with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  final EnemyType type;
  double speed;

  Enemy({required this.type, required this.speed, required Vector2 size}) : super(size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameState.isGameOver) return;
    
    position.x -= speed * dt;
    if (position.x + size.x < 0) {
      removeFromParent();
    }
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

  void die() {
    // Add explosion or death effect here if needed
    removeFromParent();
  }
}
