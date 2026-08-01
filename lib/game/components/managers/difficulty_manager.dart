import 'package:flame/components.dart';
import '../../../config/game_constants.dart';
import '../../spider_slinger_game.dart';

class DifficultyManager extends Component with HasGameReference<SpiderSlingerGame> {
  double _gameTime = 0;
  
  int get currentPhase {
    if (_gameTime < GameConstants.phase1Duration) return 1;
    if (_gameTime < GameConstants.phase2Duration) return 2;
    return 3;
  }

  double get spawnRate {
    switch (currentPhase) {
      case 1:
        return 3.0; // Seconds between spawns
      case 2:
        return 2.0;
      case 3:
      default:
        return 1.0;
    }
  }

  double get enemySpeedMultiplier {
    switch (currentPhase) {
      case 1:
        return 1.0;
      case 2:
        return 1.5;
      case 3:
      default:
        return 2.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.gameState.isGameOver) {
      _gameTime += dt;
    }
  }
}
