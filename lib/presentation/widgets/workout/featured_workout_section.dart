import 'package:flutter/cupertino.dart';
import '../../controllers/workout_page_controller.dart';
import '../../../domain/models/custom_workout.dart';
import './workout_grid.dart';
import './featured_workout_card.dart';

class FeaturedWorkoutsSection extends StatelessWidget {
  final WorkoutPageController controller;

  const FeaturedWorkoutsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomWorkout>>(
      stream: controller.getFeaturedWorkouts(),
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

        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Featured Programs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (workouts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          CupertinoIcons.star,
                          size: 48,
                          color: CupertinoColors.systemGrey3,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No featured workouts yet',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the star icon to add one',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey2,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              WorkoutGrid(
                workouts: workouts,
                cardBuilder: (workout) => FeaturedWorkoutCard(workout: workout),
              ),
          ],
        );
      },
    );
  }
}