import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_progress_entry.dart';
import 'goal_service.dart';

class ActivityGoalIntegration {
  final GoalService _goalService = GoalService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sync all unprocessed activities with goals
  /// Call this when opening the progress tracker page
  Future<void> syncActivitiesWithGoals(String userID) async {
    try {
      print('🔄 Starting activity sync for user: $userID');

      // Get all activities for this user
      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('userName', isEqualTo: await _getUserDisplayName(userID))
          .orderBy('createdAt', descending: false)
          .get();

      if (activitiesSnapshot.docs.isEmpty) {
        print('✅ No activities found to sync');
        return;
      }

      // Get all active goals with auto-link enabled
      final goalsSnapshot = await _firestore
          .collection('goals')
          .where('userID', isEqualTo: userID)
          .where('status', isEqualTo: GoalStatus.active.name)
          .where('autoLink', isEqualTo: true)
          .get();

      if (goalsSnapshot.docs.isEmpty) {
        print('✅ No active auto-linked goals to update');
        return;
      }

      final goals = goalsSnapshot.docs
          .map((doc) => Goal.fromJson(doc.data()))
          .toList();

      int syncedCount = 0;

      // Process each activity
      for (var activityDoc in activitiesSnapshot.docs) {
        final activityData = activityDoc.data();
        final activityId = activityDoc.id;

        // Check if this activity has already been synced
        final alreadySynced = activityData['syncedToGoals'] == true;
        if (alreadySynced) continue;

        final activityDate = (activityData['createdAt'] as Timestamp?)?.toDate();
        if (activityDate == null) continue;

        final calories = _parseDouble(activityData['calories']);
        final time = _parseTimeToMinutes(activityData['time'] as String?);

        // Find matching goals for this activity
        for (var goal in goals) {
          // Check if activity date is within goal period
          if (activityDate.isBefore(goal.startDate) ||
              activityDate.isAfter(goal.endDate)) {
            continue;
          }

          // Check if this activity has already been added to this goal
          final existingEntry = await _checkIfActivityAlreadyAdded(
            goal.id,
            activityId,
          );

          if (existingEntry) continue;

          double valueToAdd = 0;
          String activityTitle = activityData['activityType'] ?? 'Activity';

          switch (goal.metric) {
            case GoalMetric.calories:
              valueToAdd = calories;
              break;
            case GoalMetric.duration:
              valueToAdd = time;
              break;
            case GoalMetric.workouts:
              valueToAdd = 1;
              break;
          }

          if (valueToAdd > 0) {
            await _goalService.addProgress(
              goalId: goal.id,
              value: valueToAdd,
              source: ProgressSource.session,
              sessionId: activityId,
              sessionTitle: activityTitle,
              notes: 'Auto-added from activity: $activityTitle',
            );

            syncedCount++;
            print('✅ Synced activity "$activityTitle" to goal "${goal.title}"');
          }
        }

        // Mark activity as synced
        await activityDoc.reference.update({'syncedToGoals': true});
      }

      print('✅ Activity sync completed: $syncedCount updates made');
    } catch (e) {
      print('❌ Error syncing activities with goals: $e');
      // Don't throw - we don't want sync failure to break the UI
    }
  }

  /// Process a single activity immediately after it's created
  Future<void> processNewActivity({
    required String userID,
    required String activityId,
    required String activityType,
    required String calories,
    required String time,
    required DateTime createdAt,
  }) async {
    try {
      print('🔄 Processing new activity: $activityType');

      // Get active goals with auto-link enabled
      final goalsSnapshot = await _firestore
          .collection('goals')
          .where('userID', isEqualTo: userID)
          .where('status', isEqualTo: GoalStatus.active.name)
          .where('autoLink', isEqualTo: true)
          .get();

      if (goalsSnapshot.docs.isEmpty) {
        print('✅ No active auto-linked goals to update');
        return;
      }

      final goals = goalsSnapshot.docs
          .map((doc) => Goal.fromJson(doc.data()))
          .toList();

      final caloriesValue = _parseDouble(calories);
      final timeValue = _parseTimeToMinutes(time);

      for (var goal in goals) {
        // Check if activity date is within goal period
        if (createdAt.isBefore(goal.startDate) ||
            createdAt.isAfter(goal.endDate)) {
          continue;
        }

        double valueToAdd = 0;

        switch (goal.metric) {
          case GoalMetric.calories:
            valueToAdd = caloriesValue;
            break;
          case GoalMetric.duration:
            valueToAdd = timeValue;
            break;
          case GoalMetric.workouts:
            valueToAdd = 1;
            break;
        }

        if (valueToAdd > 0) {
          await _goalService.addProgress(
            goalId: goal.id,
            value: valueToAdd,
            source: ProgressSource.session,
            sessionId: activityId,
            sessionTitle: activityType,
            notes: 'Auto-added from activity',
          );

          print('✅ Added activity to goal "${goal.title}"');
        }
      }

      // Mark activity as synced
      await _firestore
          .collection('activities')
          .doc(activityId)
          .update({'syncedToGoals': true});

    } catch (e) {
      print('❌ Error processing new activity: $e');
    }
  }

  /// Check if an activity has already been added to a goal
  Future<bool> _checkIfActivityAlreadyAdded(
      String goalId,
      String activityId,
      ) async {
    final snapshot = await _firestore
        .collection('goals')
        .doc(goalId)
        .collection('progress')
        .where('sessionId', isEqualTo: activityId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get user's display name from Firebase Auth
  Future<String> _getUserDisplayName(String userID) async {
    // In a real app, you might want to cache this or get it from Auth
    // For now, we'll get it from Firestore or Auth
    try {
      final userDoc = await _firestore.collection('users').doc(userID).get();
      if (userDoc.exists) {
        return userDoc.data()?['displayName'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error getting display name: $e');
    }
    return 'Unknown User';
  }

  /// Parse calories string to double
  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except decimal point
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  /// Parse time string (e.g., "28:45" or "1:30:45") to minutes
  double _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 0;

    try {
      final parts = timeStr.split(':');

      if (parts.length == 2) {
        // Format: MM:SS
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return minutes + (seconds / 60);
      } else if (parts.length == 3) {
        // Format: HH:MM:SS
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = int.tryParse(parts[2]) ?? 0;
        return (hours * 60) + minutes + (seconds / 60);
      } else {
        // Just a number, assume minutes
        return double.tryParse(timeStr) ?? 0;
      }
    } catch (e) {
      print('Error parsing time: $e');
      return 0;
    }
  }
}