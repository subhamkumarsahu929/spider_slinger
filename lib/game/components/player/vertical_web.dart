import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Renders a web rope from a fixed ceiling anchor to a dynamic player hang-point.
///
/// The component sits at [anchorWorld] in world space (top of rope / ceiling
/// attachment). Every frame the owning [PlayerComponent] must update
/// [playerConnectWorld] to the current bottom-connection point so the line
/// tracks the pendulum arc correctly.
class VerticalWeb extends PositionComponent {
  final Vector2 anchorWorld;

  /// Bottom end of the rope — updated each frame by PlayerComponent.
  Vector2 playerConnectWorld;

  VerticalWeb({required this.anchorWorld})
      : playerConnectWorld = anchorWorld.clone(),
        super(position: anchorWorld.clone(), size: Vector2.zero(), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    // Rope endpoint in local space (component sits at anchorWorld)
    final Offset end = Offset(
      playerConnectWorld.x - anchorWorld.x,
      playerConnectWorld.y - anchorWorld.y,
    );

    // Rope line
    canvas.drawLine(
      Offset.zero,
      end,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );

    // Small anchor circle at the ceiling attachment point
    canvas.drawCircle(
      Offset.zero,
      5.0,
      Paint()..color = Colors.white70,
    );
  }
}
