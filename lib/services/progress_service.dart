import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateProgress(UserProgress progress) async {
    await _firestore
        .collection('user_progress')
        .doc('${progress.userId}_${progress.courseId}')
        .set(progress.toMap());
  }

  Stream<UserProgress?> getUserProgress(String userId, String courseId) {
    return _firestore
        .collection('user_progress')
        .doc('${userId}_$courseId')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProgress.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> markLessonComplete(
      String userId, String courseId, String lessonId) async {
    final docRef =
    _firestore.collection('user_progress').doc('${userId}_$courseId');
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (docSnapshot.exists) {
        final progress = UserProgress.fromMap(docSnapshot.data()!);
        if (!progress.completedLessons.contains(lessonId)) {
          final updatedLessons = [...progress.completedLessons, lessonId];
          transaction.update(docRef, {
            'completedLessons': updatedLessons,
            'lastAccessed': Timestamp.now(),
          });
        }
      } else {
        transaction.set(docRef, {
          'userId': userId,
          'courseId': courseId,
          'completedLessons': [lessonId],
          'quizScores': {},
          'lastAccessed': Timestamp.now(),
        });
      }
    });
  }
}