import 'package:dsal/screens/quizzes/quiz_attempt_screen.dart';
import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../services/quiz_service.dart';

class QuizzesScreen extends StatelessWidget {
  final QuizService _quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quizzes'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQuizList(),
            _buildQuizList(filter: 'in_progress'),
            _buildQuizList(filter: 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList({String? filter}) {
    return StreamBuilder<List<Quiz>>(
      stream: _quizService.getQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final quizzes = snapshot.data ?? [];

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return QuizCard(quiz: quiz);
          },
        );
      },
    );
  }
}

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({Key? key, required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startQuiz(context),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildDifficultyChip(),
                ],
              ),
              SizedBox(height: 8),
              Text(quiz.description),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.quiz_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${quiz.questions.length} questions'),
                  SizedBox(width: 16),
                  Icon(Icons.timer_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${quiz.timeLimit ~/ 60} minutes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    Color color;
    switch (quiz.difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        quiz.difficulty,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _startQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizAttemptScreen(quiz: quiz),
      ),
    );
  }
}