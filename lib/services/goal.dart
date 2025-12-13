// lib/services/goal_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';
import '../models/goal_progress_entry.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new goal
  Future<Goal> createGoal({
    required String userID,
    required String title,
    required GoalMetric metric,
    required double targetValue,
    required GoalPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    bool autoLink = true,
    bool reminderEnabled = false,
  }) async {
    // Archive existing active goals with same metric and period
    await _archiveExistingGoals(userID, metric, period, startDate, endDate);

    final docRef = _firestore.collection('goals').doc();
    final goal = Goal(
      id: docRef.id,
      userID: userID,
      title: title,
      metric: metric,
      targetValue: targetValue,
      period: period,
      startDate: startDate,
      endDate: endDate,
      autoLink: autoLink,
      reminderEnabled: reminderEnabled,
      createdAt: DateTime.now(),
    );

    await docRef.set(goal.toJson());
    return goal;
  }

  // Archive existing goals with same metric and overlapping period
  Future<void> _archiveExistingGoals(
      String userID,
      GoalMetric metric,
      GoalPeriod period,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final snapshot = await _firestore
        .collection('goals')
        .where('userID', isEqualTo: userID)
        .where('metric', isEqualTo: metric.name)
        .where('status', isEqualTo: GoalStatus.active.name)
        .get();

    for (var doc in snapshot.docs) {
      final goal = Goal.fromJson(doc.data());
      // Check if periods overlap
      if (goal.startDate.isBefore(endDate) && goal.endDate.isAfter(startDate)) {
        await doc.reference.update({'status': GoalStatus.ended.name});
      }
    }
  }

  // Get active goals for user
  Stream<List<Goal>> getActiveGoals(String userID) {
    return _firestore
        .collection('goals')
        .where('status', isEqualTo: GoalStatus.active.name)
        .where('userID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList());
  }

  // Get all goals for user
  Stream<List<Goal>> getAllGoals(String userID) {
    return _firestore
        .collection('goals')
        .where('userID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList());
  }

  // Get goal by ID
  Future<Goal?> getGoal(String goalId) async {
    final doc = await _firestore.collection('goals').doc(goalId).get();
    if (!doc.exists) return null;
    return Goal.fromJson(doc.data()!);
  }

  // Update goal
  Future<void> updateGoal(Goal goal) async {
    await _firestore.collection('goals').doc(goal.id).update(goal.toJson());
  }

  // Add progress to goal (manual or from session)
  Future<void> addProgress({
    required String goalId,
    required double value,
    required ProgressSource source,
    String? sessionId,
    String? sessionTitle,
    String? notes,
  }) async {
    final goal = await getGoal(goalId);
    if (goal == null) return;

    final newValue = goal.currentValue + value;
    final double progressPercentage =
    ((newValue.toDouble() / goal.targetValue.toDouble()) * 100)
        .clamp(0.0, 100.0);

    // Create progress entry
    final entryRef = _firestore
        .collection('goals')
        .doc(goalId)
        .collection('progress')
        .doc();

    final entry = GoalProgressEntry(
      id: entryRef.id,
      goalId: goalId,
      value: value,
      source: source,
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      notes: notes,
      timestamp: DateTime.now(),
      progressPercentage: progressPercentage,
    );

    await entryRef.set(entry.toJson());

    // Update goal current value
    final updatedGoal = goal.copyWith(
      currentValue: newValue,
      status: newValue >= goal.targetValue ? GoalStatus.completed : goal.status,
      completedAt: newValue >= goal.targetValue ? DateTime.now() : null,
    );

    await updateGoal(updatedGoal);
  }

  // Get progress timeline for a goal
  Stream<List<GoalProgressEntry>> getProgressTimeline(String goalId) {
    return _firestore
        .collection('goals')
        .doc(goalId)
        .collection('progress')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GoalProgressEntry.fromJson(doc.data()))
        .toList());
  }

  // Update goal status
  Future<void> updateGoalStatus(String goalId, GoalStatus status) async {
    await _firestore.collection('goals').doc(goalId).update({
      'status': status.name,
      if (status == GoalStatus.completed) 'completedAt': DateTime.now().toIso8601String(),
    });
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    // Delete all progress entries
    final progressSnapshot = await _firestore
        .collection('goals')
        .doc(goalId)
        .collection('progress')
        .get();

    for (var doc in progressSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete goal
    await _firestore.collection('goals').doc(goalId).delete();
  }

  // Auto-update from workout session
  Future<void> autoUpdateFromSession({
    required String userID,
    required String sessionId,
    required String sessionTitle,
    required double calories,
    required double durationMinutes,
  }) async {
    // Get active goals with auto-link enabled
    final snapshot = await _firestore
        .collection('goals')
        .where('userID', isEqualTo: userID)
        .where('status', isEqualTo: GoalStatus.active.name)
        .where('autoLink', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final goal = Goal.fromJson(doc.data());

      // Check if goal period includes current date
      final now = DateTime.now();
      if (now.isAfter(goal.startDate) && now.isBefore(goal.endDate)) {
        double valueToAdd = 0;

        switch (goal.metric) {
          case GoalMetric.calories:
            valueToAdd = calories;
            break;
          case GoalMetric.duration:
            valueToAdd = durationMinutes;
            break;
          case GoalMetric.workouts:
            valueToAdd = 1;
            break;
        }

        if (valueToAdd > 0) {
          await addProgress(
            goalId: goal.id,
            value: valueToAdd,
            source: ProgressSource.session,
            sessionId: sessionId,
            sessionTitle: sessionTitle,
            notes: 'Auto-added from workout session',
          );
        }
      }
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics(String userID) async {
    final snapshot = await _firestore
        .collection('goals')
        .where('userID', isEqualTo: userID)
        .get();

    int totalGoals = snapshot.docs.length;
    int completedGoals = 0;
    int activeGoals = 0;

    for (var doc in snapshot.docs) {
      final goal = Goal.fromJson(doc.data());
      if (goal.status == GoalStatus.completed) completedGoals++;
      if (goal.status == GoalStatus.active) activeGoals++;
    }

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'activeGoals': activeGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0,
    };
  }
}
