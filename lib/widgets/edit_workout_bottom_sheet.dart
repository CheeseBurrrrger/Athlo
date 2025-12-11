import 'package:athlo/services/auth_service.dart';
import 'package:athlo/services/custom_workout_service.dart';
import 'package:flutter/cupertino.dart';
import '../models/custom_workout.dart';
import '../models/exercise.dart';
import '../models/muscle.dart';
import '../services/exercise_db_service.dart';
import '../services/workout_storage_service.dart';

class EditWorkoutBottomSheet extends StatefulWidget {
  final CustomWorkout workout;

  const EditWorkoutBottomSheet({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<EditWorkoutBottomSheet> createState() => _EditWorkoutBottomSheetState();
}

class _EditWorkoutBottomSheetState extends State<EditWorkoutBottomSheet> {
  final ExerciseDBService _apiService = ExerciseDBService();
  WorkoutService workoutService = new WorkoutService();

  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late String _selectedLevel;
  late String _selectedMuscle;
  late int _selectedColorIndex;
  late List<Exercise> _selectedExercises;

  List<Muscle> muscles = [];
  List<Exercise> availableExercises = [];
  bool isLoadingMuscles = true;
  bool isLoadingExercises = false;

  final List<Color> availableColors = [
    const Color(0xFF6E8CFB),
    const Color(0xFF636CCB),
    const Color(0xFF50589C),
    const Color(0xFF3C467B),
    const Color(0xFF4CAF50),
    const Color(0xFFFF6B6B),
    const Color(0xFFFFB84D),
    const Color(0xFF9B59B6),
  ];

  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();

    // Initialize with workout data
    _titleController = TextEditingController(text: widget.workout.title);
    _durationController = TextEditingController(text: widget.workout.duration);
    _selectedLevel = widget.workout.level;
    _selectedMuscle = widget.workout.targetMuscle;
    _selectedExercises = List.from(widget.workout.exercises);

    // Find the color index
    final Color workoutColor = _getColorFromHex(widget.workout.color);
    _selectedColorIndex = availableColors.indexWhere(
          (color) => color.value == workoutColor.value,
    );
    if (_selectedColorIndex == -1) _selectedColorIndex = 0;

    _loadMuscles();
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      return const Color(0xFF3C467B);
    }
  }

  Future<void> _loadMuscles() async {
    setState(() => isLoadingMuscles = true);
    try {
      final fetchedMuscles = await _apiService.getMuscles();
      setState(() {
        muscles = fetchedMuscles;
        isLoadingMuscles = false;
      });

      // Load exercises for the current muscle
      await _loadExercises(_selectedMuscle);
    } catch (e) {
      setState(() => isLoadingMuscles = false);
      if (mounted) {
        _showErrorDialog('Error loading muscles: $e');
      }
    }
  }

  Future<void> _loadExercises(String muscleName) async {
    setState(() => isLoadingExercises = true);
    try {
      final exercises = await _apiService.getExercisesByMuscle(muscleName);
      setState(() {
        availableExercises = exercises.cast<Exercise>();
        isLoadingExercises = false;
      });
    } catch (e) {
      setState(() => isLoadingExercises = false);
      if (mounted) {
        _showErrorDialog('Error loading exercises: $e');
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

  Future<void> _saveWorkout() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Please enter a workout name');
      return;
    }

    if (_durationController.text.isEmpty) {
      _showErrorDialog('Please enter duration');
      return;
    }

    if (_selectedExercises.isEmpty) {
      _showErrorDialog('Please select at least one exercise');
      return;
    }

    try {
      final updatedWorkout = CustomWorkout(
        id: widget.workout.id,
        uId: authService.value.currentUser!.uid,
        title: _titleController.text,
        duration: _durationController.text,
        level: _selectedLevel,
        targetMuscle: _selectedMuscle,
        exercises: _selectedExercises,
        color: '0x${availableColors[_selectedColorIndex].value.toRadixString(16)}',
        createdAt: widget.workout.createdAt,
      );

      await workoutService.edit(updatedWorkout);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error updating workout: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Workout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Container(
            height: 0.5,
            color: CupertinoColors.systemGrey4,
          ),

          // Form content
          Expanded(
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
                    controller: _titleController,
                    placeholder: 'Enter workout name',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        CupertinoIcons.sportscourt,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Duration
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _durationController,
                    placeholder: 'e.g., 45-60 min',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        CupertinoIcons.time,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Level
                  const Text(
                    'Fitness Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showLevelPicker(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.chart_bar,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedLevel,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Target Muscle
                  const Text(
                    'Target Muscle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isLoadingMuscles
                      ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                      : GestureDetector(
                    onTap: () => _showMusclePicker(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.scope,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedMuscle,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Color Selection
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
                    children: availableColors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final color = entry.value;
                      final isSelected = _selectedColorIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
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

                  const SizedBox(height: 24),

                  // Exercises Section
                  Row(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: availableColors[_selectedColorIndex]
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedExercises.length} selected',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: availableColors[_selectedColorIndex],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Selected Exercises
                  if (_selectedExercises.isNotEmpty)
                    ..._selectedExercises.map((exercise) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: availableColors[_selectedColorIndex]
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: availableColors[_selectedColorIndex]
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.sportscourt,
                              color: availableColors[_selectedColorIndex],
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
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.remove(exercise);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Add Exercise Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showExercisePicker(),
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
                            color: availableColors[_selectedColorIndex],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Exercises',
                            style: TextStyle(
                              color: availableColors[_selectedColorIndex],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom action button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.systemGrey4,
                  width: 0.5,
                ),
              ),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveWorkout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: availableColors[_selectedColorIndex],
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
          ),
        ],
      ),
    );
  }

  void _showLevelPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: levels.indexOf(_selectedLevel),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedLevel = levels[index];
                  });
                },
                children: levels.map((level) => Center(child: Text(level))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMusclePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                      _selectedExercises.clear();
                      _loadExercises(_selectedMuscle);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: muscles.indexWhere(
                        (m) => m.name == _selectedMuscle,
                  ),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedMuscle = muscles[index].name;
                  });
                },
                children: muscles
                    .map((muscle) => Center(child: Text(muscle.name)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExercisePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
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
            ),
            Container(
              height: 0.5,
              color: CupertinoColors.systemGrey4,
            ),
            Expanded(
              child: isLoadingExercises
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableExercises.length,
                itemBuilder: (context, index) {
                  final exercise = availableExercises[index];
                  final isSelected = _selectedExercises
                      .any((e) => e.name == exercise.name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.removeWhere(
                                    (e) => e.name == exercise.name);
                            _showFeedbackToast('${exercise.name} removed', isSuccess: false);
                          } else {
                            _selectedExercises.add(exercise);
                            _showFeedbackToast('${exercise.name} added', isSuccess: true);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? availableColors[_selectedColorIndex]
                              .withOpacity(0.15)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? availableColors[_selectedColorIndex]
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
                                    ? availableColors[_selectedColorIndex]
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
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isSelected
                                          ? CupertinoColors.black
                                          : CupertinoColors.black,
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
                                  color: availableColors[_selectedColorIndex],
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackToast(String message, {required bool isSuccess}) {
    // Remove any existing overlays
    if (mounted) {
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
                  ? availableColors[_selectedColorIndex]
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

      // Auto-remove after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        overlayEntry.remove();
      });
    }
  }
}