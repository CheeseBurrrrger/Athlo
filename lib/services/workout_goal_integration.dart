// lib/services/workout_goal_integration.dart
import '../services/goal_service.dart';
import '../models/workout_session.dart';
import '../models/goal.dart';

class WorkoutGoalIntegration {
  final GoalService _goalService = GoalService();

  /// Call this method when a workout session is completed
  /// This will automatically update relevant active goals
  Future<void> onWorkoutCompleted({
    required String userId,
    required WorkoutSession session,
  }) async {
    try {
      // Calculate workout metrics
      final durationMinutes = session.duration.inMinutes.toDouble();
      final caloriesBurned = _calculateCaloriesFromSession(session);
      final workoutTitle = _getWorkoutTitle(session);

      print('🔄 Syncing workout session to goals...');
      print('   User ID: $userId');
      print('   Session ID: ${session.id}');
      print('   Workout: $workoutTitle');
      print('   Duration: $durationMinutes minutes');
      print('   Calories: $caloriesBurned kcal');

      await _goalService.autoUpdateFromSession(
        userID: userId,
        sessionId: session.id,
        sessionTitle: workoutTitle,
        calories: caloriesBurned,
        durationMinutes: durationMinutes,
      );

      print('✅ Goals auto-updated from workout session');
    } catch (e) {
      print('❌ Error auto-updating goals: $e');
      // Don't throw - we don't want workout completion to fail if goal update fails
    }
  }

  /// Calculate calories burned from a workout session
  /// This is a simple estimation based on exercise count, sets, and duration
  double _calculateCaloriesFromSession(WorkoutSession session) {
    try {
      // Base calculation: ~5 calories per minute of workout
      double baseCalories = session.duration.inMinutes * 5.0;

      // Add bonus for completed exercises and sets
      int totalSets = 0;
      int completedSets = 0;

      for (var exercise in session.exercises) {
        totalSets += exercise.sets.length;
        completedSets += exercise.sets.where((set) => set.isCompleted).length;
      }

      // Bonus: 10 calories per completed set
      double setBonus = completedSets * 10.0;

      // Intensity multiplier based on completion rate
      double completionRate = totalSets > 0 ? completedSets / totalSets : 0;
      double intensityMultiplier = 0.8 + (completionRate * 0.4); // 0.8 to 1.2

      double totalCalories = (baseCalories + setBonus) * intensityMultiplier;

      print('   📊 Calorie calculation:');
      print('      Base: $baseCalories (${session.duration.inMinutes} min × 5)');
      print('      Set bonus: $setBonus ($completedSets sets × 10)');
      print('      Intensity: ${(intensityMultiplier * 100).toStringAsFixed(0)}% (${(completionRate * 100).toStringAsFixed(0)}% completion)');
      print('      Total: ${totalCalories.toStringAsFixed(0)} kcal');

      return totalCalories.roundToDouble();
    } catch (e) {
      print('Error calculating calories: $e');
      // Fallback: 5 calories per minute
      return session.duration.inMinutes * 5.0;
    }
  }

  /// Get a user-friendly workout title
  String _getWorkoutTitle(WorkoutSession session) {
    // Try to use workout ID as title, or generate a default
    if (session.exercises.isNotEmpty) {
      final firstExercise = session.exercises.first.name;
      final exerciseCount = session.exercises.length;

      if (exerciseCount == 1) {
        return firstExercise;
      } else {
        return '$firstExercise + ${exerciseCount - 1} more';
      }
    }

    return 'Workout Session';
  }
}