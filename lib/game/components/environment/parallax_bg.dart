import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';

class ParallaxBg extends ParallaxComponent<SpiderSlingerGame> {
  final double speed;

  ParallaxBg({this.speed = 50.0});

  @override
  Future<void> onLoad() async {
    try {
      parallax = await game.loadParallax(
        [
          ParallaxImageData('background.png'),
        ],
        baseVelocity: Vector2(speed, 0),
        velocityMultiplierDelta: Vector2(1.5, 1.0),
      );
    } catch (e) {
      // Fallback if no assets
    }
  }

  @override
  void render(Canvas canvas) {
    if (parallax == null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, game.size.x, game.size.y),
        Paint()..color = Colors.lightBlue.shade100,
      );
    } else {
      super.render(canvas);
    }
  }
}
