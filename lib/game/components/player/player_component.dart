import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import 'web_shot.dart';
import 'vertical_web.dart';
import '../environment/platform_block.dart';
import '../../../config/game_constants.dart';
import '../../../services/audio_service.dart';

enum PlayerState { idle, running, jumping, hanging, attacking, hurt }

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerState> with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  double verticalVelocity = 0.0;
  double horizontalVelocity = 0.0;
  bool isGrounded = false;
  bool isHanging = false;
  bool isAttacking = false;
  bool isHurt = false;
  bool isFacingRight = true;
  bool isUpsideDown = false;
  bool isSwinging = false;
  bool moveInputLeft = false;
  bool moveInputRight = false;
  double attackTimer = 0.0;
  double hurtTimer = 0.0;
  double swingTimer = 0.0;
  VerticalWeb? currentVerticalWeb;

  PlayerComponent() : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load('sprites/Spider-Man.png');
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
    
    if (game.gameState.isGameOver) return;

    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) isAttacking = false;
    }

    if (isHurt) {
      hurtTimer -= dt;
      if (hurtTimer <= 0) isHurt = false;
    }

    if (isSwinging) {
      swingTimer -= dt;
      if (swingTimer <= 0) {
        isSwinging = false;
        // Revert to input-driven velocity
        if (moveInputLeft) {
          horizontalVelocity = -GameConstants.playerSpeed;
        } else if (moveInputRight) {
          horizontalVelocity = GameConstants.playerSpeed;
        } else {
          horizontalVelocity = 0;
        }
      }
    } else {
      // Ensure velocity matches input if not swinging
      if (moveInputLeft) horizontalVelocity = -GameConstants.playerSpeed;
      else if (moveInputRight) horizontalVelocity = GameConstants.playerSpeed;
      else horizontalVelocity = 0;
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
      // Un-flip vertically if we detached
      if (isUpsideDown) {
        flipVerticallyAroundCenter();
        isUpsideDown = false;
      }

      // Apply horizontal and vertical movement
      position.x += horizontalVelocity * dt;
      
      // Bounds check so player doesn't run infinitely left past camera
      if (position.x < game.camera.viewfinder.position.x - game.size.x / 2 + size.x / 2) {
        position.x = game.camera.viewfinder.position.x - game.size.x / 2 + size.x / 2;
      }

      // Apply gravity (isGrounded will be resolved by onCollision)
      verticalVelocity += GameConstants.gravity * dt;
      position.y += verticalVelocity * dt;
      isGrounded = false; // Reset every frame; collision resolves it to true if touching

      // Fallback if falls into the void (death)
      if (position.y > game.size.y + 200) {
         hit();
         position.y = 100; // Reset high up
         verticalVelocity = 0;
      }
    } else {
      // Hanging upside down
      if (!isUpsideDown) {
        flipVerticallyAroundCenter();
        isUpsideDown = true;
      }

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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlatformBlock) {
      // Resolve falling collision
      if (verticalVelocity > 0) {
        double platformTop = other.position.y;
        double playerBottom = position.y + size.y / 2;
        
        // Ensure we were roughly above or near the top of the platform to stand on it
        if (playerBottom - verticalVelocity * 0.016 <= platformTop + 20) {
          position.y = platformTop - size.y / 2 + 1; // +1 ensures continuous intersection
          verticalVelocity = 0;
          isGrounded = true;
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void jump() {
    if (isGrounded && !isHanging) {
      verticalVelocity = GameConstants.jumpForce;
      isGrounded = false;
      AudioService.playJump();
    } else if (isHanging) {
      // Detach and drop
      isHanging = false;
      currentVerticalWeb?.removeFromParent();
      currentVerticalWeb = null;
      verticalVelocity = GameConstants.jumpForce * 0.5;
    }
  }

  void triggerSwing() {
    if (isHanging) {
      isHanging = false;
      currentVerticalWeb?.removeFromParent();
      currentVerticalWeb = null;
      
      // Massive forward leap!
      verticalVelocity = GameConstants.jumpForce * 0.8;
      
      // Determine direction based on current input, or face direction if no input
      if (moveInputLeft) {
        horizontalVelocity = -500;
        isFacingRight = false;
      } else if (moveInputRight) {
        horizontalVelocity = 500;
        isFacingRight = true;
      } else {
        horizontalVelocity = isFacingRight ? 500 : -500;
      }
      
      // Activate swing timer to stop horizontal momentum shortly after
      isSwinging = true;
      swingTimer = 0.35; // 350ms of forward momentum before stopping

      AudioService.playJump();
    }
  }

  void moveLeft() {
    moveInputLeft = true;
    if (!isSwinging) horizontalVelocity = -GameConstants.playerSpeed;
  }

  void moveRight() {
    moveInputRight = true;
    if (!isSwinging) horizontalVelocity = GameConstants.playerSpeed;
  }

  void stopMoving() {
    moveInputLeft = false;
    moveInputRight = false;
    if (!isSwinging) horizontalVelocity = 0;
  }

  void shootHorizontalWeb() {
    if (game.gameState.isGameOver) return;
    
    isAttacking = true;
    attackTimer = 0.3; // Give the attack animation time to play
    
    final directionMultiplier = isFacingRight ? 1.0 : -1.0;
    final web = WebShot(
      position: position.clone() + Vector2(directionMultiplier * (size.x / 2), 0),
      direction: directionMultiplier,
    );
    game.world.add(web);
    AudioService.playWebShot();
  }

  void shootVerticalWeb() {
    if (game.gameState.isGameOver || isHanging) return;
    
    if (!isGrounded) {
      isHanging = true;
      verticalVelocity = 0;
      // Web Anchor World Position fix: uses global world x position
      currentVerticalWeb = VerticalWeb(position: position.clone()..y -= size.y/2);
      game.world.add(currentVerticalWeb!);
      AudioService.playWebShot();
    }
  }

  void hit() {
    game.gameState.takeDamage();
    isHurt = true;
    hurtTimer = 0.45; // About 3 frames at 0.15s each
    AudioService.playHit();
    if (game.gameState.lives <= 0) {
      AudioService.playGameOver();
    }
  }
}
