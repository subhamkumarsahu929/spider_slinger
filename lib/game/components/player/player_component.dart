import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import 'web_shot.dart';
import 'vertical_web.dart';
import '../../../config/game_constants.dart';
import '../../../services/audio_service.dart';

enum PlayerState { idle, running, jumping, hanging, attacking, hurt }

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  double verticalVelocity = 0.0;
  double horizontalVelocity = 0.0;
  bool isGrounded = false;
  bool isHanging = false;
  bool isAttacking = false;
  bool isHurt = false;
  bool isFacingRight = true;
  double attackTimer = 0.0;
  double hurtTimer = 0.0;
  VerticalWeb? currentVerticalWeb;

  PlayerComponent() : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    try {
      final image = await gameRef.images.load('sprites/Spider-Man.png');
      final spriteSize = Vector2(image.width / 5, image.height / 5);
      
      SpriteAnimation createAnimation(List<int> frames) {
        return SpriteAnimation.spriteList(
          frames.map((frameIndex) {
            final row = frameIndex ~/ 5;
            final col = frameIndex % 5;
            return Sprite(
              image,
              srcPosition: Vector2(col * spriteSize.x, row * spriteSize.y),
              srcSize: spriteSize,
            );
          }).toList(),
          stepTime: 0.15,
        );
      }

      animations = {
        PlayerState.idle: createAnimation([0, 1]),
        PlayerState.running: createAnimation([2, 3, 5, 6]),
        PlayerState.jumping: createAnimation([8, 9, 12]),
        PlayerState.hanging: createAnimation([18, 19]),
        PlayerState.attacking: createAnimation([4, 16]),
        PlayerState.hurt: createAnimation([21, 22]),
      };
      
      current = PlayerState.idle;
    } catch (e) {
      // Fallback
    }
    
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameRef.gameState.isGameOver) return;

    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) isAttacking = false;
    }

    if (isHurt) {
      hurtTimer -= dt;
      if (hurtTimer <= 0) isHurt = false;
    }

    // Direction Flipping Logic
    bool movingLeft = horizontalVelocity < 0;
    bool movingRight = horizontalVelocity > 0;
    if (movingLeft && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    } else if (movingRight && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    }

    if (!isHanging) {
      // Apply horizontal and vertical movement
      position.x += horizontalVelocity * dt;
      
      // Bounds check so player doesn't run infinitely left
      if (position.x < size.x / 2) {
        position.x = size.x / 2;
      }

      // Apply gravity
      verticalVelocity += GameConstants.gravity * dt;
      position.y += verticalVelocity * dt;

      // Basic floor collision fallback for testing
      if (position.y >= gameRef.size.y - 100) {
        position.y = gameRef.size.y - 100;
        verticalVelocity = 0;
        isGrounded = true;
      } else {
        isGrounded = false;
      }
    } else {
      // Swinging mechanics (horizontal movement while hanging)
      if (horizontalVelocity != 0) {
        position.x += horizontalVelocity * dt;
        if (currentVerticalWeb != null) {
          currentVerticalWeb!.position.x = position.x; // Web moves with player while swinging
        }
      }
    }

    // Update animation state
    if (isHurt) {
      current = PlayerState.hurt;
    } else if (isAttacking) {
      current = PlayerState.attacking;
    } else if (isHanging) {
      current = PlayerState.hanging;
    } else if (!isGrounded) {
      current = PlayerState.jumping;
    } else {
      current = horizontalVelocity == 0 ? PlayerState.idle : PlayerState.running;
    }
  }

  void jump() {
    if (isGrounded && !isHanging) {
      verticalVelocity = GameConstants.jumpForce;
      isGrounded = false;
      AudioService.playJump();
    } else if (isHanging) {
      // Detach and jump
      isHanging = false;
      currentVerticalWeb?.removeFromParent();
      currentVerticalWeb = null;
      verticalVelocity = GameConstants.jumpForce;
      AudioService.playJump();
    }
  }

  void shootHorizontalWeb() {
    if (gameRef.gameState.isGameOver) return;
    
    isAttacking = true;
    attackTimer = 0.3; // Give the attack animation time to play
    
    final directionMultiplier = isFacingRight ? 1.0 : -1.0;
    final web = WebShot(
      position: position.clone() + Vector2(directionMultiplier * (size.x / 2), 0),
      direction: directionMultiplier,
    );
    gameRef.add(web);
    AudioService.playWebShot();
  }

  void shootVerticalWeb() {
    if (gameRef.gameState.isGameOver || isHanging) return;
    
    if (!isGrounded) {
      isHanging = true;
      verticalVelocity = 0;
      // Web Anchor World Position fix: uses global world x position
      currentVerticalWeb = VerticalWeb(position: position.clone()..y -= size.y/2);
      gameRef.add(currentVerticalWeb!);
      AudioService.playWebShot();
    }
  }

  void hit() {
    gameRef.gameState.takeDamage();
    isHurt = true;
    hurtTimer = 0.45; // About 3 frames at 0.15s each
    AudioService.playHit();
    if (gameRef.gameState.lives <= 0) {
      AudioService.playGameOver();
    }
  }
}
