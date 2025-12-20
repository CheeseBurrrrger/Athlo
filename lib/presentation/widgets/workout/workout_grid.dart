import 'package:flutter/cupertino.dart';
import '../../../domain/models/custom_workout.dart';

class WorkoutGrid extends StatelessWidget {
  final List<CustomWorkout> workouts;
  final Widget Function(CustomWorkout) cardBuilder;

  const WorkoutGrid({
    Key? key,
    required this.workouts,
    required this.cardBuilder,
  }) : super(key: key);

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 0.75;
    if (width > 900) return 0.7;
    if (width > 600) return 0.65;
    return 0.6;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _getChildAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => cardBuilder(workouts[index]),
          childCount: workouts.length,
        ),
      ),
    );
  }
}
