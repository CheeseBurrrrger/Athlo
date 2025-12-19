// lib/progress_tracker.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/goal.dart';
import 'models/goal_progress_entry.dart';
import 'services/goal_service.dart';
import 'services/activity_goal_integration.dart';
import 'widgets/goal_card.dart';
import 'widgets/create_goal_sheet.dart';
import 'pages/goal_detail_page.dart';
import 'package:intl/intl.dart'; // make sure you have intl in pubspec.yaml

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  final GoalService _goalService = GoalService();
  final ActivityGoalIntegration _activityIntegration = ActivityGoalIntegration();
  final String userID = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncActivities();
  }

  Future<void> _syncActivities() async {
    if (userID.isEmpty) return;

    setState(() => _isSyncing = true);

    try {
      await _activityIntegration.syncActivitiesWithGoals(userID);
    } catch (e) {
      print('Error syncing activities: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'My Progress',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_isSyncing) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isSyncing ? null : _syncActivities,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showAllGoals(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _goalService.getActiveGoals(userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final goals = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(goals),
                const SizedBox(height: 16),
                if (goals.isEmpty)
                  _buildEmptyState()
                else
                  _buildGoalsSection(goals),
                const SizedBox(height: 16),
                _buildStatsOverview(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalSheet(context),
        backgroundColor: const Color(0xFFFFFFFF),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildHeader(List<Goal> goals) {
    final completedGoals = goals.where((g) => g.progressPercentage >= 100).length;
    final onTrackGoals = goals.where((g) => g.progressStatus == 'On track').length;

    final currentTime = DateFormat('EEE, MMM d • HH:mm').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3C467B),
            Color(0xFF50589C),
            Color(0xFF636CCB),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Goals',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goals.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'System time: $currentTime',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (onTrackGoals > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$onTrackGoals goal${onTrackGoals > 1 ? 's' : ''} on track!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to start tracking your progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateGoalSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C467B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(List<Goal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreateGoalSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            return GoalCard(
              goal: goals[index],
              onTap: () => _navigateToGoalDetail(goals[index]),
              onQuickUpdate: (value) => _handleQuickUpdate(goals[index], value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _goalService.getStatistics(userID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data!;
        final completionRate = stats['completionRate'] as double;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Goals',
                      '${stats['totalGoals']}',
                      Icons.flag,
                      const Color(0xFF3C467B),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Completed',
                      '${stats['completedGoals']}',
                      Icons.check_circle,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Success Rate',
                      '${completionRate.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCreateGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateGoalSheet(userID: userID),
    );
  }

  void _navigateToGoalDetail(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailPage(goal: goal),
      ),
    );
  }

  Future<void> _handleQuickUpdate(Goal goal, double value) async {
    try {
      await _goalService.addProgress(
        goalId: goal.id,
        value: value,
        source: ProgressSource.manual,
        notes: 'Quick update',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress updated: +${value.toStringAsFixed(0)} ${_getUnitLabel(goal.metric)}'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating progress: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getUnitLabel(GoalMetric metric) {
    switch (metric) {
      case GoalMetric.calories:
        return 'kcal';
      case GoalMetric.duration:
        return 'min';
      case GoalMetric.workouts:
        return 'workouts';
    }
  }

  void _showAllGoals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllGoalsPage(userID: userID),
      ),
    );
  }
}

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