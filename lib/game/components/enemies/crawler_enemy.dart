import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';

class CrawlerEnemy extends Enemy {
  CrawlerEnemy({required double speed}) 
      : super(type: EnemyType.crawler, speed: speed, size: Vector2(48, 32));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    try {
      sprite = await gameRef.loadSprite('crawler.png');
    } catch (e) {
      // Fallback
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      canvas.drawRect(size.toRect(), Paint()..color = Colors.brown);
    } else {
      super.render(canvas);
    }
  }
}
