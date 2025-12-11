import 'package:athlo/models/workout_session.dart' hide WorkoutSession;
import 'package:flutter/cupertino.dart';
import '../models/workout_session.dart';
class WorkoutSummaryPage extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryPage({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = session.duration;
    final totalSets = session.exercises.fold<int>(
      0,
          (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Workout Complete! 🎉'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Duration',
                      '${duration.inMinutes} min',
                      CupertinoIcons.time,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Exercises',
                      '${session.completedExercises}/${session.exercises.length}',
                      CupertinoIcons.sportscourt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Sets',
                      totalSets.toString(),
                      CupertinoIcons.chart_bar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Calories',
                      '${(duration.inMinutes * 5).toString()} cal',
                      CupertinoIcons.flame,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Exercise Summary
              const Text(
                'Exercise Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...session.exercises.map((exercise) {
                final completedSets =
                    exercise.sets.where((s) => s.isCompleted).length;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemGrey5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        exercise.isCompleted
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        color: exercise.isCompleted
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$completedSets sets completed',
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: CupertinoColors.activeBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}