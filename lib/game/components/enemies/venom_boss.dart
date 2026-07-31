import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import '../player/player_component.dart';
import '../../../config/game_constants.dart';

enum VenomState { idle, running, leapAttack, groundPound, hit, death }

class VenomBoss extends SpriteAnimationGroupComponent<VenomState> with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  int health = 5;
  bool isDying = false;
  double _stateTimer = 0.0;
  bool _isLeaping = false;
  bool isFacingRight = false; // Starts facing left
  
  double verticalVelocity = 0.0;
  
  // Constants
  final double runSpeed = 150.0 * 1.5; // 1.5x normal speed
  final double leapForce = -600.0;
  
  VenomBoss() : super(size: Vector2(96, 96), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Flip horizontally to face left towards Spider-Man
    flipHorizontallyAroundCenter();

    final image = game.images.fromCache('enemies/Venom.png');
    final spriteSize = Vector2(image.width / 4, image.height / 5);

    SpriteAnimation createAnimation(List<int> frames, {bool loop = true, double stepTime = 0.15}) {
      return SpriteAnimation.spriteList(
        frames.map((frameIndex) {
          final row = frameIndex ~/ 4;
          final col = frameIndex % 4;
          return Sprite(
            image,
            srcPosition: Vector2(col * spriteSize.x, row * spriteSize.y),
            srcSize: spriteSize,
          );
        }).toList(),
        stepTime: stepTime,
        loop: loop,
      );
    }
    
    animations = {
      VenomState.idle: createAnimation([1, 2]),
      VenomState.running: createAnimation([12, 13]),
      VenomState.leapAttack: createAnimation([5, 6, 7]),
      VenomState.groundPound: createAnimation([8, 9, 15]),
      VenomState.hit: createAnimation([17, 18, 19], loop: false, stepTime: 0.1),
      VenomState.death: createAnimation([17, 18, 19], loop: false),
    };

    current = VenomState.running;
    
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    if (current == VenomState.hit) {
      if (animationTicker?.done() ?? false) {
        if (health <= 0) {
          current = VenomState.death;
        } else {
          current = _isLeaping ? VenomState.leapAttack : VenomState.running;
        }
      }
      return; // Pause movement during hit
    }
    
    if (current == VenomState.death) {
      if (animationTicker?.done() ?? false) {
        removeFromParent();
      }
      return;
    }

    _stateTimer += dt;
    
    // Alternating behavior: run for a bit, then leap
    if (!_isLeaping && _stateTimer > 2.5) {
      _startLeap();
    }

    if (_isLeaping) {
      verticalVelocity += GameConstants.gravity * dt;
      position.y += verticalVelocity * dt;
      position.x -= (runSpeed * 1.3) * dt; // Leap a bit faster
      
      double floorY = game.size.y - 100 - size.y / 2 + 30; // Adjust for hitbox/center
      
      if (position.y >= floorY) {
        position.y = floorY;
        _isLeaping = false;
        _stateTimer = 0.0;
        current = VenomState.groundPound;
      }
    } else {
      if (current == VenomState.groundPound) {
        if (_stateTimer > 0.6) {
          current = VenomState.running;
        }
      } else {
        current = VenomState.running;
        position.x -= runSpeed * dt;
      }
    }
    
    // Calculate horizontal movement
    double horizontalMovement = _isLeaping ? -(runSpeed * 1.3) * dt : (current == VenomState.running ? -runSpeed * dt : 0);

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
    
    // Bounds check relative to camera
    if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x) {
      removeFromParent();
    }
  }

  void _startLeap() {
    _isLeaping = true;
    verticalVelocity = leapForce;
    current = VenomState.leapAttack;
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
    
    current = VenomState.hit;
    
    if (health <= 0) {
      isDying = true;
      game.gameState.addScore(200);
    }
  }
}
