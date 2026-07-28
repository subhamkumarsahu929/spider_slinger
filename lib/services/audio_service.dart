import 'package:flame_audio/flame_audio.dart';
import '../config/assets.dart';

class AudioService {
  static bool _soundEnabled = true;

  static Future<void> initialize() async {
    await FlameAudio.audioCache.loadAll([
      AppAssets.webShotAudio,
      AppAssets.jumpAudio,
      AppAssets.gameOverAudio,
      AppAssets.hitAudio,
    ]);
  }

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static void playWebShot() {
    if (_soundEnabled) {
      FlameAudio.play(AppAssets.webShotAudio);
    }
  }

  static void playJump() {
    if (_soundEnabled) {
      FlameAudio.play(AppAssets.jumpAudio);
    }
  }

  static void playHit() {
    if (_soundEnabled) {
      FlameAudio.play(AppAssets.hitAudio);
    }
  }

  static void playGameOver() {
    if (_soundEnabled) {
      FlameAudio.play(AppAssets.gameOverAudio);
    }
  }
}
