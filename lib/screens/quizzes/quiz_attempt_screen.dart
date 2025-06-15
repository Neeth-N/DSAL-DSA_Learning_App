import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../services/quiz_service.dart';

class QuizAttemptScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizAttemptScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizAttemptScreenState createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  late Timer _timer;
  late int _timeRemaining;
  List<int?> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.quiz.timeLimit;
    _selectedAnswers = List<int?>.filled(widget.quiz.questions.length, null);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _prevQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _submitQuiz() async {
    _timer.cancel();
    int score = 0;
    int totalQuestions = widget.quiz.questions.length;

    for (int i = 0; i < totalQuestions; i++) {
      if (_selectedAnswers[i] == widget.quiz.questions[i].correctAnswer) {
        score++;
      }
    }

    await QuizService().submitQuizResult(
      userId: 'testUser', // Replace with actual user ID
      quizId: widget.quiz.id,
      score: score,
      totalQuestions: totalQuestions,
      timeTaken: Duration(seconds: widget.quiz.timeLimit - _timeRemaining),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Attempt'),
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('$_timeRemaining s', style: TextStyle(fontSize: 18)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(question.question, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              return RadioListTile<int>(
                title: Text(question.options[index]),
                value: index,
                groupValue: _selectedAnswers[_currentQuestionIndex],
                onChanged: (value) => _selectAnswer(value!),
              );
            }),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _prevQuestion,
                    child: Text('Previous'),
                  ),
                if (_currentQuestionIndex < widget.quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _submitQuiz,
                    child: Text('Submit'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
