import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Quiz>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Quiz.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> submitQuizResult({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required Duration timeTaken,
  }) async {
    await _firestore.collection('quiz_results').add({
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user's total score in leaderboard
    final userRef = _firestore.collection('leaderboard').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (userDoc.exists) {
        final currentScore = userDoc.data()?['totalScore'] ?? 0;
        transaction.update(userRef, {
          'totalScore': currentScore + score,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(userRef, {
          'userId': userId,
          'totalScore': score,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}