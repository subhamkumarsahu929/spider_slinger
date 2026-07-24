import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  int lives = 3;
  int score = 0;
  bool isAuthenticated = false;

  void increaseScore(int amount) {
    score += amount;
    notifyListeners();
  }

  void loseLife() {
    if (lives > 0) {
      lives -= 1;
    }
    notifyListeners();
  }
}
