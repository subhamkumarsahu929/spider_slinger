import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import 'web_shot.dart';
import 'vertical_web.dart';
import '../../../config/game_constants.dart';
import '../../../services/audio_service.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<SpiderSlingerGame>, CollisionCallbacks {
  double verticalVelocity = 0.0;
  bool isGrounded = false;
  bool isHanging = false;
  VerticalWeb? currentVerticalWeb;

  PlayerComponent() : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Placeholder sprite load using config (will fail if file not present, but we use a try-catch or colored box fallback)
    try {
      sprite = await gameRef.loadSprite('player.png'); // Hardcode fallback for now or use AppAssets.playerSprite
    } catch (e) {
      // Fallback if no assets
    }
    
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameRef.gameState.isGameOver) return;

    if (!isHanging) {
      // Apply gravity
      verticalVelocity += GameConstants.gravity * dt;
      position.y += verticalVelocity * dt;

      // Basic floor collision fallback for testing (assuming floor is at y = gameRef.size.y - 100)
      if (position.y >= gameRef.size.y - 100) {
        position.y = gameRef.size.y - 100;
        verticalVelocity = 0;
        isGrounded = true;
      } else {
        isGrounded = false;
      }
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
    final web = WebShot(position: position.clone() + Vector2(size.x / 2, 0));
    gameRef.add(web);
    AudioService.playWebShot();
  }

  void shootVerticalWeb() {
    if (gameRef.gameState.isGameOver || isHanging) return;
    
    // Shoot web upwards. For simplicity, immediately transition to hanging state
    // if we are above the floor.
    if (!isGrounded) {
      isHanging = true;
      verticalVelocity = 0;
      currentVerticalWeb = VerticalWeb(position: position.clone()..y -= size.y/2);
      gameRef.add(currentVerticalWeb!);
      AudioService.playWebShot();
    }
  }

  void hit() {
    gameRef.gameState.takeDamage();
    AudioService.playHit();
    if (gameRef.gameState.lives <= 0) {
      AudioService.playGameOver();
    }
  }
}
