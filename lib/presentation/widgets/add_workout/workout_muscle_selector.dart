import 'package:flutter/cupertino.dart';
import '../../controllers/add_workout_controller.dart';

class WorkoutMuscleSelector extends StatelessWidget {
  final AddWorkoutController controller;
  final ValueChanged<String> onMuscleSelected;

  const WorkoutMuscleSelector({
    Key? key,
    required this.controller,
    required this.onMuscleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Muscle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdown(context),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    if (controller.isLoadingMuscles) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 12),
            Text('Loading muscles...'),
          ],
        ),
      );
    }

    if (controller.muscles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No muscles available'),
      );
    }

    return GestureDetector(
      onTap: () => _showMusclePicker(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.scope, color: CupertinoColors.systemGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.selectedMuscle?.toUpperCase() ?? 'Select target muscle',
                style: TextStyle(
                  fontSize: 16,
                  color: controller.selectedMuscle != null
                      ? CupertinoColors.label
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showMusclePicker(BuildContext context) {
    String? tempSelection = controller.selectedMuscle;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select Muscle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (tempSelection != null && tempSelection != controller.selectedMuscle) {
                        onMuscleSelected(tempSelection!);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (int index) {
                  tempSelection = controller.muscles[index].name;
                },
                children: controller.muscles.map((muscle) {
                  return Center(child: Text(muscle.name.toUpperCase()));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}