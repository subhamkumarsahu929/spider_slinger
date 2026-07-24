class UserScoreModel {
  final String userId;
  final int score;
  final int attempts;
  final DateTime timestamp;

  UserScoreModel({
    required this.userId,
    required this.score,
    required this.attempts,
    required this.timestamp,
  });
}
