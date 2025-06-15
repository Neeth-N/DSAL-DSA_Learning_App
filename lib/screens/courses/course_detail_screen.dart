import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/course.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            _buildDifficultyChip(course.difficulty),
            SizedBox(height: 16),
            Text(
              course.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24),
            _buildCourseContent(context, course.content),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implement start learning functionality
        },
        label: Text('Start Learning'),
        icon: Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        difficulty,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildCourseContent(BuildContext context, Map<String, dynamic> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Content',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: content.length,
          itemBuilder: (context, index) {
            final section = content.entries.elementAt(index);
            return ExpansionTile(
              title: Text(section.key),
              children: (section.value as List).map<Widget>((topic) {
                return ListTile(
                  leading: Icon(Icons.article_outlined),
                  title: Text(topic['title']),
                  subtitle: Text(topic['duration']),
                  trailing: Icon(Icons.lock_outline),
                  onTap: () {
                    // Implement topic navigation
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
