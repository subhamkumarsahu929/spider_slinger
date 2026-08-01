import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';
import 'platform_block.dart';
import '../player/player_component.dart';

enum SpikeDirection { up, down, left, right }

class HazardBlock extends SpriteComponent with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  final TileTheme theme;
  final SpikeDirection direction;

  HazardBlock({
    required Vector2 position,
    this.theme = TileTheme.blue,
    this.direction = SpikeDirection.up,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    Vector2 srcPos = Vector2.zero();
    Vector2 srcSz = Vector2(16, 16);

    if (theme == TileTheme.blue) {
      switch (direction) {
        case SpikeDirection.up: srcPos = Vector2(48, 32); break;
        case SpikeDirection.down: srcPos = Vector2(64, 32); break;
        case SpikeDirection.left: srcPos = Vector2(80, 32); break;
        case SpikeDirection.right: srcPos = Vector2(96, 32); break;
      }
    } else {
      switch (direction) {
        case SpikeDirection.up: srcPos = Vector2(48, 96); break;
        case SpikeDirection.down: srcPos = Vector2(64, 96); break;
        case SpikeDirection.left: srcPos = Vector2(80, 96); break;
        case SpikeDirection.right: srcPos = Vector2(96, 96); break;
      }
    }

    size = srcSz.clone();
    sprite = await Sprite.load(
      'environment/platform-template.png',
      srcPosition: srcPos,
      srcSize: srcSz,
    );
    
    // Add hitbox for damage
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x / 2 - 200) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      if (!game.gameState.isInvulnerable) {
        other.hit();
      }
    }
  }
}
