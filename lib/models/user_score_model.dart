class UserScore {
  final String userId;
  final int score;
  final int attempts;
  final DateTime timestamp;

  UserScore({
    required this.userId,
    required this.score,
    required this.attempts,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'score': score,
      'attempts': attempts,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserScore.fromMap(Map<String, dynamic> map) {
    return UserScore(
      userId: map['userId'] ?? '',
      score: map['score']?.toInt() ?? 0,
      attempts: map['attempts']?.toInt() ?? 0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
