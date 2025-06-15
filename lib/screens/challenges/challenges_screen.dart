import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../../services/challenge_service.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatelessWidget {
  final ChallengeService _challengeService = ChallengeService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Coding Challenges'),
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
            _buildChallengeList(false),
            _buildChallengeList(true, inProgress: true),
            _buildChallengeList(true, completed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeList(bool filtered, {bool inProgress = false, bool completed = false}) {
    return StreamBuilder<List<Challenge>>(
      stream: _challengeService.getChallenges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final challenges = snapshot.data ?? [];

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return ChallengeCard(challenge: challenge);
          },
        );
      },
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({Key? key, required this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
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
                      challenge.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildDifficultyChip(challenge.difficulty),
                ],
              ),
              SizedBox(height: 8),
              Text(
                challenge.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16),
                  SizedBox(width: 4),
                  Text('${challenge.timeLimit}ms'),
                  SizedBox(width: 16),
                  Icon(Icons.category_outlined, size: 16),
                  SizedBox(width: 4),
                  Text(challenge.category),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
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
        difficulty,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}