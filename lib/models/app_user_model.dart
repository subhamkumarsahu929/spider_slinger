import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppUser is our app's internal representation of a signed-in player.
//
// Why not use Firebase's User object directly throughout the codebase?
//   Because it keeps game logic decoupled from Firebase.
//   If we ever switch auth providers, only this file changes.
// ─────────────────────────────────────────────────────────────────────────────
class AppUser {
  /// Firebase's unique anonymous identifier for this device.
  /// Persists across app restarts until the app is uninstalled.
  final String uid;

  /// True for anonymous sign-in (our default for all players).
  final bool isAnonymous;

  /// Display name — null for anonymous users (they have no name yet).
  final String? displayName;

  AppUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
  });

  // ── Factory: from Firebase ─────────────────────────────────────────────────
  // Converts Firebase's User object into our lightweight AppUser.
  // Uses the strongly-typed Firebase User class (not dynamic anymore).
  factory AppUser.fromFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) {
      // Fallback — should never happen in normal flow because
      // signInAnonymously() always returns a user.
      return AppUser(uid: 'unknown', isAnonymous: true);
    }
    return AppUser(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      displayName: firebaseUser.displayName,
    );
  }

  // ── Factory: to Firestore Map ──────────────────────────────────────────────
  // Saves basic user info to the 'users' collection in Firestore.
  // Called once on first sign-in to register the player.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'isAnonymous': isAnonymous,
      'displayName': displayName ?? 'Anonymous Player',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() => 'AppUser(uid: $uid, isAnonymous: $isAnonymous)';
}

