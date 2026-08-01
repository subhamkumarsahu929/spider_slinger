import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../spider_slinger_game.dart';

class HitTextComponent extends PositionComponent with HasGameReference<SpiderSlingerGame> {
  final String text;
  final double duration;
  double _elapsed = 0.0;
  late final TextComponent _textComponent;
  late final TextComponent _outlineComponent;
  
  final Random _random = Random();
  late Vector2 _velocity;

  HitTextComponent({
    required this.text,
    required Vector2 position,
    this.duration = 0.6,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Random upward angle
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * 1.0; 
    final speed = 100.0 + _random.nextDouble() * 50.0;
    _velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
    
    // Choose red or yellow randomly for comic effect
    final color = _random.nextBool() ? const Color(0xFFE23636) : const Color(0xFFF5D300);

    // Thick black outline
    _outlineComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: GoogleFonts.bangers(
          fontSize: 32,
          color: Colors.black,
          letterSpacing: 2.0,
        ).copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0
            ..color = Colors.black,
        ),
      ),
      anchor: Anchor.center,
    );

    // Inner filled text
    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: GoogleFonts.bangers(
          fontSize: 32,
          color: color,
          letterSpacing: 2.0,
        ),
      ),
      anchor: Anchor.center,
    );

    // Random rotation for punchy effect
    final rot = (_random.nextDouble() - 0.5) * 0.4;
    _outlineComponent.angle = rot;
    _textComponent.angle = rot;

    add(_outlineComponent);
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    
    // Float upwards
    position.add(_velocity * dt);
    
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
