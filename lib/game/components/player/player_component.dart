import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import 'web_shot.dart';
import 'vertical_web.dart';
import '../environment/platform_block.dart';
import '../../../config/game_constants.dart';
import '../effects/hit_text_component.dart';
import '../../../services/audio_service.dart';

enum PlayerState { idle, running, jumping, hanging, attacking, hurt, swinging }

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

  // --- Physics state ---
  bool _jumpHeld = false;           // True while jump button is held down
  double _coyoteTimer = 0.0;        // Seconds remaining to jump after leaving a ledge
  double _jumpBufferTimer = 0.0;    // Seconds remaining for a buffered jump press
  double _lastDt = 0.016;           // Actual dt from last frame (used in collision resolution)
  static const double _coyoteTime    = 0.10;
  static const double _jumpBufferTime = 0.10;

  // --- Pendulum swing state (#5) ---
  Vector2? _swingAnchor;   // World position of ceiling attachment point
  double _swingAngle  = 0; // Angle from vertical (radians); + = rightward
  double _swingAngVel = 0; // Angular velocity (rad/s)
  double _ropeLength  = GameConstants.ropeLength;

  // --- Void respawn state (#8) ---
  final Vector2 _lastSafePosition = Vector2.zero();
  double _respawnGrace = 0.0;              // Seconds of post-respawn immunity
  static const double _respawnGraceDuration = 0.6;

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
        PlayerState.idle: createAnimation([0]),
        PlayerState.running: createAnimation([2, 3, 5, 6]),
        PlayerState.jumping: createAnimation([8, 9, 12]),
        PlayerState.hanging: createAnimation([18, 19]),
        PlayerState.attacking: createAnimation([4, 16]),
        PlayerState.hurt: createAnimation([21, 22]),
        PlayerState.swinging: createAnimation([15, 17, 24]),
      };
      
      current = PlayerState.idle;
    } catch (e) {
      // Fallback
    }
    
    // Tighten player hitbox to ignore empty transparent space in the 64x64 sprite
    add(RectangleHitbox(size: Vector2(28, 46), position: Vector2(18, 18)));
  }

  @override
  void update(double dt) {
    // Tick down game-wide invulnerability timer
    game.gameState.updateInvulnerability(dt);

    // Flashing effect during invulnerability
    if (game.gameState.isInvulnerable) {
      final isFlash = (DateTime.now().millisecondsSinceEpoch ~/ 150) % 2 == 0;
      opacity = isFlash ? 0.3 : 1.0;
    } else {
      opacity = 1.0;
    }

    // Update animation state based on previous frame's collision results
    if (isHurt) {
      current = PlayerState.hurt;
    } else if (isAttacking) {
      current = PlayerState.attacking;
    } else if (isHanging) {
      current = PlayerState.hanging;
    } else if (isSwinging) {
      current = PlayerState.swinging;
    } else if (!isGrounded) {
      current = PlayerState.jumping;
    } else {
      current = horizontalVelocity == 0 ? PlayerState.idle : PlayerState.running;
    }

    super.update(dt);
    
    if (game.gameState.isGameOver) {
      opacity = 1.0; // Reset opacity on game over
      return;
    }

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
        // After swing, resume acceleration-based input
      }
    }

    if (!isSwinging && !isHanging) {
      // #1 — Smooth acceleration & friction (only when grounded/airborne, not hanging)
      final double targetVelocity = moveInputLeft  ? -GameConstants.playerSpeed
                                  : moveInputRight ? GameConstants.playerSpeed
                                  : 0.0;
      if (targetVelocity != 0) {
        horizontalVelocity = _moveToward(
          horizontalVelocity, targetVelocity, GameConstants.acceleration * dt);
      } else {
        horizontalVelocity = _moveToward(
          horizontalVelocity, 0, GameConstants.friction * dt);
      }
    }

    // Direction flip — uses pendulum angular velocity while hanging,
    // regular horizontal velocity otherwise
    final bool wantsLeft  = isHanging ? _swingAngVel < -0.08 : horizontalVelocity < 0;
    final bool wantsRight = isHanging ? _swingAngVel >  0.08 : horizontalVelocity > 0;
    if (wantsLeft && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    } else if (wantsRight && !isFacingRight) {
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

      // #2 — Coyote time: allow jumping briefly after walking off a ledge
      if (isGrounded) {
        _coyoteTimer = _coyoteTime;
        // #8 — Track last safe position for void respawn
        _lastSafePosition.setFrom(position);
      } else {
        _coyoteTimer -= dt;
      }

      // #2 — Jump buffer: fire a queued jump on the first frame of landing
      if (_jumpBufferTimer > 0) {
        _jumpBufferTimer -= dt;
        if (isGrounded || _coyoteTimer > 0) {
          _executeJump();
          _jumpBufferTimer = 0;
        }
      }

      // #3 + #4 — Asymmetric gravity with terminal velocity cap
      verticalVelocity += GameConstants.gravity * dt;
      if (verticalVelocity > 0) {
        // Falling — heavier pull
        verticalVelocity += GameConstants.gravity * (GameConstants.fallMultiplier - 1) * dt;
      } else if (verticalVelocity < 0 && !_jumpHeld) {
        // Rising but jump button released — cut the arc short
        verticalVelocity += GameConstants.gravity * (GameConstants.lowJumpMultiplier - 1) * dt;
      }

      // #4 — Terminal velocity: prevent tunneling on lag spikes
      if (verticalVelocity > GameConstants.maxFallSpeed) {
        verticalVelocity = GameConstants.maxFallSpeed;
      }

      position.y += verticalVelocity * dt;
      _lastDt = dt; // Store for use in collision callbacks
      isGrounded = false; // Reset every frame; collision resolves it to true if touching

      // #8 — Tick down respawn grace; suppress void check during it
      if (_respawnGrace > 0) _respawnGrace -= dt;

      // Fallback if falls into the void (death)
      if (_respawnGrace <= 0 && position.y > game.size.y + 200) {
        hit();
        game.cameraShake(duration: 0.35, intensity: 10.0);
        // Respawn at last known safe ground position, or a default if none yet
        final safePos = _lastSafePosition.isZero()
            ? Vector2(game.camera.viewfinder.position.x, game.size.y - 200)
            : _lastSafePosition;
        position.setFrom(safePos);
        verticalVelocity  = 0;
        horizontalVelocity = 0;
        _respawnGrace = _respawnGraceDuration;
      }
    } else {
      // Hanging — pendulum swing physics (#5)
      if (!isUpsideDown) {
        flipVerticallyAroundCenter();
        isUpsideDown = true;
      }

      if (_swingAnchor != null) {
        // Pendulum: angular acceleration = -(g / L) * sin(θ)
        _swingAngVel +=
            (-GameConstants.gravity / _ropeLength) * sin(_swingAngle) * dt;

        // Exponential air-resistance damping (frame-rate independent)
        _swingAngVel *= exp(-GameConstants.swingDamping * dt);

        // Player can actively pump the swing with left/right input
        if (moveInputLeft)  _swingAngVel -= 3.0 * dt;
        if (moveInputRight) _swingAngVel += 3.0 * dt;

        _swingAngle += _swingAngVel * dt;

        // Prevent full rotation — cap arc to ±126°
        _swingAngle = _swingAngle.clamp(-pi * 0.70, pi * 0.70);

        // Compute player world position from pendulum state
        position.x = _swingAnchor!.x + sin(_swingAngle) * _ropeLength;
        position.y = _swingAnchor!.y + cos(_swingAngle) * _ropeLength;

        // Update the rope visual to track current hang point
        currentVerticalWeb?.playerConnectWorld
            .setFrom(position - Vector2(0, size.y / 2));
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlatformBlock) {
      if (intersectionPoints.isEmpty) {
        super.onCollision(intersectionPoints, other);
        return;
      }

      // Compute overlap centre to determine collision normal
      final Vector2 overlapCentre =
          intersectionPoints.reduce((a, b) => a + b) / intersectionPoints.length.toDouble();

      final double myLeft   = position.x - size.x / 2;
      final double myRight  = position.x + size.x / 2;
      final double myTop    = position.y - size.y / 2;
      final double myBottom = position.y + size.y / 2;

      final double platLeft  = other.position.x;
      final double platRight = other.position.x + other.size.x;
      final double platTop   = other.position.y;

      // --- Top collision (landing) ---
      // Use actual _lastDt instead of hardcoded 0.016 to avoid tunneling at low fps
      final double prevBottom = myBottom - verticalVelocity * _lastDt;
      if (verticalVelocity >= 0 && prevBottom <= platTop + 24) {
        position.y = platTop - size.y / 2; // No +1 offset — clean surface snap
        verticalVelocity = 0;
        isGrounded = true;
        super.onCollision(intersectionPoints, other);
        return;
      }

      // --- Ceiling collision (head-bump) ---
      final double platBottom = other.position.y + other.size.y;
      final double prevTop = myTop - verticalVelocity * _lastDt;
      if (verticalVelocity < 0 && prevTop >= platBottom - 16) {
        position.y = platBottom + size.y / 2;
        verticalVelocity = 0; // Kill upward momentum so jump doesn't stick
        super.onCollision(intersectionPoints, other);
        return;
      }

      // --- Side collisions (wall push-out) ---
      if (overlapCentre.x < position.x && myLeft < platRight) {
        // Hit from the right side of the platform — push player right
        position.x = platRight + size.x / 2;
        horizontalVelocity = 0;
      } else if (overlapCentre.x > position.x && myRight > platLeft) {
        // Hit from the left side of the platform — push player left
        position.x = platLeft - size.x / 2;
        horizontalVelocity = 0;
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  /// Called when the jump button is pressed down.
  void onJumpPressed() {
    _jumpHeld = true;
    if (isHanging) {
      // #5 — Release from pendulum at natural tangential velocity
      _releaseFromSwing(speedMultiplier: 1.0);
      return;
    }
    if (isGrounded || _coyoteTimer > 0) {
      _executeJump();
    } else {
      // #2 — Buffer the jump so it fires on the next landing
      _jumpBufferTimer = _jumpBufferTime;
    }
  }

  /// Called when the jump button is released — enables variable jump height.
  void onJumpReleased() {
    _jumpHeld = false;
    // #3 — Cut the arc short if still rising
    if (verticalVelocity < 0) {
      verticalVelocity *= 0.45;
    }
  }

  /// Executes the jump impulse and resets coyote window.
  void _executeJump() {
    verticalVelocity = GameConstants.jumpForce;
    isGrounded = false;
    _coyoteTimer = 0;
    AudioService.playJump();
  }

  // Legacy alias kept for any existing call-sites.
  void jump() => onJumpPressed();

  void triggerSwing() {
    if (isHanging) {
      // #5 — Release with 1.5× amplified pendulum velocity for a powerful launch
      _releaseFromSwing(speedMultiplier: 1.5);

      // Keep the swinging animation state for visual flair
      isSwinging = true;
      swingTimer = 0.40;

      AudioService.playJump();
    }
  }

  /// Detaches from the pendulum and converts angular velocity into linear
  /// velocity (v = ω × r, tangent to the arc).
  ///
  /// [speedMultiplier] scales the release speed (1.0 = natural, 1.5 = boosted).
  void _releaseFromSwing({double speedMultiplier = 1.0}) {
    isHanging = false;
    currentVerticalWeb?.removeFromParent();
    currentVerticalWeb = null;

    if (_swingAnchor != null) {
      // Tangential velocity: v_x = ω·r·cos(θ),  v_y = −ω·r·sin(θ)
      horizontalVelocity =
          _ropeLength * _swingAngVel * cos(_swingAngle) * speedMultiplier;
      verticalVelocity =
          -_ropeLength * _swingAngVel * sin(_swingAngle) * speedMultiplier;

      // Guarantee a minimum horizontal push so the player doesn't drop straight down
      if (horizontalVelocity.abs() < 60) {
        horizontalVelocity = isFacingRight ? 180.0 : -180.0;
      }
      _swingAnchor = null;
    } else {
      // Fallback (should never happen)
      verticalVelocity = GameConstants.jumpForce * 0.5;
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
    // Velocity now decays via friction — no hard reset here
  }

  // Lerp helper: moves [current] toward [target] by at most [maxDelta] per step.
  double _moveToward(double current, double target, double maxDelta) {
    final diff = target - current;
    if (diff.abs() <= maxDelta) return target;
    return current + (diff > 0 ? maxDelta : -maxDelta);
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

      // #5 — Initialise pendulum anchor 'ropeLength' pixels above the player
      _ropeLength = GameConstants.ropeLength;
      _swingAnchor = Vector2(position.x, position.y - size.y / 2 - _ropeLength);

      // Seed angular velocity from current horizontal momentum for a natural feel
      _swingAngVel = horizontalVelocity.abs() > 20
          ? horizontalVelocity / _ropeLength
          : (isFacingRight ? 1.8 : -1.8);
      _swingAngle = 0.0; // Start straight below anchor

      currentVerticalWeb = VerticalWeb(anchorWorld: _swingAnchor!);
      currentVerticalWeb!.playerConnectWorld
          .setFrom(position - Vector2(0, size.y / 2));
      game.world.add(currentVerticalWeb!);
      AudioService.playWebShot();
    }
  }

  void hit() {
    game.gameState.takeDamage();
    isHurt = true;
    hurtTimer = 0.45; // About 3 frames at 0.15s each
    AudioService.playHit();
    
    // Spawn comic hit text for player damage!
    final hitWords = ['OOF!', 'UGH!', 'ARGH!', 'OUCH!', 'YIKES!', 'CRACK!'];
    final word = hitWords[Random().nextInt(hitWords.length)];
    game.world.add(HitTextComponent(text: word, position: position.clone()));

    if (game.gameState.lives <= 0) {
      AudioService.playGameOver();
    }
  }
}
