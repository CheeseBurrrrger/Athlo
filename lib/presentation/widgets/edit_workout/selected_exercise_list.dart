import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';

class SelectedExercisesList extends StatelessWidget {
  final EditWorkoutController controller;

  const SelectedExercisesList({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: controller.selectedExercises.map((exercise) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.selectedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.selectedColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.sportscourt,
                color: controller.selectedColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      exercise.equipment,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                child: const Icon(
                  CupertinoIcons.minus_circle,
                  color: CupertinoColors.systemRed,
                ),
                onPressed: () => controller.removeExercise(exercise),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}