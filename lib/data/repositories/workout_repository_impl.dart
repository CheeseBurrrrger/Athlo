import 'package:athlo/data/models/custom_workout_model.dart';
import 'package:athlo/domain/entities/custom_workout.dart';
import 'package:athlo/domain/repositories/workout_repository.dart';
import 'package:athlo/services/custom_workout_service.dart';
import 'package:athlo/services/workout_session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutService workoutService;
  final WorkoutSessionService sessionService;

  WorkoutRepositoryImpl(
      this.workoutService,
      this.sessionService,
      );

  @override
  Stream<List<CustomWorkout>> getUserWorkouts(String userId) {
    return workoutService.readSpecificUser(userId);
  }

  @override
  Future<void> deleteWorkout(String workoutId) {
    return workoutService.delete(workoutId);
  }

  @override
  Future<Map<String, dynamic>> getWorkoutStats(String userId) {
    return sessionService.getWorkoutStats(userId);
  }

  @override
  Future<void> updateWorkout(CustomWorkout workout) {
    // TODO: implement updateWorkout
    throw UnimplementedError();
  }
}
