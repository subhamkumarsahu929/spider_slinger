import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../spider_slinger_game.dart';

enum TileTheme { blue, purple }
enum PlatformType { groundBlock, thinLedgeLeft, thinLedgeMid, thinLedgeRight, dripLedge }

class PlatformBlock extends SpriteComponent with HasGameReference<SpiderSlingerGame>, CollisionCallbacks {
  final TileTheme theme;
  final PlatformType platformType;

  PlatformBlock({
    required Vector2 position,
    this.theme = TileTheme.blue,
    this.platformType = PlatformType.groundBlock,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    Vector2 srcPos = Vector2.zero();
    Vector2 srcSz = Vector2.zero();

    if (theme == TileTheme.blue) {
      switch (platformType) {
        case PlatformType.groundBlock:
          srcPos = Vector2(0, 0); srcSz = Vector2(32, 32); break;
        case PlatformType.thinLedgeLeft:
          srcPos = Vector2(48, 48); srcSz = Vector2(16, 16); break;
        case PlatformType.thinLedgeMid:
          srcPos = Vector2(64, 48); srcSz = Vector2(32, 16); break;
        case PlatformType.thinLedgeRight:
          srcPos = Vector2(96, 48); srcSz = Vector2(16, 16); break;
        case PlatformType.dripLedge:
          srcPos = Vector2(112, 32); srcSz = Vector2(48, 16); break;
      }
    } else {
      switch (platformType) {
        case PlatformType.groundBlock:
          srcPos = Vector2(0, 64); srcSz = Vector2(32, 32); break;
        case PlatformType.thinLedgeLeft:
          srcPos = Vector2(48, 112); srcSz = Vector2(16, 16); break;
        case PlatformType.thinLedgeMid:
          srcPos = Vector2(64, 112); srcSz = Vector2(32, 16); break;
        case PlatformType.thinLedgeRight:
          srcPos = Vector2(96, 112); srcSz = Vector2(16, 16); break;
        case PlatformType.dripLedge:
          srcPos = Vector2(112, 96); srcSz = Vector2(48, 16); break;
      }
    }

    size = srcSz.clone();
    sprite = await Sprite.load(
      'environment/platform-template.png',
      srcPosition: srcPos,
      srcSize: srcSz,
    );
    
    // Make ground solid
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Cleanup when off-screen to the left
    if (position.x + size.x < game.camera.viewfinder.position.x - game.size.x / 2 - 200) {
      removeFromParent();
    }
  }
}
