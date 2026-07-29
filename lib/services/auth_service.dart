import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import '../models/app_user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService wraps Firebase Authentication.
//
// Why anonymous auth?
//   Players don't want to create an account just to submit a score.
//   Firebase anonymous sign-in gives every player a unique uid automatically
//   so we can tie their scores to a persistent identity — even offline.
//   Later, you can "upgrade" their account to Google/email without losing data.
// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  // FirebaseAuth.instance is a singleton — there's only one per app.
  // We accept an optional override so unit tests can inject a mock.
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ── Auth State Stream ──────────────────────────────────────────────────────
  // Emits a new AppUser? every time the user's sign-in state changes:
  //   • null  → signed out (very rare for anonymous auth)
  //   • AppUser → signed in (has a uid we can attach scores to)
  //
  // This is a Stream, not a Future — it fires multiple times if state changes.
  // In main.dart we .listen() to it and update GameState whenever it fires.
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser == null) return null;
      return AppUser.fromFirebaseUser(firebaseUser);
    });
  }

  // ── Anonymous Sign-In ──────────────────────────────────────────────────────
  // Returns the AppUser on success, or null on failure.
  //
  // Key behaviour:
  //   • First launch → Firebase creates a brand-new anonymous uid and caches it.
  //   • Subsequent launches → Firebase returns the SAME cached uid (no network).
  //   • The uid persists until the app is uninstalled or signOut() is called.
  Future<AppUser?> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      // userCredential.user is the raw Firebase User object.
      // We convert it to our own AppUser to keep game code decoupled from Firebase.
      return AppUser.fromFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException gives us a specific error code.
      // Common codes: 'operation-not-allowed' (anonymous auth disabled in console)
      debugPrint('[AuthService] signInAnonymously failed: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      // Catch-all for unexpected errors (network loss during first-ever sign-in, etc.)
      debugPrint('[AuthService] signInAnonymously unexpected error: $e');
      return null;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  // Clears the local Firebase session. The anonymous uid is gone permanently
  // (unless you've linked it to a real account first).
  // For a game, you'd only call this in a "clear data / reset" scenario.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

