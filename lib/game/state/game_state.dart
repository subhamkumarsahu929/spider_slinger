import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../../config/game_constants.dart';
import '../../models/app_user_model.dart';
import '../../models/user_score_model.dart';
import '../../services/score_repository.dart';
import '../../services/user_repository.dart'; // ← NEW: user profile storage
import '../../services/audio_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GameState is the single source of truth for all game data.
//
// What it tracks:
//   • score        — current session score
//   • lives        — how many lives remain (max = GameConstants.maxLives)
//   • isGameOver   — true after death or win; blocks further game actions
//   • isInvulnerable — temporary shield after taking damage
//   • currentUser  — the signed-in AppUser (set by AuthService on startup)
//   • attempts     — how many games played this session
//
// What it writes to Firestore on game over:
//   • scores/{auto-id}  — this session's score entry
//   • users/{uid}       — updates bestScore and totalGames
// ─────────────────────────────────────────────────────────────────────────────
class GameState extends ChangeNotifier {
  int _score = 0;
  int _lives = GameConstants.maxLives;
  bool _isGameOver = false;
  bool _isInvulnerable = false;
  double _invulnerabilityTime = 0.0;
  AppUser? _currentUser;
  String? studentName;
  String? rollNumber;
  int _attempts = 0;
  int _loopCount = 0; // Tracks endless progression loops
  
  String currentBossName = 'VENOM';
  String currentBossTaunt = 'WE ARE VENOM';

  // Firebase repositories — both write to Firestore on game over.
  final ScoreRepository _scoreRepository = ScoreRepository();
  final UserRepository _userRepository = UserRepository(); // ← NEW

  // ── Getters ────────────────────────────────────────────────────────────────
  int get score => _score;
  int get lives => _lives;
  bool get isGameOver => _isGameOver;
  bool get isInvulnerable => _isInvulnerable;
  double get invulnerabilityTime => _invulnerabilityTime;
  AppUser? get currentUser => _currentUser;
  int get attempts => _attempts;
  int get loopCount => _loopCount;

  void setUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();

    if (user != null) {
      _userRepository.registerOrUpdateUser(user, studentName, rollNumber);
    }
  }

  void setStudentInfo(String name, String roll) {
    studentName = name;
    rollNumber = roll;
    notifyListeners();
    if (_currentUser != null) {
      _userRepository.registerOrUpdateUser(_currentUser!, studentName, rollNumber);
    }
  }
  
  void setBossInfo(String name, String taunt) {
    currentBossName = name;
    currentBossTaunt = taunt;
    notifyListeners();
  }

  // ── addScore ───────────────────────────────────────────────────────────────
  void addScore(int points) {
    if (_isGameOver) return;
    _score += points;
    notifyListeners();
  }

  // ── takeDamage ─────────────────────────────────────────────────────────────
  void takeDamage() {
    if (_isInvulnerable || _isGameOver) return;

    _lives -= 1;
    if (_lives <= 0) {
      _lives = 0;
      _triggerGameOver();
    } else {
      _isInvulnerable = true;
      _invulnerabilityTime = GameConstants.invulnerabilityDuration;
    }
    notifyListeners();
  }

  // ── resetGame ──────────────────────────────────────────────────────────────
  void resetGame() {
    _score = 0;
    _lives = GameConstants.maxLives;
    _isGameOver = false;
    _isInvulnerable = false;
    _invulnerabilityTime = 0.0;
    _loopCount = 0; // Reset progression
    _attempts++;
    AudioService.playBgm();
    notifyListeners();
  }

  // ── bossDefeated ─────────────────────────────────────────────────────────────
  void bossDefeated() {
    if (_isGameOver) return;
    
    // Reward points for defeating boss based on loop multiplier
    int baseScore = 500;
    int loopMultiplier = 1 + _loopCount;
    addScore(baseScore * loopMultiplier);
    
    // Increment endless progression loop
    _loopCount++;
    notifyListeners();
  }

  // ── _triggerGameOver ───────────────────────────────────────────────────────
  // Fires on both loss (lives = 0) and win.
  // Writes TWO documents to Firestore in parallel:
  //   1. scores/{auto-id} — this session's score entry (leaderboard)
  //   2. users/{uid}      — updates totalGames + bestScore (user profile)
  Future<void> _triggerGameOver() async {
    _isGameOver = true;
    AudioService.stopBgm();
    notifyListeners();

    if (_currentUser != null) {
      final uid = _currentUser!.uid;

      final finalScore = UserScore(
        userId: uid,
        score: _score,
        attempts: _attempts,
        timestamp: DateTime.now(),
      );

      // Run both writes in parallel — no need to wait for one before the other.
      await Future.wait([
        _scoreRepository.submitScore(finalScore),      // → scores collection
        _userRepository.updateAfterGame(uid, _score),  // → users collection
      ]);
    }
  }

  // ── updateInvulnerability ──────────────────────────────────────────────────
  // Ticks down the invulnerability countdown.
  void updateInvulnerability(double dt) {
    if (_isInvulnerable && !_isGameOver) {
      _invulnerabilityTime -= dt;
      if (_invulnerabilityTime <= 0) {
        _invulnerabilityTime = 0.0;
        _isInvulnerable = false;
      }
      notifyListeners();
    }
  }

  bool _notificationScheduled = false;

  @override
  void notifyListeners() {
    if (_notificationScheduled) return;

    final scheduler = WidgetsBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      super.notifyListeners();
    } else if (scheduler.schedulerPhase == SchedulerPhase.idle) {
      _notificationScheduled = true;
      Future.microtask(() {
        _notificationScheduled = false;
        super.notifyListeners();
      });
    } else {
      _notificationScheduled = true;
      scheduler.addPostFrameCallback((_) {
        _notificationScheduled = false;
        super.notifyListeners();
      });
    }
  }
}

