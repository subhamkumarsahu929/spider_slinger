import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';

enum EnemyType { crawler, airborne }
enum EnemyState { idle, walk, attack, hit, death }

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState> with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  final EnemyType type;
  double speed;
  bool isDying = false;

  Enemy({required this.type, required this.speed, required Vector2 size}) : super(size: size, anchor: Anchor.center);

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
  }

  int health = 1;

  void hitByWeb(int damage) {
    if (isDying) return;
    health -= damage;
    if (health <= 0) {
      isDying = true;
      current = EnemyState.hit;
      speed = 0; // Stop moving
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
