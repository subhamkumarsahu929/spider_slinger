import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart';
import 'dart:math';

class AirborneEnemy extends Enemy {
  double _time = 0;
  final double hoverAmplitude = 30.0;
  final double hoverFrequency = 3.0;
  final double initialY;

  AirborneEnemy({
    required super.speed,
    required this.initialY,
    super.patrolMinX,
    super.patrolMaxX,
  }) : super(
          type: EnemyType.airborne,
          size: Vector2(48, 48),
        );

  @override
  Future<void> onLoad() async {
    SpriteAnimation createAnim(String action, int frames, {bool loop = true}) {
      return SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/Fly-Enemy/Fly-Enemy-$action-Sheet.png'),
        SpriteAnimationData.sequenced(
          amount: frames,
          stepTime: 0.15,
          textureSize: Vector2(48, 48),
          loop: loop,
        ),
      );
    }

    animations = {
      EnemyState.idle: createAnim('Idle', 5),
      EnemyState.walk: createAnim('Idle', 5), // No walk sheet for fly
      EnemyState.attack: createAnim('Attack', 4),
      EnemyState.hit: createAnim('Hit', 4, loop: false),
      EnemyState.death: createAnim('Death', 4, loop: false),
    };

    current = EnemyState.walk;
    add(CircleHitbox(radius: 16, position: Vector2(8, 8)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver) return;
    
    // Hovering sine wave
    if (current != EnemyState.hit && current != EnemyState.death) {
      _time += dt;
      position.y = initialY + sin(_time * hoverFrequency) * hoverAmplitude;
    }
  }
}
