import '../services/goal_service.dart';

class WorkoutGoalIntegration {
  final GoalService _goalService = GoalService();

  /// Call this method when a workout session is completed
  /// This will automatically update relevant active goals
  Future<void> onWorkoutCompleted({
    required String userID,
    required String sessionId,
    required String workoutTitle,
    required double caloriesBurned,
    required double durationMinutes,
  }) async {
    try {
      await _goalService.autoUpdateFromSession(
        userID: userID,
        sessionId: sessionId,
        sessionTitle: workoutTitle,
        calories: caloriesBurned,
        durationMinutes: durationMinutes,
      );

      print('✅ Goals auto-updated from workout: $workoutTitle');
    } catch (e) {
      print('❌ Error auto-updating goals: $e');
      // Don't throw - we don't want workout completion to fail if goal update fails
    }
  }
}

// catetan dari mas claude :

/*
 * INTEGRATION GUIDE:
 *
 * Add this code to your workout completion handler
 * (typically in workout_summary_page.dart or workout_session_service.dart):
 *
 * import 'package:your_app/services/workout_goal_integration.dart';
 *
 * // After successfully saving the workout session
 * final integration = WorkoutGoalIntegration();
 * await integration.onWorkoutCompleted(
 *   userID: userID,
 *   sessionId: session.id,
 *   workoutTitle: session.workoutTitle,
 *   caloriesBurned: totalCaloriesBurned,  // Calculate from exercises
 *   durationMinutes: session.endTime!.difference(session.startTime).inMinutes.toDouble(),
 * );
 *
 * EXAMPLE FOR YOUR ACTIVE_WORKOUT_PAGE.DART:
 *
 * Future<void> _completeWorkout() async {
 *   // Your existing code to save the session
 *   await workoutSessionService.completeSession(sessionId);
 *
 *   // Calculate total calories from all exercises
 *   double totalCalories = exercises.fold(0, (sum, ex) => sum + (ex.calories ?? 0));
 *
 *   // Auto-update goals
 *   final integration = WorkoutGoalIntegration();
 *   await integration.onWorkoutCompleted(
 *     userID: FirebaseAuth.instance.currentUser!.uid,
 *     sessionId: sessionId,
 *     workoutTitle: workoutTitle,
 *     caloriesBurned: totalCalories,
 *     durationMinutes: DateTime.now().difference(startTime).inMinutes.toDouble(),
 *   );
 *
 *   // Navigate to summary or home
 *   Navigator.of(context).pushReplacement(
 *     MaterialPageRoute(builder: (_) => WorkoutSummaryPage(...))
 *   );
 * }
 */