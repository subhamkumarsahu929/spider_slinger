import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../player/player_component.dart';
import 'base_boss.dart';

enum VultureState { idle, running, hit, death }

class VultureBoss extends BaseBoss<VultureState> {
  VultureBoss() : super(
    health: 12,
    runSpeed: 180.0,
    size: Vector2(96, 96), // Scaled up!
  );

  double _time = 0;
  final double hoverAmplitude = 40.0;
  final double hoverFrequency = 2.0;
  double _baseY = 0;

  @override
  Future<void> onLoad() async {
    flipHorizontallyAroundCenter();

    // Helper to slice a 3-frame walking row
    SpriteAnimation loadBossRunRightAnimation(String imagePath) {
      return SpriteAnimation.fromFrameData(
        game.images.fromCache(imagePath),
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.15,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(0, 96), // Row 3 (Right facing)
        ),
      );
    }

    final runAnim = loadBossRunRightAnimation('enemies/\$Vulture Character Sprite.png');

    animations = {
      VultureState.idle: runAnim,
      VultureState.running: runAnim,
      VultureState.hit: runAnim,
      VultureState.death: runAnim,
    };

    // Tint for Golden aesthetic
    paint.colorFilter = const ColorFilter.mode(Color(0xFFFFD700), BlendMode.srcATop);

    current = VultureState.running;
    add(RectangleHitbox(size: Vector2(70, 90), position: Vector2(13, 3)));
    
    // Set base Y for hovering once added to game
    _baseY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    if (current == VultureState.hit) {
      if (animationTicker?.done() ?? false) {
        if (health <= 0) {
          current = VultureState.death;
        } else {
          current = VultureState.running;
        }
      }
      return;
    }
    
    if (current == VultureState.death) {
      if (animationTicker?.done() ?? false) {
        game.gameState.bossDefeated();
        removeFromParent();
      }
      return;
    }

    if (_baseY == 0) _baseY = position.y;

    double targetDirection = getPlayerDirection();
    
    // Aggressive Y Tracking
    final player = game.world.children.whereType<PlayerComponent>().firstOrNull;
    if (player != null) {
      double targetY = player.position.y - 150; // Aim to hover slightly above player
      _baseY += (targetY - _baseY) * 2.0 * dt; // Lerp towards target Y aggressively
    }
    
    // Movement
    position.x += targetDirection * runSpeed * dt;
    
    // Hovering (No Gravity)
    _time += dt;
    position.y = _baseY + sin(_time * hoverFrequency) * hoverAmplitude;
    
    updateFacingDirection(targetDirection * runSpeed);

    // Screen bound cleanup
    if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x) {
      removeFromParent();
    }
  }

  @override
  void onHit() {
    current = VultureState.hit;
  }

  @override
  void onDeath() {}
}
