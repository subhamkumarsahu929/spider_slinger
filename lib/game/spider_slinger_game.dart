import 'package:flame/game.dart';
import 'state/game_state.dart';
import 'components/player/player_component.dart';
import 'components/environment/skyline_background.dart';
import 'components/managers/difficulty_manager.dart';
import 'components/managers/procedural_spawner.dart';
import 'components/managers/spawner_manager.dart';

class SpiderSlingerGame extends FlameGame with HasCollisionDetection {
  final GameState gameState;
  late PlayerComponent _player;

  SpiderSlingerGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Pre-cache enemy and environment assets
    await images.loadAll([
      'enemies/Little-Enemy/Little-Enemy-Idle-Sheet.png',
      'enemies/Little-Enemy/Little-Enemy-Walk-Sheet.png',
      'enemies/Little-Enemy/Little-Enemy-Attack-Sheet.png',
      'enemies/Little-Enemy/Little-Enemy-Hit-Sheet.png',
      'enemies/Little-Enemy/Little-Enemy-Death-Sheet.png',
      'enemies/Tall-Enemy/Tall-Enemy-Idle-Sheet.png',
      'enemies/Tall-Enemy/Tall-Enemy-Walk-Sheet.png',
      'enemies/Tall-Enemy/Tall-Enemy-Attack-Sheet.png',
      'enemies/Tall-Enemy/Tall-Enemy-Hit-Sheet.png',
      'enemies/Tall-Enemy/Tall-Enemy-Death-Sheet.png',
      'enemies/Fly-Enemy/Fly-Enemy-Idle-Sheet.png',
      'enemies/Fly-Enemy/Fly-Enemy-Attack-Sheet.png',
      'enemies/Fly-Enemy/Fly-Enemy-Hit-Sheet.png',
      'enemies/Fly-Enemy/Fly-Enemy-Death-Sheet.png',
      'enemies/Venom.png',
      'environment/platform-template.png',
      for (final i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14]) 'buildings/build_day_$i.png',
      for (final i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14]) 'buildings/build_night_$i.png',
    ]);

    // Background Skyline
    add(SkylineBackground());

    // Managers
    final difficultyManager = DifficultyManager();
    add(difficultyManager); // Managers can stay on game root
    add(SpawnerManager(difficultyManager: difficultyManager));
    add(ProceduralSpawner());

    // Player
    _player = PlayerComponent()
      ..position = Vector2(100, size.y - 200);
    world.add(_player);

    camera.follow(_player);
  }

  void jump() {
    _player.jump();
  }

  void startMovingLeft() {
    _player.moveLeft();
  }

  void startMovingRight() {
    _player.moveRight();
  }

  void stopMoving() {
    _player.stopMoving();
  }

  void shootHorizontalWeb() {
    _player.shootHorizontalWeb();
  }

  void shootVerticalWeb() {
    _player.shootVerticalWeb();
  }

  void triggerSwing() {
    _player.triggerSwing();
  }
}
