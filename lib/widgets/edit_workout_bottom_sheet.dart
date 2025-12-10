import 'package:athlo/services/auth_service.dart';
import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final ExerciseDBService _apiService = ExerciseDBService();
  final WorkoutStorageService _storageService = WorkoutStorageService();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading muscles: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: $e')),
        );
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
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
        createdAt: widget.workout.createdAt, // Keep original creation date
      );

      await _storageService.updateWorkout(updatedWorkout);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating workout: $e')),
        );
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
        color: Colors.white,
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
              color: Colors.grey.shade300,
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
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout Name
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Workout Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.fitness_center),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a workout name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Duration
                    TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration (e.g., 45-60 min)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Level
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'Fitness Level',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.bar_chart),
                      ),
                      items: levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    isLoadingMuscles
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                      value: _selectedMuscle,
                      decoration: InputDecoration(
                        labelText: 'Target Muscle',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.track_changes),
                      ),
                      items: muscles.map((muscle) {
                        return DropdownMenuItem(
                          value: muscle.name,
                          child: Text(muscle.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMuscle = value!;
                          _selectedExercises.clear();
                        });
                        _loadExercises(value!);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Color Selection
                    const Text(
                      'Workout Color',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: availableColors[_selectedColorIndex].withOpacity(0.1),
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
                            color: availableColors[_selectedColorIndex].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: availableColors[_selectedColorIndex].withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                    OutlinedButton.icon(
                      onPressed: () => _showExercisePicker(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercises'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: availableColors[_selectedColorIndex],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: isLoadingExercises
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableExercises.length,
                itemBuilder: (context, index) {
                  final exercise = availableExercises[index];
                  final isSelected = _selectedExercises.any((e) => e.name == exercise.name);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? availableColors[_selectedColorIndex]
                            : Colors.grey.shade200,
                        child: Icon(
                          isSelected ? Icons.check : Icons.fitness_center,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(exercise.equipment),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.removeWhere((e) => e.name == exercise.name);
                          } else {
                            _selectedExercises.add(exercise);
                          }
                        });
                        Navigator.pop(context);
                      },
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
}