class Course {
  final String id;
  final String title;
  final String description;
  final Map<String, dynamic> content;
  final String difficulty;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.difficulty,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? {},
      difficulty: map['difficulty'] ?? 'Beginner',
    );
  }
}