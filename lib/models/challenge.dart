class Challenge {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<Map<String, dynamic>> testCases;
  final String starterCode;
  final Map<String, dynamic> constraints;
  final int timeLimit;
  final String category;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.testCases,
    required this.starterCode,
    required this.constraints,
    required this.timeLimit,
    required this.category,
  });

  factory Challenge.fromMap(Map<String, dynamic> map, String id) {
    return Challenge(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      testCases: List<Map<String, dynamic>>.from(map['testCases'] ?? []),
      starterCode: map['starterCode'] ?? '',
      constraints: Map<String, dynamic>.from(map['constraints'] ?? {}),
      timeLimit: map['timeLimit'] ?? 1000,
      category: map['category'] ?? 'Arrays',
    );
  }
}