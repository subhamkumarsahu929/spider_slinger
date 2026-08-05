import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../../config/game_constants.dart';
import '../environment/platform_block.dart';
import 'base_boss.dart';

enum RhinoState { idle, running, leapAttack, groundPound, hit, death }

class RhinoBoss extends BaseBoss<RhinoState> {
  bool _isLeaping = false;
  final double leapForce = -650.0;
  
  RhinoBoss() : super(
    health: 15,
    runSpeed: 200.0,
    size: Vector2(96, 96), // Scaled up!
  );

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

    final runAnim = loadBossRunRightAnimation('enemies/\$Rhino.png');

    animations = {
      RhinoState.idle: runAnim,
      RhinoState.running: runAnim,
      RhinoState.leapAttack: runAnim,
      RhinoState.groundPound: runAnim,
      RhinoState.hit: runAnim,
      RhinoState.death: runAnim,
    };

    // Tint for Silver aesthetic
    paint.colorFilter = const ColorFilter.mode(Color(0xFFC0C0C0), BlendMode.srcATop);

    current = RhinoState.running;
    add(RectangleHitbox(size: Vector2(70, 90), position: Vector2(13, 3)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    if (current == RhinoState.hit) {
      if (animationTicker?.done() ?? false) {
        if (health <= 0) {
          current = RhinoState.death;
        } else {
          current = _isLeaping ? RhinoState.leapAttack : RhinoState.running;
        }
      }
      return;
    }
    
    if (current == RhinoState.death) {
      if (animationTicker?.done() ?? false) {
        game.gameState.bossDefeated();
        removeFromParent();
      }
      return;
    }

    stateTimer += dt;
    if (!_isLeaping && stateTimer > 1.5) {
      _startLeap();
    }

    double targetDirection = getPlayerDirection();

    if (_isLeaping) {
      verticalVelocity += GameConstants.gravity * dt;
      if (verticalVelocity > 0) {
        verticalVelocity += GameConstants.gravity * (GameConstants.fallMultiplier - 1) * dt;
      }
      if (verticalVelocity > GameConstants.maxFallSpeed) {
        verticalVelocity = GameConstants.maxFallSpeed;
      }
      position.y += verticalVelocity * dt;
      position.x += targetDirection * (runSpeed * 1.3) * dt;

      final double fallbackFloorY = game.size.y - 100 - size.y / 2 + 30;
      if (position.y >= fallbackFloorY) {
        position.y = fallbackFloorY;
        _landLeap();
      }
    } else {
      if (current == RhinoState.groundPound) {
        if (stateTimer > 0.6) {
          current = RhinoState.running;
        }
      } else {
        current = RhinoState.running;
        position.x += targetDirection * runSpeed * dt;
      }
    }
    
    updateFacingDirection(targetDirection * runSpeed);

    if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x) {
      removeFromParent();
    }
  }

  void _startLeap() {
    _isLeaping = true;
    verticalVelocity = leapForce;
    current = RhinoState.leapAttack;
  }

  void _landLeap() {
    _isLeaping = false;
    stateTimer = 0.0;
    current = RhinoState.groundPound;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isLeaping && other is PlatformBlock && verticalVelocity >= 0) {
      if (intersectionPoints.isNotEmpty) {
        position.y = other.position.y - size.y / 2;
        verticalVelocity = 0;
        _landLeap();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!_isLeaping && other is PlatformBlock && verticalVelocity >= 0) {
      if (intersectionPoints.isNotEmpty) {
        position.y = other.position.y - size.y / 2;
        verticalVelocity = 0;
      }
    }
  }

  @override
  void onHit() {
    current = RhinoState.hit;
  }

  @override
  void onDeath() {}
}
