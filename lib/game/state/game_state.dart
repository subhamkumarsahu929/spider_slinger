import 'package:flutter/foundation.dart';
import '../../config/game_constants.dart';
import '../../models/app_user_model.dart';
import '../../models/user_score_model.dart';
import '../../services/score_repository.dart';
import '../../services/user_repository.dart'; // ← NEW: user profile storage

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
  AppUser? _currentUser;
  String? studentName;
  String? rollNumber;
  int _attempts = 0;

  // Firebase repositories — both write to Firestore on game over.
  final ScoreRepository _scoreRepository = ScoreRepository();
  final UserRepository _userRepository = UserRepository(); // ← NEW

  // ── Getters ────────────────────────────────────────────────────────────────
  int get score => _score;
  int get lives => _lives;
  bool get isGameOver => _isGameOver;
  bool get isInvulnerable => _isInvulnerable;
  AppUser? get currentUser => _currentUser;
  int get attempts => _attempts;

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
      _triggerInvulnerability();
    }
    notifyListeners();
  }

  // ── resetGame ──────────────────────────────────────────────────────────────
  void resetGame() {
    _score = 0;
    _lives = GameConstants.maxLives;
    _isGameOver = false;
    _isInvulnerable = false;
    _attempts++;
    notifyListeners();
  }

  // ── triggerWin ─────────────────────────────────────────────────────────────
  void triggerWin() {
    if (_isGameOver) return;
    addScore(GameConstants.scoreFinish);
    addScore(_lives * GameConstants.scorePerLife);
    _triggerGameOver();
  }

  // ── _triggerGameOver ───────────────────────────────────────────────────────
  // Fires on both loss (lives = 0) and win.
  // Writes TWO documents to Firestore in parallel:
  //   1. scores/{auto-id} — this session's score entry (leaderboard)
  //   2. users/{uid}      — updates totalGames + bestScore (user profile)
  Future<void> _triggerGameOver() async {
    _isGameOver = true;
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

  // ── _triggerInvulnerability ────────────────────────────────────────────────
  // Gives the player a brief shield after taking damage.
  void _triggerInvulnerability() {
    _isInvulnerable = true;
    notifyListeners();
    Future.delayed(
      Duration(
        milliseconds:
            (GameConstants.invulnerabilityDuration * 1000).toInt(),
      ),
      () {
        _isInvulnerable = false;
        notifyListeners();
      },
    );
  }
}

