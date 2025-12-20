import 'package:athlo/domain/constants/workout_levels.dart';
import 'package:flutter/cupertino.dart';

class WorkoutLevelSelector extends StatelessWidget {
  final String? selectedLevel;
  final ValueChanged<String> onLevelChanged;

  const WorkoutLevelSelector({
    Key? key,
    required this.selectedLevel,
    required this.onLevelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = WorkoutLevels.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: levels.map((level) {
            final isSelected = selectedLevel == level.label;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onLevelChanged(level.label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? level.color
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? level.color
                            : CupertinoColors.systemGrey4,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      level.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}