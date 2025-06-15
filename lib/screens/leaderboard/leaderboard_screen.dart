import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle filter selection
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'all_time',
                  child: Text('All Time'),
                ),
                PopupMenuItem(
                  value: 'this_month',
                  child: Text('This Month'),
                ),
                PopupMenuItem(
                  value: 'this_week',
                  child: Text('This Week'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('totalScore', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          return Column(
            children: [
              _buildTopThree(users),
              Expanded(
                child: _buildLeaderboardList(users),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<QueryDocumentSnapshot> users) {
    if (users.length < 3) return SizedBox();

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopUser(users[1], 2), // Second place
          _buildTopUser(users[0], 1), // First place
          _buildTopUser(users[2], 3), // Third place
        ],
      ),
    );
  }

  Widget _buildTopUser(QueryDocumentSnapshot user, int rank) {
    final score = user['totalScore'] ?? 0;
    final size = rank == 1 ? 100.0 : 80.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: rank == 1
                  ? Colors.yellow.shade700
                  : rank == 2
                  ? Colors.grey.shade400
                  : Colors.brown.shade300,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: rank == 1 ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${score.toString()} pts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final score = user['totalScore'] ?? 0;
        final rank = index + 1;

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rank <= 3
                  ? rank == 1
                  ? Colors.yellow.shade700
                  : rank == 2
                  ? Colors.grey.shade400
                  : Colors.brown.shade300
                  : Colors.blue.shade100,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : Colors.black,
                ),
              ),
            ),
            title: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user['userId'])
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                return Text(userData?['name'] ?? 'Anonymous');
              },
            ),
            trailing: Text(
              '$score pts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}