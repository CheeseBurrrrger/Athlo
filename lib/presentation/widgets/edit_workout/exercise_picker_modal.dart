import 'package:flutter/cupertino.dart';
import '../../controllers/edit_workout_controller.dart';
import '../../../domain/models/exercise.dart';

class ExercisePickerModal extends StatefulWidget {
  final EditWorkoutController controller;

  const ExercisePickerModal({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<ExercisePickerModal> {
  void _showFeedback(String message, bool isSuccess) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSuccess
                ? widget.controller.selectedColor
                : CupertinoColors.systemRed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.minus_circle_fill,
                color: CupertinoColors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Container(height: 0.5, color: CupertinoColors.systemGrey4),
          Expanded(child: _buildExerciseList()),
        ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Exercises',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Done'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoadingExercises) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.controller.availableExercises.length,
          itemBuilder: (context, index) {
            final exercise = widget.controller.availableExercises[index];
            return _ExerciseItem(
              exercise: exercise,
              controller: widget.controller,
              onToggle: () {
                setState(() {
                  widget.controller.toggleExercise(exercise);
                  final isSelected = widget.controller.isExerciseSelected(exercise);
                  _showFeedback(
                    '${exercise.name} ${isSelected ? 'added' : 'removed'}',
                    isSelected,
                  );
                });
              },
            );
          },
        );
      },
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final EditWorkoutController controller;
  final VoidCallback onToggle;

  const _ExerciseItem({
    required this.exercise,
    required this.controller,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.isExerciseSelected(exercise);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? controller.selectedColor.withOpacity(0.15)
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? controller.selectedColor
                  : CupertinoColors.systemGrey5,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? controller.selectedColor
                      : CupertinoColors.systemGrey4,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected
                      ? CupertinoIcons.check_mark
                      : CupertinoIcons.sportscourt,
                  color: CupertinoColors.white,
                  size: 20,
                ),
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
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      exercise.equipment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: controller.selectedColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Added',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}