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

  AirborneEnemy({required super.speed, required this.initialY}) 
      : super(type: EnemyType.airborne, size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Tighten hitbox (Sprite is 80x80, real visual is ~40x40 centered)
    add(CircleHitbox(radius: 20, position: Vector2(20, 20)));

    const String prefix = 'enemies/Fly-Enemy/Fly-Enemy';

    // Assumed amounts. Adjust if your sprite sheets differ.
    animations = {
      EnemyState.idle:   createAnim('$prefix-Idle-Sheet.png', amount: 4),
      EnemyState.walk:   createAnim('$prefix-Idle-Sheet.png', amount: 4), // Airborne — no walk sheet; mirrors idle
      EnemyState.attack: createAnim('$prefix-Attack-Sheet.png', amount: 4),
      EnemyState.hit:    createAnim('$prefix-Hit-Sheet.png', amount: 2, loop: false),
      EnemyState.death:  createAnim('$prefix-Death-Sheet.png', amount: 4, loop: false),
    };

    // Tint Cyan
    paint.colorFilter = const ColorFilter.mode(Color(0xFF26E0FF), BlendMode.srcIn);

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
