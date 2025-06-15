import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import '../../models/challenge.dart';
import '../../services/challenge_service.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({Key? key, required this.challenge})
      : super(key: key);

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final CodeController _codeController = CodeController();
  bool _isRunning = false;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _codeController.text = widget.challenge.starterCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildCodeEditor(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildChallengeDetails(),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCodeEditor() {
    return Container(
      color: Colors.grey[900],
      child: CodeField(
        controller: _codeController,
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildChallengeDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problem Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(widget.challenge.description),
          SizedBox(height: 16),
          Text(
            'Constraints',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          ...widget.challenge.constraints.entries.map(
                (constraint) => Text('• ${constraint.key}: ${constraint.value}'),
          ),
          SizedBox(height: 16),
          Text(
            'Output',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: Text(_output),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _isRunning ? null : _runTests,
            child: Text('Run Tests'),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isRunning ? null : _submitSolution,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _output = 'Running tests...\n';
    });

    try {
      for (var testCase in widget.challenge.testCases) {
        // In a real app, you would send the code to a backend service
        // for execution and validation
        await Future.delayed(Duration(seconds: 1)); // Simulated delay
        _output += '\nTest case ${testCase['input']}: Passed';
      }
    } catch (e) {
      _output += '\nError: $e';
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _submitSolution() async {
    setState(() {
      _isRunning = true;
      _output = 'Submitting solution...\n';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ChallengeService().submitSolution(
          userId: user.uid,
          challengeId: widget.challenge.id,
          code: _codeController.text,
          passed: true, // In a real app, this would be determined by test results
          executionTime: 100, // In a real app, this would be measured
        );
        _output += '\nSolution submitted successfully!';
      }
    } catch (e) {
      _output += '\nError: $e';
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
}