import 'package:dsal/screens/courses/quiz_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/progress_service.dart';

class LessonContentScreen extends StatefulWidget {
  final String lessonId;
  final String courseId;
  final Map<String, dynamic> lessonContent;

  const LessonContentScreen({
    Key? key,
    required this.lessonId,
    required this.courseId,
    required this.lessonContent,
  }) : super(key: key);

  @override
  _LessonContentScreenState createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  final ProgressService _progressService = ProgressService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final sections = widget.lessonContent['sections'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonContent['title']),
        actions: [
          IconButton(
            icon: Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    courseId: widget.courseId,
                    lessonId: widget.lessonId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: sections.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final section = sections[index];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['title'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      _buildContentSection(section),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildNavigationBar(sections.length),
        ],
      ),
    );
  }

  Widget _buildContentSection(Map<String, dynamic> section) {
    switch (section['type']) {
      case 'text':
        return Text(section['content']);
      case 'code':
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            section['content'],
            style: TextStyle(fontFamily: 'monospace'),
          ),
        );
      case 'image':
        return Image.network(section['content']);
      default:
        return SizedBox();
    }
  }

  Widget _buildNavigationBar(int totalPages) {
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
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
                : null,
            child: Text('Previous'),
          ),
          Text('${_currentPage + 1} / $totalPages'),
          TextButton(
            onPressed: _currentPage < totalPages - 1
                ? () => _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
                : () => _completeLesson(),
            child: Text(_currentPage < totalPages - 1 ? 'Next' : 'Complete'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeLesson() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _progressService.markLessonComplete(
        user.uid,
        widget.courseId,
        widget.lessonId,
      );
      Navigator.pop(context);
    }
  }
}