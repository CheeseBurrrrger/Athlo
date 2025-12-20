import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controllers/edit_workout_controller.dart';
import '../../domain/models/custom_workout.dart';
import '../../domain/utils/dialog_utils.dart';
import './edit_workout/edit_workout_header.dart';
import './edit_workout/edit_workout_form.dart';
import 'edit_workout/edit_workout_exercise_section.dart';

class EditWorkoutBottomSheet extends StatefulWidget {
  final CustomWorkout workout;

  const EditWorkoutBottomSheet({super.key, required this.workout});

  @override
  State<EditWorkoutBottomSheet> createState() => _EditWorkoutBottomSheetState();
}

class _EditWorkoutBottomSheetState extends State<EditWorkoutBottomSheet> {
  late final EditWorkoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditWorkoutController(originalWorkout: widget.workout);
    _controller.loadMuscles().catchError((e) {
      if (mounted) {
        DialogUtils.showError(context, 'Error loading data: $e');
      }
    });
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
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showError(context, 'Error updating workout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            EditWorkoutHeader(
              onClose: () => Navigator.pop(context),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditWorkoutForm(controller: _controller),
                        const SizedBox(height: 24),
                        EditWorkoutExercisesSection(
                          controller: _controller,
                          onLoadExercises: (muscle) {
                            _controller.setMuscle(muscle);
                            _controller.selectedExercises.clear();
                            _controller.loadExercises(muscle).catchError((e) {
                              DialogUtils.showError(context, 'Error loading exercises: $e');
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
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
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey3,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            border: Border(
              top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
            ),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _handleSave,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _controller.selectedColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}