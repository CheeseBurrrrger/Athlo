import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';

class WorkoutMusclePicker extends StatelessWidget {
  final EditWorkoutController controller;

  const WorkoutMusclePicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Muscle',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        controller.isLoadingMuscles
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CupertinoActivityIndicator()),
        )
            : GestureDetector(
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
                  CupertinoIcons.scope,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.selectedMuscle,
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
    String? tempSelection = controller.selectedMuscle;

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
                    onPressed: () {
                      Navigator.pop(context);
                      if (tempSelection != null && tempSelection != controller.selectedMuscle) {
                        // This will be handled by parent widget
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: controller.muscles.indexWhere(
                        (m) => m.name == controller.selectedMuscle,
                  ),
                ),
                onSelectedItemChanged: (index) {
                  tempSelection = controller.muscles[index].name;
                  controller.setMuscle(tempSelection!);
                },
                children: controller.muscles
                    .map((muscle) => Center(child: Text(muscle.name)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}