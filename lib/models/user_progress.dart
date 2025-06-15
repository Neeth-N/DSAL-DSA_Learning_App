import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final String courseId;
  final List<String> completedLessons;
  final Map<String, int> quizScores;
  final DateTime lastAccessed;

  UserProgress({
    required this.userId,
    required this.courseId,
    required this.completedLessons,
    required this.quizScores,
    required this.lastAccessed,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      quizScores: Map<String, int>.from(map['quizScores'] ?? {}),
      lastAccessed: (map['lastAccessed'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'quizScores': quizScores,
      'lastAccessed': Timestamp.fromDate(lastAccessed),
    };
  }
}