import 'package:athlo/domain/entities/custom_workout.dart';
import 'package:athlo/domain/repositories/workout_repository.dart';

class GetUserWorkouts {
  final WorkoutRepository repository;

  GetUserWorkouts(this.repository);

  Stream<List<CustomWorkout>> call(String userId) {
    return repository.getUserWorkouts(userId);
  }
}