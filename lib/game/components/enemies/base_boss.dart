import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';
import '../effects/hit_text_component.dart';

abstract class BaseBoss<T> extends SpriteAnimationGroupComponent<T> with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  int health;
  bool isDying = false;
  double stateTimer = 0.0;
  bool isFacingRight = false;
  double verticalVelocity = 0.0;
  double runSpeed;

  BaseBoss({
    required this.health,
    required this.runSpeed,
    required Vector2 size,
  }) : super(size: size, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    // Subclasses should call super.update(dt) and handle hit/death states.
  }

  double getPlayerDirection() {
    double targetDirection = -1; // Default left
    final player = game.world.children.whereType<PlayerComponent>().firstOrNull;
    if (player != null) {
      targetDirection = player.position.x > position.x ? 1.0 : -1.0;
    }
    return targetDirection;
  }

  void updateFacingDirection(double horizontalMovement) {
    bool movingLeft = horizontalMovement < 0;
    bool movingRight = horizontalMovement > 0;
    if (movingLeft && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    } else if (movingRight && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      if (!game.gameState.isInvulnerable && !isDying) {
        other.hit();
      }
    }
  }

  void hitByWeb(int damage) {
    if (isDying) return;
    health -= damage;
    
    final hitWords = ['BAM!', 'POW!', 'WHACK!', 'THWIP!', 'SMACK!', 'CRUNCH!', 'BONK!', 'ZAP!', 'BIFF!'];
    final word = hitWords[Random().nextInt(hitWords.length)];
    game.world.add(HitTextComponent(text: word, position: position.clone()));

    game.cameraShake(
      duration: health <= 0 ? 0.45 : 0.2,
      intensity: health <= 0 ? 14.0 : 7.0,
    );

    onHit();

    if (health <= 0) {
      isDying = true;
      children.whereType<ShapeHitbox>().forEach((h) => h.collisionType = CollisionType.inactive);
      onDeath();
    }
  }

  /// Hook for subclasses to change state to hit
  void onHit();

  /// Hook for subclasses to change state to death
  void onDeath();
}
