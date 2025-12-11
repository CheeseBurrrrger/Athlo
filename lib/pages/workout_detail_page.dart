import 'package:flutter/cupertino.dart';

class WorkoutDetailPage extends StatelessWidget {
  final String title;
  final String duration;
  final String level;
  final String target;
  final String exercises;
  final IconData icon;
  final Color color;

  const WorkoutDetailPage({
    Key? key,
    required this.title,
    required this.duration,
    required this.level,
    required this.target,
    required this.exercises,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          _buildNavigationBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCards(),
                      const SizedBox(height: 24),
                      _buildOverviewSection(),
                      const SizedBox(height: 24),
                      _buildExerciseListSection(),
                      const SizedBox(height: 24),
                      _buildStartButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // Navigation Bar
  // ========================================
  Widget _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
      backgroundColor: color,
      largeTitle: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
      ),
      leading: CupertinoNavigationBarBackButton(
        color: CupertinoColors.white,
        onPressed: () {}, // Navigator.pop will be added when integrated
      ),
      stretch: true,
    );
  }

  // ========================================
  // Hero Section
  // ========================================
  Widget _buildHeroSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: CupertinoColors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  // ========================================
  // Info Cards
  // ========================================
  Widget _buildInfoCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: CupertinoIcons.time,
                label: 'Duration',
                value: duration,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: CupertinoIcons.chart_bar,
                label: 'Level',
                value: level,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: CupertinoIcons.scope,
                label: 'Target',
                value: target,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: CupertinoIcons.sportscourt,
                label: 'Exercises',
                value: exercises,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========================================
  // Overview Section
  // ========================================
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Program latihan ini dirancang untuk memaksimalkan hasil dengan fokus pada $target. '
              'Cocok untuk level $level yang ingin meningkatkan kekuatan dan massa otot.',
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ========================================
  // Exercise List Section
  // ========================================
  Widget _buildExerciseListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._getExerciseList().map((exercise) {
          return _ExerciseCard(
            name: exercise['name']!,
            sets: exercise['sets']!,
            color: color,
          );
        }),
      ],
    );
  }

  // ========================================
  // Start Button
  // ========================================
  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // TODO: Replace with actual navigation
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute(
          //     builder: (context) => ActiveWorkoutPage(workout: workout),
          //   ),
          // );

          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              content: const Text('Starting workout! 💪'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Start Workout',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // Exercise Data
  // ========================================
  List<Map<String, String>> _getExerciseList() {
    return [
      {'name': 'Barbell Bench Press', 'sets': '4 sets × 8-10 reps'},
      {'name': 'Dumbbell Rows', 'sets': '4 sets × 10-12 reps'},
      {'name': 'Shoulder Press', 'sets': '3 sets × 10 reps'},
      {'name': 'Bicep Curls', 'sets': '3 sets × 12 reps'},
      {'name': 'Tricep Dips', 'sets': '3 sets × 10-12 reps'},
      {'name': 'Cable Flyes', 'sets': '3 sets × 12-15 reps'},
    ];
  }
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

// ========================================
// Info Card Widget
// ========================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ========================================
// Exercise Card Widget
// ========================================
class _ExerciseCard extends StatelessWidget {
  final String name;
  final String sets;
  final Color color;

  const _ExerciseCard({
    required this.name,
    required this.sets,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.sportscourt,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sets,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.play_circle,
            color: color,
            size: 28,
          ),
        ],
      ),
    );
  }
}