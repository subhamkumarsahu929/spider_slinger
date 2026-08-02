import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import '../config/assets.dart';

class AudioService {
  static bool _soundEnabled = true;

  // Preloads audio files. Silently ignores missing files so the game
  // doesn't crash when audio assets don't exist yet.
  static Future<void> initialize() async {
    try {
      await FlameAudio.audioCache.loadAll([
        AppAssets.webShotAudio,
        AppAssets.jumpAudio,
        AppAssets.gameOverAudio,
        AppAssets.hitAudio,
      ]);
    } catch (e) {
      debugPrint('[AudioService] initialize: some audio files missing, sounds disabled. $e');
    }
  }

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static void playWebShot() {
    if (_soundEnabled) _play(AppAssets.webShotAudio);
  }

  static void playJump() {
    if (_soundEnabled) _play(AppAssets.jumpAudio);
  }

  static void playHit() {
    if (_soundEnabled) _play(AppAssets.hitAudio);
  }

  static void playGameOver() {
    if (_soundEnabled) _play(AppAssets.gameOverAudio);
  }

  // Internal helper: plays a sound and silently ignores missing-asset errors.
  // Uses async/try-catch instead of .catchError() because catchError requires
  // the handler to return the same type as the Future (AudioPlayer), which
  // we can't do — so the async pattern is cleaner and type-safe.
  static Future<void> _play(String file) async {
    try {
      await FlameAudio.play(file);
    } catch (_) {
      // Audio file not found — game continues without sound.
    }
  }
}
