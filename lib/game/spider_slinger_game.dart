import 'package:flame/game.dart';
import 'state/game_state.dart';
import 'components/player/player_component.dart';
import 'components/environment/parallax_bg.dart';
import 'components/environment/platform_block.dart';
import 'components/managers/difficulty_manager.dart';
import 'components/managers/spawner_manager.dart';

class SpiderSlingerGame extends FlameGame with HasCollisionDetection {
  final GameState gameState;
  late PlayerComponent _player;

  SpiderSlingerGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();

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

    // Floor
    add(PlatformBlock(
      position: Vector2(0, size.y - 100),
      size: Vector2(size.x, 100),
    ));

    // Finish Line
    // Placed far to the right, will move towards player if we move the world or player moves.
    // For simplicity, we could make it spawn based on time or distance.
    // Let's spawn it at a specific time in DifficultyManager later.
  }

  void jump() {
    _player.jump();
  }

  void shootHorizontalWeb() {
    _player.shootHorizontalWeb();
  }

  void shootVerticalWeb() {
    _player.shootVerticalWeb();
  }
}
