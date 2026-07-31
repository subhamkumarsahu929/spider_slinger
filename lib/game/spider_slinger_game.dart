import 'package:flame/game.dart';
import 'state/game_state.dart';
import 'components/player/player_component.dart';
import 'components/environment/parallax_bg.dart';
import 'components/environment/platform_block.dart';
import 'components/managers/difficulty_manager.dart';
import 'components/managers/spawner_manager.dart';
import '../config/game_constants.dart';

class SpiderSlingerGame extends FlameGame with HasCollisionDetection {
  final GameState gameState;
  late PlayerComponent _player;

  SpiderSlingerGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Pre-cache enemy assets
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
    ]);

    // Background
    add(ParallaxBg());

    // Managers
    final difficultyManager = DifficultyManager();
    add(difficultyManager);
    add(SpawnerManager(difficultyManager: difficultyManager));

    // Player
    _player = PlayerComponent()
      ..position = Vector2(100, size.y - 200);
    add(_player);

    // Floor - Make it much wider since the player can move!
    add(PlatformBlock(
      position: Vector2(-5000, size.y - 100),
      size: Vector2(10000, 100),
    ));

    camera.follow(_player);
  }

  void jump() {
    _player.jump();
  }

  void startMovingLeft() {
    _player.horizontalVelocity = -GameConstants.playerSpeed;
  }

  void startMovingRight() {
    _player.horizontalVelocity = GameConstants.playerSpeed;
  }

  void stopMoving() {
    _player.horizontalVelocity = 0;
  }

  void shootHorizontalWeb() {
    _player.shootHorizontalWeb();
  }

  void shootVerticalWeb() {
    _player.shootVerticalWeb();
  }
}
