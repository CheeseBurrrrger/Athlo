import 'package:flutter/cupertino.dart';
import '../../controllers/workout_page_controller.dart';
import '../quick_stat_card.dart';

class WorkoutStatsSection extends StatelessWidget {
  final WorkoutPageController controller;

  const WorkoutStatsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: QuickStatCard(
                    value: controller.stats['totalWorkouts'].toString(),
                    label: 'Workouts\nCompleted',
                    color: const Color(0xFF6E8CFB),
                    icon: CupertinoIcons.check_mark_circled_solid,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickStatCard(
                    value: controller.stats['todayMinutes'].toString(),
                    label: 'Minutes\nToday',
                    color: const Color(0xFF636CCB),
                    icon: CupertinoIcons.timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickStatCard(
                    value: controller.stats['currentStreak'].toString(),
                    label: 'Day\nStreak',
                    color: const Color(0xFF50589C),
                    icon: CupertinoIcons.flame_fill,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}