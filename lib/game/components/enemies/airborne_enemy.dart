import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import 'dart:math';

class AirborneEnemy extends Enemy {
  double _time = 0;
  final double hoverAmplitude = 30.0;
  final double hoverFrequency = 3.0;
  final double initialY;

  AirborneEnemy({required double speed, required this.initialY}) 
      : super(type: EnemyType.airborne, speed: speed, size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    try {
      sprite = await gameRef.loadSprite('airborne.png');
    } catch (e) {
      // Fallback
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameState.isGameOver) return;
    
    _time += dt;
    position.y = initialY + sin(_time * hoverFrequency) * hoverAmplitude;
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      canvas.drawRect(size.toRect(), Paint()..color = Colors.purple);
    } else {
      super.render(canvas);
    }
  }
}
