import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return AppUser.fromFirebaseUser(user);
    });
  }

  Future<AppUser?> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return AppUser.fromFirebaseUser(userCredential.user);
    } catch (e) {
      print('Failed to sign in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
