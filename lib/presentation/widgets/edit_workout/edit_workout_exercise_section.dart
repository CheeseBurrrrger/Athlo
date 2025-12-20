import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';
import './selected_exercise_list.dart';
import './exercise_picker_modal.dart';

class EditWorkoutExercisesSection extends StatelessWidget {
  final EditWorkoutController controller;
  final Function(String) onLoadExercises;

  const EditWorkoutExercisesSection({
    Key? key,
    required this.controller,
    required this.onLoadExercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        if (controller.selectedExercises.isNotEmpty)
          SelectedExercisesList(controller: controller),
        const SizedBox(height: 16),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Exercises',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: controller.selectedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${controller.selectedExercises.length} selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: controller.selectedColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showExercisePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              color: controller.selectedColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Exercises',
              style: TextStyle(
                color: controller.selectedColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ExercisePickerModal(controller: controller),
    );
  }
}