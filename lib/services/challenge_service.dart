import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Challenge>> getChallenges() {
    return _firestore.collection('challenges').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Challenge.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> submitSolution({
    required String userId,
    required String challengeId,
    required String code,
    required bool passed,
    required int executionTime,
  }) async {
    await _firestore.collection('submissions').add({
      'userId': userId,
      'challengeId': challengeId,
      'code': code,
      'passed': passed,
      'executionTime': executionTime,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
