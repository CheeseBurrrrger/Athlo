import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import '../controllers/add_workout_controller.dart';
import 'add_workout/workout_form_header.dart';
import 'add_workout/workout_basic_info_section.dart';
import 'add_workout/workout_level_selector.dart';
import 'add_workout/workout_muscle_selector.dart';
import 'add_workout/workout_exercise_selector.dart';
import '../../domain/utils/dialog_utils.dart';

class AddWorkoutBottomSheet extends StatefulWidget {
  const AddWorkoutBottomSheet({super.key});

  @override
  State<AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends State<AddWorkoutBottomSheet> {
  final AddWorkoutController _controller = AddWorkoutController();

  @override
  void initState() {
    super.initState();
    _controller.loadMuscles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final error = _controller.validateForm();
    if (error != null) {
      DialogUtils.showError(context, error);
      return;
    }

    try {
      await _controller.saveWorkout();
      if (mounted) {
        Navigator.pop(context, true);
        DialogUtils.showSuccess(context, 'Workout created successfully! 💪');
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showError(context, 'Failed to save workout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CupertinoColors.systemBackground,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            WorkoutFormHeader(
              title: 'Add Custom Workout',
              onClose: () => Navigator.pop(context),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CupertinoScrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WorkoutBasicInfoSection(
                            nameController: _controller.nameController,
                            durationController: _controller.durationController,
                          ),
                          const SizedBox(height: 20),
                          WorkoutLevelSelector(
                            selectedLevel: _controller.selectedLevel,
                            onLevelChanged: _controller.setLevel,
                          ),
                          const SizedBox(height: 20),
                          WorkoutMuscleSelector(
                            controller: _controller,
                            onMuscleSelected: (muscle) {
                              _controller.setMuscle(muscle);
                              _controller.loadExercises(muscle).catchError((e) {
                                DialogUtils.showError(context, e.toString());
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_controller.selectedMuscle != null)
                            WorkoutExerciseSelector(controller: _controller),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: _handleSave,
            borderRadius: BorderRadius.circular(12),
            child: const Text(
              'Create Workout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}