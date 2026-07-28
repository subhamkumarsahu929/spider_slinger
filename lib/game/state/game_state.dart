import 'package:flutter/foundation.dart';
import '../../config/game_constants.dart';
import '../../models/app_user_model.dart';
import '../../models/user_score_model.dart';
import '../../services/score_repository.dart';

class GameState extends ChangeNotifier {
  int _score = 0;
  int _lives = GameConstants.maxLives;
  bool _isGameOver = false;
  bool _isInvulnerable = false;
  AppUser? _currentUser;
  final ScoreRepository _scoreRepository = ScoreRepository();
  int _attempts = 0;

  int get score => _score;
  int get lives => _lives;
  bool get isGameOver => _isGameOver;
  bool get isInvulnerable => _isInvulnerable;
  AppUser? get currentUser => _currentUser;

  void setUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  void addScore(int points) {
    if (_isGameOver) return;
    _score += points;
    notifyListeners();
  }

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

  void resetGame() {
    _score = 0;
    _lives = GameConstants.maxLives;
    _isGameOver = false;
    _isInvulnerable = false;
    _attempts++;
    notifyListeners();
  }

  void triggerWin() {
    if (_isGameOver) return;
    addScore(GameConstants.scoreFinish);
    addScore(_lives * GameConstants.scorePerLife);
    _triggerGameOver();
  }

  Future<void> _triggerGameOver() async {
    _isGameOver = true;
    notifyListeners();

    if (_currentUser != null) {
      final finalScore = UserScore(
        userId: _currentUser!.uid,
        score: _score,
        attempts: _attempts,
        timestamp: DateTime.now(),
      );
      await _scoreRepository.submitScore(finalScore);
    }
  }

  void _triggerInvulnerability() {
    _isInvulnerable = true;
    notifyListeners();
    Future.delayed(
      Duration(milliseconds: (GameConstants.invulnerabilityDuration * 1000).toInt()),
      () {
        _isInvulnerable = false;
        notifyListeners();
      },
    );
  }
}
