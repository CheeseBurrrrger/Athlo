import 'package:athlo/domain/entities/custom_workout.dart';

abstract class WorkoutRepository {
  Stream<List<CustomWorkout>> getUserWorkouts(String userId);
  Future<void> updateWorkout(CustomWorkout workout);
  Future<void> deleteWorkout(String id);
}