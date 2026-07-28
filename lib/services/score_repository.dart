import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_score_model.dart';

class ScoreRepository {
  final FirebaseFirestore _firestore;

  ScoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitScore(UserScore score) async {
    try {
      await _firestore.collection('scores').add(score.toMap());
    } catch (e) {
      print('Error submitting score: $e');
    }
  }

  Future<List<UserScore>> getHighScores({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => UserScore.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching high scores: $e');
      return [];
    }
  }
}
