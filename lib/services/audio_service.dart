import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import '../config/assets.dart';

class AudioService {
  static bool _soundEnabled = true;
  // Set to true once you add physical audio files to assets/audio/ and update pubspec.yaml
  static const bool _useAudio = false;

  static Future<void> initialize() async {
    if (!_useAudio) return;
    try {
      await FlameAudio.audioCache.loadAll([
        AppAssets.webShotAudio,
        AppAssets.jumpAudio,
        AppAssets.gameOverAudio,
        AppAssets.hitAudio,
      ]);
    } catch (e) {
      debugPrint('[AudioService] Failed to load audio assets: $e');
    }
  }

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static void playWebShot() {
    if (!_useAudio || !_soundEnabled) return;
    try {
      FlameAudio.play(AppAssets.webShotAudio);
    } catch (e) {
      debugPrint('[AudioService] Failed to play web shot sound: $e');
    }
  }

  static void playJump() {
    if (!_useAudio || !_soundEnabled) return;
    try {
      FlameAudio.play(AppAssets.jumpAudio);
    } catch (e) {
      debugPrint('[AudioService] Failed to play jump sound: $e');
    }
  }

  static void playHit() {
    if (!_useAudio || !_soundEnabled) return;
    try {
      FlameAudio.play(AppAssets.hitAudio);
    } catch (e) {
      debugPrint('[AudioService] Failed to play hit sound: $e');
    }
  }

  static void playGameOver() {
    if (!_useAudio || !_soundEnabled) return;
    try {
      FlameAudio.play(AppAssets.gameOverAudio);
    } catch (e) {
      debugPrint('[AudioService] Failed to play game over sound: $e');
    }
  }
}
