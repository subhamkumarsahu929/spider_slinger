import 'package:cloud_firestore/cloud_firestore.dart'; // for Timestamp

// UserScore is a plain Dart object — no Firebase imports needed at the model level
// (except Timestamp for reading back Firestore data).
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

  // ── toMap ──────────────────────────────────────────────────────────────────
  // Converts to a Map for Firestore. Note: 'timestamp' is intentionally
  // omitted here — ScoreRepository overrides it with FieldValue.serverTimestamp()
  // using the spread operator ({...score.toMap(), 'timestamp': ...}).
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'score': score,
      'attempts': attempts,
      // Written as ISO string here, but overridden by serverTimestamp() in ScoreRepository.
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // ── fromMap ────────────────────────────────────────────────────────────────
  // Reads a Firestore document back into a UserScore.
  // The timestamp field can come back as either:
  //   • a Firestore Timestamp object (when reading a freshly written doc)
  //   • a String (from older documents written before serverTimestamp)
  // We handle both cases here.
  factory UserScore.fromMap(Map<String, dynamic> map) {
    DateTime parsedTime;
    final rawTime = map['timestamp'];
    if (rawTime is Timestamp) {
      // The standard case — Firestore Timestamp from the server.
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      // Fallback for any older documents stored with ISO string.
      parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      // If null or unknown type, default to now.
      parsedTime = DateTime.now();
    }

    return UserScore(
      userId: map['userId'] ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      timestamp: parsedTime,
    );
  }
}

