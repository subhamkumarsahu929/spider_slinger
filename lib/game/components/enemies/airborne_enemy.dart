import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart';
import 'dart:math';

class AirborneEnemy extends Enemy {
  double _time = 0;
  final double hoverAmplitude = 30.0;
  final double hoverFrequency = 3.0;
  final double initialY;

  AirborneEnemy({required double speed, required this.initialY}) 
      : super(type: EnemyType.airborne, speed: speed, size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());

    const String prefix = 'enemies/Fly-Enemy/Fly-Enemy';

    // Assumed amounts. Adjust if your sprite sheets differ.
    animations = {
      EnemyState.idle: createAnim('$prefix-Idle-Sheet.png', amount: 4),
      EnemyState.walk: createAnim('$prefix-Idle-Sheet.png', amount: 4), // Fallback walk to idle
      EnemyState.attack: createAnim('$prefix-Attack-Sheet.png', amount: 4),
      EnemyState.hit: createAnim('$prefix-Hit-Sheet.png', amount: 2, loop: false),
      EnemyState.death: createAnim('$prefix-Death-Sheet.png', amount: 4, loop: false),
    };

    current = EnemyState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameState.isGameOver || isDying) return;
    
    _time += dt;
    position.y = initialY + sin(_time * hoverFrequency) * hoverAmplitude;
  }
}
