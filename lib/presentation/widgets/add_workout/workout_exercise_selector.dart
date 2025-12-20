import 'package:athlo/domain/models/exercise.dart';
import 'package:flutter/cupertino.dart';
import '../../controllers/add_workout_controller.dart';

class WorkoutExerciseSelector extends StatelessWidget {
  final AddWorkoutController controller;

  const WorkoutExerciseSelector({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        if (controller.availableExercises.isNotEmpty) _buildActions(),
        const SizedBox(height: 8),
        _buildExerciseList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Exercises',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (controller.selectedExercises.isNotEmpty)
          Text(
            '${controller.selectedExercises.length} selected',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (controller.selectedExercises.length <
            controller.availableExercises.length)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Select All'),
            onPressed: controller.selectAllExercises,
          ),
        if (controller.selectedExercises.isNotEmpty)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Clear'),
            onPressed: controller.clearExercises,
          ),
      ],
    );
  }

  Widget _buildExerciseList() {
    if (controller.isLoadingExercises) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text('Loading exercises...'),
            ],
          ),
        ),
      );
    }

    if (controller.availableExercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No exercises available for this muscle'),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoScrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.availableExercises.length,
          itemBuilder: (context, index) {
            final exercise = controller.availableExercises[index];
            return _ExerciseListItem(
              exercise: exercise,
              isSelected: controller.selectedExercises.contains(exercise),
              onTap: () => controller.toggleExercise(exercise),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey3,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
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
          ],
        ),
      ),
    );
  }
}