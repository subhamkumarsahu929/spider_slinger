import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart';

enum CrawlerType { little, tall }

class CrawlerEnemy extends Enemy {
  final CrawlerType crawlerType;

  CrawlerEnemy({
    required super.speed,
    this.crawlerType = CrawlerType.little,
    super.patrolMinX,
    super.patrolMaxX,
  }) : super(
          type: EnemyType.crawler,
          size: crawlerType == CrawlerType.little ? Vector2(48, 48) : Vector2(48, 48),
        );

  @override
  Future<void> onLoad() async {
    useGravity = true;

    final String prefix = crawlerType == CrawlerType.little ? 'Little-Enemy' : 'Tall-Enemy';
    
    SpriteAnimation createAnim(String action, int frames, {bool loop = true}) {
      return SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/$prefix/$prefix-$action-Sheet.png'),
        SpriteAnimationData.sequenced(
          amount: frames,
          stepTime: 0.15,
          textureSize: Vector2(48, 48),
          loop: loop,
        ),
      );
    }

    animations = {
      EnemyState.idle: createAnim('Idle', 4),
      EnemyState.walk: createAnim('Walk', 4),
      EnemyState.attack: createAnim('Attack', 4),
      EnemyState.hit: createAnim('Hit', 4, loop: false),
      EnemyState.death: createAnim('Death', 4, loop: false),
    };

    current = EnemyState.walk;
    
    add(RectangleHitbox(size: Vector2(36, 36), position: Vector2(6, 12)));
  }
}
