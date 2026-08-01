import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart';

enum CrawlerType { little, tall }

class CrawlerEnemy extends Enemy {
  final CrawlerType crawlerType;

  CrawlerEnemy({required super.speed, required this.crawlerType}) 
      : super(type: EnemyType.crawler, size: Vector2(96, 64));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    useGravity = true; // #6 — Crawlers should fall and land on platforms
    // Tighten crawler hitbox (Sprite size is 96x64, real visual is smaller)
    add(RectangleHitbox(size: Vector2(60, 40), position: Vector2(18, 24)));

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

    // Tint to match comic aesthetic
    final tint = crawlerType == CrawlerType.little ? const Color(0xFFFF2F92) : const Color(0xFF3A1C8C);
    paint.colorFilter = ColorFilter.mode(tint, BlendMode.srcIn);

    current = EnemyState.walk;
  }
}
