import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../spider_slinger_game.dart';

class VerticalWeb extends PositionComponent with HasGameRef<SpiderSlingerGame> {
  VerticalWeb({required Vector2 position}) : super(position: position, size: Vector2(4, 500), anchor: Anchor.bottomCenter);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = Colors.white);
  }

}
