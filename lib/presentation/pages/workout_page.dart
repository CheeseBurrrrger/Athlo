import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import '../controllers/workout_page_controller.dart';
import '../widgets/workout/workout_header.dart';
import '../widgets/workout/workout_stats_section.dart';
import '../widgets/workout/custom_workouts_section.dart';
import '../widgets/workout/featured_workout_section.dart';
import '../widgets/workout/popular_workout_section.dart';
import '../widgets/add_workout_bottom_sheet.dart';
import '../widgets/add_feature_workout_bottom_sheet.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutPageController _controller = WorkoutPageController();

  @override
  void initState() {
    super.initState();
    _controller.loadStats();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Workout Plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1974F5),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.star, color: CupertinoColors.white),
          onPressed: _showAddFeaturedWorkout,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _showAddWorkout,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            const WorkoutHeader(),
            WorkoutStatsSection(controller: _controller),
            CustomWorkoutsSection(
              controller: _controller,
              onWorkoutDeleted: () => _controller.loadStats(),
            ),
            FeaturedWorkoutsSection(controller: _controller),
            const PopularWorkoutsSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddWorkout() async {
    final result = await showCupertinoModalPopup(
      context: context,
      builder: (context) => const AddWorkoutBottomSheet(),
    );
    if (result == true) {
      _controller.loadStats();
    }
  }

  Future<void> _showAddFeaturedWorkout() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => const AddFeaturedWorkoutBottomSheet(),
    );
  }
}
