import 'dart:math';
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

  // Camera shake state (#13)
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  final Random _shakeRandom = Random();

  SpiderSlingerGame({required this.gameState});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Pre-cache enemy and environment assets (only once — stays in cache on reset)
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

    _initWorld();
  }

  /// Initialises all gameplay objects (player, managers, background).
  /// Safe to call repeatedly — does NOT reload assets.
  void _initWorld() {
    add(SkylineBackground());

    final difficultyManager = DifficultyManager();
    add(difficultyManager);
    add(SpawnerManager(difficultyManager: difficultyManager));
    add(ProceduralSpawner());

    _player = PlayerComponent()
      ..position = Vector2(100, size.y - 200);
    world.add(_player);

    camera.follow(_player);
    
    // Pause the engine immediately so the game doesn't run in the background
    // while the splash screen or main menu is active.
    pauseEngine();
  }

  /// Tears down the live world and reinitialises it cleanly.
  /// Call this when returning to the main menu so the next game starts fresh.
  /// Fixes: #4 (dirty world on retry) and #9 (DifficultyManager time persists).
  void resetWorld() {
    // 1. Clear all in-world objects (player, enemies, platforms, webs)
    world.removeAll(world.children.toList());

    // 2. Remove game-root managed components
    final toRemove = children.where((c) =>
      c is SkylineBackground ||
      c is DifficultyManager ||
      c is SpawnerManager ||
      c is ProceduralSpawner,
    ).toList();
    removeAll(toRemove);

    // 3. Clear any leftover shake state
    _shakeTimer = 0;

    // 4. Make sure engine is running before reinitialising
    resumeEngine();

    // 5. Rebuild world with fresh components (#9 — new DifficultyManager starts at t=0)
    _initWorld();
  }

  /// Triggers a brief camera shake — call from boss hit, void death, etc. (#13)
  void cameraShake({double duration = 0.25, double intensity = 8.0}) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  @override
  void update(double dt) {
    super.update(dt); // Camera follow runs inside super
    // Apply shake offset ON TOP of follow result so it's always visible (#13)
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      camera.viewfinder.position += Vector2(
        (_shakeRandom.nextDouble() - 0.5) * _shakeIntensity * 2,
        (_shakeRandom.nextDouble() - 0.5) * _shakeIntensity * 2,
      );
    }
  }

  // ── Player action forwarding ─────────────────────────────────────────────
  void jump()              => _player.onJumpPressed();
  void onJumpReleased()    => _player.onJumpReleased();
  void startMovingLeft()   => _player.moveLeft();
  void startMovingRight()  => _player.moveRight();
  void stopMoving()        => _player.stopMoving();
  void shootHorizontalWeb() => _player.shootHorizontalWeb();
  void shootVerticalWeb()  => _player.shootVerticalWeb();
  void triggerSwing()      => _player.triggerSwing();
}
