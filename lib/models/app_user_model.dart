class AppUser {
  final String uid;
  final bool isAnonymous;
  final String? displayName;

  AppUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
  });

  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    // Stub expecting future Firebase implementation
    return AppUser(
      uid: firebaseUser?.uid ?? 'test-uid',
      isAnonymous: firebaseUser?.isAnonymous ?? true,
      displayName: firebaseUser?.displayName,
    );
  }
}
