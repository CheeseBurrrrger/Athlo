import 'package:flutter/cupertino.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/custom_workout_service.dart';
import '../../data/services/exercise_db_service.dart';
import '../../domain/models/custom_workout.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/muscle.dart';

class EditWorkoutController extends ChangeNotifier {
  final CustomWorkout originalWorkout;
  final WorkoutService _workoutService = WorkoutService();
  final ExerciseDBService _exerciseDBService = ExerciseDBService();

  // Form controllers
  late TextEditingController titleController;
  late TextEditingController durationController;

  // State
  late String _selectedLevel;
  late String _selectedMuscle;
  late int _selectedColorIndex;
  late List<Exercise> _selectedExercises;

  List<Muscle> _muscles = [];
  List<Exercise> _availableExercises = [];
  bool _isLoadingMuscles = true;
  bool _isLoadingExercises = false;

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

  // Getters
  String get selectedLevel => _selectedLevel;
  String get selectedMuscle => _selectedMuscle;
  int get selectedColorIndex => _selectedColorIndex;
  List<Exercise> get selectedExercises => _selectedExercises;
  List<Muscle> get muscles => _muscles;
  List<Exercise> get availableExercises => _availableExercises;
  bool get isLoadingMuscles => _isLoadingMuscles;
  bool get isLoadingExercises => _isLoadingExercises;
  Color get selectedColor => availableColors[_selectedColorIndex];

  EditWorkoutController({required this.originalWorkout}) {
    _initializeFromWorkout();
  }

  void _initializeFromWorkout() {
    titleController = TextEditingController(text: originalWorkout.title);
    durationController = TextEditingController(text: originalWorkout.duration);
    _selectedLevel = originalWorkout.level;
    _selectedMuscle = originalWorkout.targetMuscle;
    _selectedExercises = List.from(originalWorkout.exercises);

    final Color workoutColor = _getColorFromHex(originalWorkout.color);
    _selectedColorIndex = availableColors.indexWhere(
          (color) => color.value == workoutColor.value,
    );
    if (_selectedColorIndex == -1) _selectedColorIndex = 0;
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      return const Color(0xFF3C467B);
    }
  }

  void setLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setMuscle(String muscle) {
    _selectedMuscle = muscle;
    notifyListeners();
  }

  void setColorIndex(int index) {
    _selectedColorIndex = index;
    notifyListeners();
  }

  void addExercise(Exercise exercise) {
    if (!_selectedExercises.any((e) => e.name == exercise.name)) {
      _selectedExercises.add(exercise);
      notifyListeners();
    }
  }

  void removeExercise(Exercise exercise) {
    _selectedExercises.removeWhere((e) => e.name == exercise.name);
    notifyListeners();
  }

  bool isExerciseSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.name == exercise.name);
  }

  void toggleExercise(Exercise exercise) {
    if (isExerciseSelected(exercise)) {
      removeExercise(exercise);
    } else {
      addExercise(exercise);
    }
  }

  Future<void> loadMuscles() async {
    _isLoadingMuscles = true;
    notifyListeners();

    try {
      _muscles = await _exerciseDBService.getMuscles();
      _isLoadingMuscles = false;
      notifyListeners();

      await loadExercises(_selectedMuscle);
    } catch (e) {
      _isLoadingMuscles = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadExercises(String muscleName) async {
    _isLoadingExercises = true;
    notifyListeners();

    try {
      final exercises = await _exerciseDBService.getExercisesByMuscle(muscleName);
      _availableExercises = exercises.cast<Exercise>();
      _isLoadingExercises = false;
      notifyListeners();
    } catch (e) {
      _isLoadingExercises = false;
      notifyListeners();
      rethrow;
    }
  }

  String? validateForm() {
    if (titleController.text.isEmpty) {
      return 'Please enter a workout name';
    }
    if (durationController.text.isEmpty) {
      return 'Please enter duration';
    }
    if (_selectedExercises.isEmpty) {
      return 'Please select at least one exercise';
    }
    return null;
  }

  Future<void> saveWorkout() async {
    final updatedWorkout = CustomWorkout(
      id: originalWorkout.id,
      uId: authService.value.currentUser!.uid,
      title: titleController.text,
      duration: durationController.text,
      level: _selectedLevel,
      targetMuscle: _selectedMuscle,
      exercises: _selectedExercises,
      color: '0x${availableColors[_selectedColorIndex].value.toRadixString(16)}',
      createdAt: originalWorkout.createdAt,
    );

    await _workoutService.edit(updatedWorkout);
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    super.dispose();
  }
}