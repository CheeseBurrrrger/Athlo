import 'package:flutter/cupertino.dart';
import '../../../domain/constants/workout_constants.dart';
import '../popular_workout_card.dart';

class PopularWorkoutsSection extends StatelessWidget {
  const PopularWorkoutsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Popular Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final workout = WorkoutConstants.popularWorkouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PopularWorkoutCard(
                    title: workout['title']!,
                    duration: workout['duration']!,
                    calories: workout['calories']!,
                    level: workout['level']!,
                    icon: workout['icon'] as IconData,
                    color: workout['color'] as Color,
                  ),
                );
              },
              childCount: WorkoutConstants.popularWorkouts.length,
            ),
          ),
        ),
      ],
    );
  }
}