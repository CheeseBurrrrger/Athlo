import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';

class WorkoutColorPicker extends StatelessWidget {
  final EditWorkoutController controller;

  const WorkoutColorPicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Color',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: controller.availableColors.asMap().entries.map((entry) {
            final index = entry.key;
            final color = entry.value;
            final isSelected = controller.selectedColorIndex == index;

            return GestureDetector(
              onTap: () => controller.setColorIndex(index),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                  CupertinoIcons.check_mark,
                  color: CupertinoColors.white,
                )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}