import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(Icons.access_time, 'Duration', duration, color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(Icons.bar_chart, 'Level', level, color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(Icons.track_changes, 'Target', target, color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(Icons.fitness_center, 'Exercises', exercises, color),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Workout Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Program latihan ini dirancang untuk memaksimalkan hasil dengan fokus pada $target. '
                        'Cocok untuk level $level yang ingin meningkatkan kekuatan dan massa otot.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Exercise List
                  const Text(
                    'Exercise List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._buildExerciseList(color),

                  const SizedBox(height: 24),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starting workout! 💪')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseList(Color color) {
    final exercises = [
      {'name': 'Barbell Bench Press', 'sets': '4 sets × 8-10 reps'},
      {'name': 'Dumbbell Rows', 'sets': '4 sets × 10-12 reps'},
      {'name': 'Shoulder Press', 'sets': '3 sets × 10 reps'},
      {'name': 'Bicep Curls', 'sets': '3 sets × 12 reps'},
      {'name': 'Tricep Dips', 'sets': '3 sets × 10-12 reps'},
      {'name': 'Cable Flyes', 'sets': '3 sets × 12-15 reps'},
    ];

    return exercises.map((exercise) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              child: Icon(Icons.fitness_center, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise['sets']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline, color: color, size: 28),
          ],
        ),
      );
    }).toList();
  }
}