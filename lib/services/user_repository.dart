import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserRepository manages the 'users' collection in Firestore.
//
// Firestore data model:
//   users/                        ← collection
//     {uid}/                      ← document ID = Firebase uid (not auto-ID)
//       uid:          "uid-abc"   ← same as document ID for easy lookup
//       isAnonymous:  true
//       displayName:  "Anonymous Player"
//       createdAt:    Timestamp   ← server time of first sign-in
//       lastSeenAt:   Timestamp   ← updated every session
//       totalGames:   5           ← incremented on each game over
//       bestScore:    4200        ← updated when score exceeds current best
//
// Why use uid as the document ID (not auto-ID)?
//   Because each player should have exactly ONE user document.
//   Using uid as the doc ID means .set() is idempotent — calling it twice
//   for the same player just updates the doc instead of creating a duplicate.
// ─────────────────────────────────────────────────────────────────────────────
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Register or Update User ────────────────────────────────────────────────
  // Called on every sign-in. Creates the user doc if it doesn't exist,
  // or just updates 'lastSeenAt' if it does.
  // SetOptions(merge: true) is the key — it only writes the fields you specify,
  // leaving all other fields (like bestScore) untouched.
  Future<void> registerOrUpdateUser(AppUser user, String? studentName, String? rollNumber) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnap = await docRef.get();
      
      final Map<String, dynamic> data = {
        'uid': user.uid,
        'isAnonymous': user.isAnonymous,
        'displayName': user.displayName ?? 'Anonymous Player',
        'lastSeenAt': FieldValue.serverTimestamp(),
      };
      
      if (!docSnap.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      
      if (studentName != null && studentName.isNotEmpty) {
        data['name'] = studentName;
      }
      if (rollNumber != null && rollNumber.isNotEmpty) {
        data['rollNumber'] = rollNumber;
      }

      await docRef.set(
        data,
        SetOptions(merge: true),
      );
      debugPrint('[UserRepository] User registered/updated: ${user.uid}');
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] registerOrUpdateUser failed: ${e.code} — ${e.message}');
    } catch (e) {
      debugPrint('[UserRepository] registerOrUpdateUser unexpected error: $e');
    }
  }

  Future<void> updateAfterGame(String uid, int newScore) async {
    try {
      // Fetch existing best score to decide whether to update it.
      final doc = await _firestore.collection('users').doc(uid).get();
      final currentBest = (doc.data()?['bestScore'] as num?)?.toInt() ?? 0;
      final isNewRecord = newScore > currentBest;

      final Map<String, dynamic> updateData = {
        'totalGames': FieldValue.increment(1),   // always bump game count
        'lastSeenAt': FieldValue.serverTimestamp(),
        if (isNewRecord) 'bestScore': newScore,  // only update if it's a new record
      };

      // Use set(merge:true) instead of update() to avoid "not-found" crash
      // when this runs before registerOrUpdateUser() completes.
      await _firestore.collection('users').doc(uid).set(
        updateData,
        SetOptions(merge: true),
      );

      debugPrint(
        '[UserRepository] Game recorded for uid=$uid | '
        'score=$newScore | bestScore=${isNewRecord ? newScore : currentBest} | newRecord=$isNewRecord',
      );
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] updateAfterGame FAILED: ${e.code} — ${e.message}');
    } catch (e) {
      debugPrint('[UserRepository] updateAfterGame unexpected error: $e');
    }
  }

  // ── Get User ───────────────────────────────────────────────────────────────
  // Fetches a user's full profile. Useful for a future profile/stats screen.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] getUser failed: ${e.code} — ${e.message}');
      return null;
    }
  }
}
