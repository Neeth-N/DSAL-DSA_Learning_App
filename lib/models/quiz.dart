class Quiz {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String difficulty;
  final List<Question> questions;
  final int timeLimit;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.difficulty,
    required this.questions,
    required this.timeLimit,
  });

  factory Quiz.fromMap(Map<String, dynamic> map, String id) {
    return Quiz(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseId: map['courseId'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      questions: (map['questions'] as List? ?? [])
          .map((q) => Question.fromMap(q))
          .toList(),
      timeLimit: map['timeLimit'] ?? 600,
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      explanation: map['explanation'],
    );
  }
}