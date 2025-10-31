import 'package:flutter/material.dart';
import '../services/exercise_db_service.dart';
import '../services/workout_storage_service.dart';
import '../models/muscle.dart';
import '../models/exercise.dart';
import '../models/custom_workout.dart';
import 'level_chip.dart';

class AddWorkoutBottomSheet extends StatefulWidget {
  const AddWorkoutBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends State<AddWorkoutBottomSheet> {
  final ExerciseDBService _exerciseDBService = ExerciseDBService();
  final WorkoutStorageService _storageService = WorkoutStorageService();

  String? selectedMuscle;
  String? selectedLevel;
  List<Exercise> availableExercises = [];
  Set<Exercise> selectedExercises = {}; // Changed to Set for better performance

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exercises: $e')),
        );
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter workout name')),
      );
      return;
    }

    if (durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter duration')),
      );
      return;
    }

    if (selectedMuscle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select target muscle')),
      );
      return;
    }

    if (selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select level')),
      );
      return;
    }

    if (selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }

    final workout = CustomWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: nameController.text,
      duration: '${durationController.text} min',
      level: selectedLevel!,
      targetMuscle: selectedMuscle!,
      exercises: selectedExercises.toList(),
      color: _getLevelColor(selectedLevel!),
      createdAt: DateTime.now(),
    );

    try {
      await _storageService.saveWorkout(workout);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout created successfully! 💪')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save workout: $e')),
        );
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Custom Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Workout Name',
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Select Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: [
                      LevelChip(
                        label: 'Beginner',
                        color: const Color(0xFF6E8CFB),
                        isSelected: selectedLevel == 'Beginner',
                        onSelected: (selected) {
                          setState(() {
                            selectedLevel = selected ? 'Beginner' : null;
                          });
                        },
                      ),
                      LevelChip(
                        label: 'Intermediate',
                        color: const Color(0xFF636CCB),
                        isSelected: selectedLevel == 'Intermediate',
                        onSelected: (selected) {
                          setState(() {
                            selectedLevel = selected ? 'Intermediate' : null;
                          });
                        },
                      ),
                      LevelChip(
                        label: 'Advanced',
                        color: const Color(0xFF50589C),
                        isSelected: selectedLevel == 'Advanced',
                        onSelected: (selected) {
                          setState(() {
                            selectedLevel = selected ? 'Advanced' : null;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Target Muscles Dropdown
                  const Text(
                    'Target Muscle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _buildMuscleDropdown(),

                  const SizedBox(height: 16),

                  // Exercise Selection
                  if (selectedMuscle != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Exercises',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            if (selectedExercises.isNotEmpty)
                              Text(
                                '${selectedExercises.length} selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (availableExercises.isNotEmpty && selectedExercises.length < availableExercises.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedExercises = availableExercises.map((e) => e.name).cast<Exercise>().toSet();
                                  });
                                },
                                child: const Text('Select All'),
                              ),
                            if (selectedExercises.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedExercises.clear();
                                  });
                                },
                                child: const Text('Clear'),
                              ),
                          ],
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

          // Bottom button
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C467B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Workout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleDropdown() {
    if (_isLoadingMuscles) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No muscles available'),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedMuscle,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.track_changes),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'Select target muscle',
      ),
      isExpanded: true,
      items: _muscles!.map((muscle) {
        return DropdownMenuItem<String>(
          value: muscle.name,
          child: Text(muscle.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMuscle = value;
          if (value != null) {
            _loadExercises(value);
          }
        });
      },
    );
  }

  Widget _buildExerciseList() {
    if (_isLoadingExercises) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No exercises available for this muscle'),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: availableExercises.length,
        itemBuilder: (context, index) {
          final exercise = availableExercises[index];
          final isSelected = selectedExercises.contains(exercise);

          return CheckboxListTile(
            title: Text(
              exercise.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              exercise.equipment,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            value: isSelected,
            activeColor: const Color(0xFF3C467B),
            dense: true,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedExercises.add(exercise);
                } else {
                  selectedExercises.remove(exercise);
                }
              });
            },
          );
        },
      ),
    );
  }
}