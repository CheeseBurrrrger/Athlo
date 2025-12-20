import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';
import './workout_info_field.dart';
import './workout_level_picker.dart';
import './workout_muscle_picker.dart';
import './workout_color_picker.dart';

class EditWorkoutForm extends StatelessWidget {
  final EditWorkoutController controller;

  const EditWorkoutForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkoutInfoField(
          label: 'Workout Name',
          controller: controller.titleController,
          placeholder: 'Enter workout name',
          icon: CupertinoIcons.sportscourt,
        ),
        const SizedBox(height: 20),
        WorkoutInfoField(
          label: 'Duration',
          controller: controller.durationController,
          placeholder: 'e.g., 45-60 min',
          icon: CupertinoIcons.time,
        ),
        const SizedBox(height: 20),
        WorkoutLevelPicker(controller: controller),
        const SizedBox(height: 20),
        WorkoutMusclePicker(controller: controller),
        const SizedBox(height: 20),
        WorkoutColorPicker(controller: controller),
      ],
    );
  }
}