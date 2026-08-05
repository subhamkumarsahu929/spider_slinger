import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';
import '../environment/platform_block.dart';
import '../../../config/game_constants.dart';
import 'dart:math';
import '../effects/hit_text_component.dart';

enum EnemyType { crawler, airborne }
enum EnemyState { idle, walk, attack, hit, death }

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  final EnemyType type;
  double speed;
  bool isDying = false;

  /// Set to true for enemies that should obey gravity (e.g. crawlers).
  /// Airborne enemies override this to false.
  bool useGravity = false;
  double verticalVelocity = 0.0;
  bool isGrounded = false;

  // Feature 2: Patrol boundaries
  double? patrolMinX;
  double? patrolMaxX;

  Enemy({required this.type, required this.speed, required Vector2 size, this.patrolMinX, this.patrolMaxX})
      : super(size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Hitboxes added in subclasses
  }

  bool isFacingRight = false; // Enemies usually spawn on the right and face left

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    if (current == EnemyState.hit) {
      if (animationTicker?.done() ?? false) {
        current = EnemyState.death;
      }
    } else if (current == EnemyState.death) {
      if (animationTicker?.done() ?? false) {
        removeFromParent();
      }
    } else {
      double horizontalMovement = -speed * dt; // Moving left by default
      position.x += horizontalMovement;

      // Handle patrol boundaries
      if (patrolMinX != null && position.x - size.x / 2 < patrolMinX!) {
        position.x = patrolMinX! + size.x / 2;
        speed = -speed; // Reverse direction
      } else if (patrolMaxX != null && position.x + size.x / 2 > patrolMaxX!) {
        position.x = patrolMaxX! - size.x / 2;
        speed = -speed; // Reverse direction
      }

      // #6 — Apply gravity for ground-based enemies
      if (useGravity) {
        if (!isGrounded) {
          verticalVelocity += GameConstants.gravity * dt;
          // Terminal velocity
          if (verticalVelocity > GameConstants.maxFallSpeed) {
            verticalVelocity = GameConstants.maxFallSpeed;
          }
        }
        position.y += verticalVelocity * dt;
        isGrounded = false; // Reset; collision resolves it
      }
      
      // Direction Flipping Logic
      bool movingLeft = horizontalMovement < 0;
      bool movingRight = horizontalMovement > 0;
      if (movingLeft && isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      } else if (movingRight && !isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }

      // Check if completely out of bounds left
      if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x) {
        removeFromParent();
      }
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
    // #6 — Ground-based enemies land on platforms
    if (useGravity && other is PlatformBlock && verticalVelocity >= 0) {
      if (intersectionPoints.isNotEmpty) {
        position.y = other.position.y - size.y / 2;
        verticalVelocity = 0;
        isGrounded = true;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // Keep enemy grounded on platforms while standing on them
    if (useGravity && other is PlatformBlock && verticalVelocity >= 0) {
      if (intersectionPoints.isNotEmpty) {
        position.y = other.position.y - size.y / 2;
        verticalVelocity = 0;
        isGrounded = true;
      }
    }
  }

  int health = 1;

  void hitByWeb(int damage) {
    if (isDying) return;
    health -= damage;
    
    // Spawn comic hit text!
    final hitWords = ['BAM!', 'POW!', 'WHACK!', 'THWIP!', 'SMACK!', 'CRUNCH!', 'BONK!', 'ZAP!', 'BIFF!'];
    final word = hitWords[Random().nextInt(hitWords.length)];
    game.world.add(HitTextComponent(text: word, position: position.clone()));

    if (health <= 0) {
      isDying = true;
      current = EnemyState.hit;
      speed = 0; // Stop moving
      children.whereType<ShapeHitbox>().forEach((h) => h.collisionType = CollisionType.inactive);
    }
  }

  SpriteAnimation createAnim(String path, {int amount = 4, bool loop = true}) {
    final image = game.images.fromCache(path);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.12,
        textureSize: Vector2(image.width / amount, image.height.toDouble()),
        loop: loop,
      ),
    );
  }
}
