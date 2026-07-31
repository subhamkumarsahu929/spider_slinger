import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart';

enum CrawlerType { little, tall }

class CrawlerEnemy extends Enemy {
  final CrawlerType crawlerType;

  CrawlerEnemy({required double speed, required this.crawlerType}) 
      : super(type: EnemyType.crawler, speed: speed, size: Vector2(48, 32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());

    final String prefix = crawlerType == CrawlerType.little ? 'enemies/Little-Enemy/Little-Enemy' : 'enemies/Tall-Enemy/Tall-Enemy';

    // Assumed amounts (4 for animation loops, 2 for hit, 4 for death)
    // Adjust 'amount' if the sprite strips have a different number of frames.
    animations = {
      EnemyState.idle: createAnim('$prefix-Idle-Sheet.png', amount: 4),
      EnemyState.walk: createAnim('$prefix-Walk-Sheet.png', amount: 4),
      EnemyState.attack: createAnim('$prefix-Attack-Sheet.png', amount: 4),
      EnemyState.hit: createAnim('$prefix-Hit-Sheet.png', amount: 2, loop: false),
      EnemyState.death: createAnim('$prefix-Death-Sheet.png', amount: 4, loop: false),
    };

    current = EnemyState.walk;
  }
}
