import 'package:flutter/material.dart';
import '../../domain/models/goal.dart';
import '../../data/services/goal_service.dart';
import '../widgets/goal_card.dart';
import 'goal_detail_page.dart';

// All Goals Page to view history
class AllGoalsPage extends StatelessWidget {
  final String userID;

  const AllGoalsPage({super.key, required this.userID});

  @override
  Widget build(BuildContext context) {
    final goalService = GoalService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Goals'),
        backgroundColor: const Color(0xFF1974F5),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Goal>>(
        stream: goalService.getAllGoals(userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return const Center(child: Text('No goals yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return GoalCard(
                goal: goals[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalDetailPage(goal: goals[index]),
                    ),
                  );
                },
                onQuickUpdate: null, // No quick update in history view
              );
            },
          );
        },
      ),
    );
  }
}