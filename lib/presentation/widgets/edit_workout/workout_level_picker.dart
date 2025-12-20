import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';

class WorkoutLevelPicker extends StatelessWidget {
  final EditWorkoutController controller;

  const WorkoutLevelPicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness Level',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.chart_bar,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.selectedLevel,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: controller.levels.indexOf(controller.selectedLevel),
                ),
                onSelectedItemChanged: (index) {
                  controller.setLevel(controller.levels[index]);
                },
                children: controller.levels
                    .map((level) => Center(child: Text(level)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}