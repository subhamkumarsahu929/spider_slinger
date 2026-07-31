import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import '../models/user_score_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScoreRepository owns all reads/writes to the Firestore 'scores' collection.
//
// Firestore data model:
//   scores/                       ← collection (auto-ID documents)
//     {auto-id}/
//       userId:    "uid-abc123"   ← from Firebase anonymous auth
//       score:     4200           ← final score at game over
//       attempts:  3              ← how many tries this session
//       timestamp: Timestamp      ← server-set time (NOT client clock)
//
// Security rules (set in Firebase Console → Firestore → Rules):
//   allow read:  if true;                    ← anyone can see the leaderboard
//   allow write: if request.auth != null;    ← must be signed in to post a score
// ─────────────────────────────────────────────────────────────────────────────
class ScoreRepository {
  // FirebaseFirestore.instance is a singleton — same pattern as FirebaseAuth.
  // We accept an override for testability.
  final FirebaseFirestore? _firestoreOverride;

  ScoreRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  // ── Submit Score ───────────────────────────────────────────────────────────
  // Called from GameState._triggerGameOver() when the player has a uid.
  // Uses .add() which auto-generates a unique document ID (safer than .set()).
  Future<void> submitScore(UserScore score) async {
    try {
      await _firestore.collection('scores').add({
        ...score.toMap(),
        // FieldValue.serverTimestamp() lets the FIRESTORE SERVER write the time.
        // This is more reliable than the client clock for ordering the leaderboard,
        // because client clocks can be wrong or spoofed.
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('[ScoreRepository] Score submitted for uid: ${score.userId}');
    } on FirebaseException catch (e) {
      // FirebaseException.code will be 'permission-denied' if Firestore rules block it.
      // That means Anonymous Auth is not enabled, or the user isn't signed in.
      debugPrint('[ScoreRepository] submitScore failed: ${e.code} — ${e.message}');
    } catch (e) {
      debugPrint('[ScoreRepository] submitScore unexpected error: $e');
    }
  }

  // ── Get High Scores ────────────────────────────────────────────────────────
  // Returns the top N scores, sorted highest-first.
  // This powers a leaderboard screen if you add one later.
  Future<List<UserScore>> getHighScores({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .orderBy('score', descending: true) // highest score first
          .limit(limit)                        // don't download the whole collection
          .get();

      // Each QueryDocumentSnapshot is one player's score entry.
      return snapshot.docs
          .map((doc) => UserScore.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[ScoreRepository] getHighScores failed: ${e.code} — ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[ScoreRepository] getHighScores unexpected error: $e');
      return [];
    }
  }
}

