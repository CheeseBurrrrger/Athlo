import 'package:flutter/cupertino.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/custom_workout_service.dart';
import '../../data/services/exercise_db_service.dart';
import '../../domain/models/custom_workout.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/muscle.dart';

class AddWorkoutController extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  final ExerciseDBService _exerciseDBService = ExerciseDBService();

  // Form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  // State
  String? _selectedMuscle;
  String? _selectedLevel;
  List<Muscle> _muscles = [];
  List<Exercise> _availableExercises = [];
  Set<Exercise> _selectedExercises = {};

  // Loading states
  bool _isLoadingMuscles = false;
  bool _isLoadingExercises = false;
  String? _errorMessage;

  // Getters
  String? get selectedMuscle => _selectedMuscle;
  String? get selectedLevel => _selectedLevel;
  List<Muscle> get muscles => _muscles;
  List<Exercise> get availableExercises => _availableExercises;
  Set<Exercise> get selectedExercises => _selectedExercises;
  bool get isLoadingMuscles => _isLoadingMuscles;
  bool get isLoadingExercises => _isLoadingExercises;
  String? get errorMessage => _errorMessage;

  void setLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setMuscle(String muscle) {
    _selectedMuscle = muscle;
    notifyListeners();
  }

  void toggleExercise(Exercise exercise) {
    if (_selectedExercises.contains(exercise)) {
      _selectedExercises.remove(exercise);
    } else {
      _selectedExercises.add(exercise);
    }
    notifyListeners();
  }

  void selectAllExercises() {
    _selectedExercises = Set.from(_availableExercises);
    notifyListeners();
  }

  void clearExercises() {
    _selectedExercises.clear();
    notifyListeners();
  }

  Future<void> loadMuscles() async {
    _isLoadingMuscles = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _muscles = await _exerciseDBService.getMuscles();
      _isLoadingMuscles = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingMuscles = false;
      notifyListeners();
    }
  }

  Future<void> loadExercises(String muscleName) async {
    _isLoadingExercises = true;
    _availableExercises = [];
    _selectedExercises.clear();
    notifyListeners();

    try {
      final exercises = await _exerciseDBService.getExercisesByMuscle(
        muscleName,
      );
      _availableExercises = exercises.cast<Exercise>();
      _isLoadingExercises = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load exercises: $e';
      _isLoadingExercises = false;
      notifyListeners();
      rethrow;
    }
  }

  String? validateForm() {
    if (nameController.text.isEmpty) {
      return 'Please enter workout name';
    }
    if (durationController.text.isEmpty) {
      return 'Please enter duration';
    }
    if (_selectedMuscle == null) {
      return 'Please select target muscle';
    }
    if (_selectedLevel == null) {
      return 'Please select level';
    }
    if (_selectedExercises.isEmpty) {
      return 'Please select at least one exercise';
    }
    return null;
  }

  Future<void> saveWorkout() async {
    final workout = CustomWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uId: authService.value.currentUser!.uid.toString(),
      title: nameController.text,
      duration: '${durationController.text} min',
      level: _selectedLevel!,
      targetMuscle: _selectedMuscle!,
      exercises: _selectedExercises.toList(),
      color: _getLevelColor(_selectedLevel!),
      createdAt: DateTime.now(),
    );

    _workoutService.add(workout);
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
}
