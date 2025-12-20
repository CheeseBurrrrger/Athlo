// import 'package:athlo/data/services/auth_service.dart' hide authService;
// import 'package:athlo/domain/models/custom_workout.dart' hide CustomWorkout;
import '../../domain/models/custom_workout.dart';
import '../../data/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/custom_workout_service.dart';
import '../../data/services/workout_session_service.dart';
import '../../data/services/featured_workout_service.dart';

class WorkoutPageController extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  final FeaturedWorkoutService _featuredService = FeaturedWorkoutService();

  Map<String, dynamic> _stats = {
    'totalWorkouts': 0,
    'totalMinutes': 0,
    'averageDuration': 0,
    'todayMinutes': 0,
    'currentStreak': 0,
  };

  Map<String, dynamic> get stats => _stats;

  Future<void> loadStats() async {
    try {
      final uId = authService.value.currentUser!.uid;
      _stats = await _sessionService.getWorkoutStats(uId);
      notifyListeners();
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Stream<List<CustomWorkout>> getUserWorkouts() {
    final uId = authService.value.currentUser!.uid;
    return _workoutService.readSpecificUser(uId);
  }

  Stream<List<CustomWorkout>>? getFeaturedWorkouts() {
    return _featuredService.readAll();
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _workoutService.delete(workoutId);
  }
}