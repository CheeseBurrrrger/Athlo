import 'package:flutter/cupertino.dart';
import '../../controllers/workout_page_controller.dart';
import '../../../domain/models/custom_workout.dart';
import './workout_grid.dart';
import './custom_workout_card.dart';

class CustomWorkoutsSection extends StatelessWidget {
  final WorkoutPageController controller;
  final VoidCallback onWorkoutDeleted;

  const CustomWorkoutsSection({
    Key? key,
    required this.controller,
    required this.onWorkoutDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomWorkout>>(
      stream: controller.getUserWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
          );
        }

        final workouts = snapshot.data ?? [];
        if (workouts.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Custom Workouts',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${workouts.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WorkoutGrid(
              workouts: workouts,
              cardBuilder: (workout) => CustomWorkoutCard(
                workout: workout,
                onDeleted: onWorkoutDeleted,
              ),
            ),
          ],
        );
      },
    );
  }
}