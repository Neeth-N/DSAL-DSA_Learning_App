import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Course>> getCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<Course> getCourseById(String courseId) async {
    final doc = await _firestore.collection('courses').doc(courseId).get();
    return Course.fromMap(doc.data()!, doc.id);
  }
}