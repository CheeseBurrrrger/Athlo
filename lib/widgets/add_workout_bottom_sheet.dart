import 'package:athlo/models/custom_workout.dart' hide CustomWorkout;
import 'package:athlo/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import '../services/workout_storage_service.dart';
import '../services/exercise_db_service.dart';
import '../services/custom_workout_service.dart';
import '../models/muscle.dart';
import '../models/exercise.dart';
import '../models/custom_workout.dart';

class AddWorkoutBottomSheet extends StatefulWidget {
  const AddWorkoutBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends State<AddWorkoutBottomSheet> {
  WorkoutService workoutService = new WorkoutService();
  final ExerciseDBService _exerciseDBService = ExerciseDBService();
  final WorkoutStorageService _storageService = WorkoutStorageService();

  String? selectedMuscle;
  String? selectedLevel;
  List<Exercise> availableExercises = [];
  Set<Exercise> selectedExercises = {};

  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  List<Muscle>? _muscles;
  bool _isLoadingMuscles = false;
  bool _isLoadingExercises = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMuscles();
  }

  Future<void> _loadMuscles() async {
    setState(() {
      _isLoadingMuscles = true;
      _errorMessage = null;
    });

    try {
      final muscles = await _exerciseDBService.getMuscles();
      setState(() {
        _muscles = muscles;
        _isLoadingMuscles = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMuscles = false;
      });
    }
  }

  Future<void> _loadExercises(String muscleName) async {
    setState(() {
      _isLoadingExercises = true;
      availableExercises = [];
      selectedExercises.clear();
    });

    try {
      final exercises = await _exerciseDBService.getExercisesByMuscle(muscleName);
      setState(() {
        availableExercises = exercises.cast<Exercise>();
        _isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: $e';
        _isLoadingExercises = false;
      });

      if (mounted) {
        _showErrorDialog('Failed to load exercises: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (nameController.text.isEmpty) {
      _showErrorDialog('Please enter workout name');
      return;
    }

    if (durationController.text.isEmpty) {
      _showErrorDialog('Please enter duration');
      return;
    }

    if (selectedMuscle == null) {
      _showErrorDialog('Please select target muscle');
      return;
    }

    if (selectedLevel == null) {
      _showErrorDialog('Please select level');
      return;
    }

    if (selectedExercises.isEmpty) {
      _showErrorDialog('Please select at least one exercise');
      return;
    }

    var workout = CustomWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uId: authService.value.currentUser!.uid.toString(),
      title: nameController.text,
      duration: '${durationController.text} min',
      level: selectedLevel!,
      targetMuscle: selectedMuscle!,
      exercises: selectedExercises.toList(),
      color: _getLevelColor(selectedLevel!),
      createdAt: DateTime.now(),
    );

    try {
      workoutService.add(workout);
      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessDialog('Workout created successfully! 💪');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to save workout: $e');
      }
    }
  }

  String _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return '0xFF6E8CFB';
      case 'Intermediate':
        return '0xFF636CCB';
      case 'Advanced':
        return '0xFF50589C';
      default:
        return '0xFF3C467B';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    super.dispose();
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            CupertinoNavigationBar(
              backgroundColor: CupertinoColors.systemBackground,
              border: null,
              middle: const Text(
                'Add Custom Workout',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Content
            Expanded(
              child: CupertinoScrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workout Name
                      const Text(
                        'Workout Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: nameController,
                        placeholder: 'Enter workout name',
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            CupertinoIcons.sportscourt,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Duration
                      const Text(
                        'Duration (minutes)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: durationController,
                        placeholder: 'Enter duration',
                        keyboardType: TextInputType.number,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            CupertinoIcons.time,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Level Selection
                      const Text(
                        'Select Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLevelSelector(),
                      const SizedBox(height: 20),

                      // Target Muscle
                      const Text(
                        'Target Muscle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMuscleDropdown(),
                      const SizedBox(height: 20),

                      // Exercise Selection
                      if (selectedMuscle != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Exercises',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (selectedExercises.isNotEmpty)
                              Text(
                                '${selectedExercises.length} selected',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (availableExercises.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (selectedExercises.length < availableExercises.length)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: const Text('Select All'),
                                  onPressed: () {
                                    setState(() {
                                      selectedExercises = Set.from(availableExercises);
                                    });
                                  },
                                ),
                              if (selectedExercises.isNotEmpty)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: const Text('Clear'),
                                  onPressed: () {
                                    setState(() {
                                      selectedExercises.clear();
                                    });
                                  },
                                ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        _buildExerciseList(),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom button
            Container(
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
                    onPressed: _saveWorkout,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    final levels = [
      {'label': 'Beginner', 'color': const Color(0xFF6E8CFB)},
      {'label': 'Intermediate', 'color': const Color(0xFF636CCB)},
      {'label': 'Advanced', 'color': const Color(0xFF50589C)},
    ];

    return Row(
      children: levels.map((level) {
        final isSelected = selectedLevel == level['label'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedLevel = level['label'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (level['color'] as Color)
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? (level['color'] as Color)
                        : CupertinoColors.systemGrey4,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  level['label'] as String,
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
    );
  }

  Widget _buildMuscleDropdown() {
    if (_isLoadingMuscles) {
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

    if (_muscles == null || _muscles!.isEmpty) {
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
      onTap: () => _showMusclePicker(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.scope,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedMuscle?.toUpperCase() ?? 'Select target muscle',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedMuscle != null
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

  void _showMusclePicker() {
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (selectedMuscle != null) {
                        _loadExercises(selectedMuscle!);
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
                  setState(() {
                    selectedMuscle = _muscles![index].name;
                  });
                },
                children: _muscles!.map((muscle) {
                  return Center(
                    child: Text(muscle.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_isLoadingExercises) {
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

    if (availableExercises.isEmpty) {
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
          itemCount: availableExercises.length,
          itemBuilder: (context, index) {
            final exercise = availableExercises[index];
            final isSelected = selectedExercises.contains(exercise);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedExercises.remove(exercise);
                  } else {
                    selectedExercises.add(exercise);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
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
          },
        ),
      ),
    );
  }
}