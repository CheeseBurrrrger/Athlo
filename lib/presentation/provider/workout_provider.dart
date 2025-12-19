import 'package:athlo/domain/entities/custom_workout.dart';
import 'package:athlo/domain/usecases/get_user_workout.dart';
import 'package:athlo/domain/usecases/delete_user_workout.dart';
import 'package:flutter/cupertino.dart';


class WorkoutProvider extends ChangeNotifier {
  final GetUserWorkouts getUserWorkouts;
  final DeleteWorkout deleteWorkout;
  final UpdateWorkout updateWorkout;

  WorkoutProvider({
    required this.getUserWorkouts,
    required this.deleteWorkout,
    required this.updateWorkout,
  });

  Stream<List<CustomWorkout>> watchUserWorkouts(String userId) {
    return getUserWorkouts(userId);
  }

  Future<void> delete(String workoutId) async {
    await deleteWorkout(workoutId);
  }

  Future<void> update(CustomWorkout workout) async {
    await updateWorkout(workout);
  }
}