import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user_progress.dart';
import '../../services/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const QuizScreen({
    Key? key,
    required this.courseId,
    required this.lessonId,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ProgressService _progressService = ProgressService();
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  bool _quizCompleted = false;

  // In a real app, fetch these from Firestore
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the time complexity of array insertion?',
      'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
      'correctAnswer': 1,
    },
    // Add more questions...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: _quizCompleted ? _buildQuizResults() : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                Text(
                  question['question'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 24),
                ...List.generate(
                  question['options'].length,
                      (index) => RadioListTile(
                    value: index,
                    groupValue: _userAnswers.length > _currentQuestionIndex
                        ? int.parse(_userAnswers[_currentQuestionIndex])
                        : null,
                    onChanged: (value) {
                      setState(() {
                        if (_userAnswers.length > _currentQuestionIndex) {
                          _userAnswers[_currentQuestionIndex] = value.toString();
                        } else {
                          _userAnswers.add(value.toString());
                        }
                      });
                    },
                    title: Text(question['options'][index]),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildNavigationBar(),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentQuestionIndex > 0
                ? () {
              setState(() {
                _currentQuestionIndex--;
              });
            }
                : null,
            child: Text('Previous'),
          ),
          TextButton(
            onPressed: _userAnswers.length > _currentQuestionIndex
                ? () {
              if (_currentQuestionIndex < _questions.length - 1) {
                setState(() {
                  _currentQuestionIndex++;
                });
              } else {
                setState(() {
                  _quizCompleted = true;
                });
                _saveQuizResults();
              }
            }
                : null,
            child: Text(_currentQuestionIndex < _questions.length - 1
                ? 'Next'
                : 'Finish'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResults() {
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (int.parse(_userAnswers[i]) == _questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / _questions.length * 100).round();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Complete!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(
            'Your Score: $score%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Return to Lesson'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveQuizResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int correctAnswers = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (int.parse(_userAnswers[i]) == _questions[i]['correctAnswer']) {
          correctAnswers++;
        }
      }

      final score = (correctAnswers / _questions.length * 100).round();

      final docRef = FirebaseFirestore.instance
          .collection('user_progress')
          .doc('${user.uid}_${widget.courseId}');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          final progress = UserProgress.fromMap(docSnapshot.data()!);
          final updatedScores = Map<String, int>.from(progress.quizScores);
          updatedScores[widget.lessonId] = score;
          transaction.update(docRef, {'quizScores': updatedScores});
        } else {
          transaction.set(docRef, {
            'userId': user.uid,
            'courseId': widget.courseId,
            'completedLessons': [],
            'quizScores': {widget.lessonId: score},
            'lastAccessed': Timestamp.now(),
          });
        }
      });
    }
  }
}