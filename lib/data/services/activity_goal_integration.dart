import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_progress_entry.dart';
import '../../domain/logic/activity_parser.dart';
import 'goal_service.dart';

class ActivityGoalIntegration {
  final GoalService _goalService = GoalService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncActivitiesWithGoals(String userID) async {
    try {
      print('🔄 Starting activity sync for user: $userID');

      final activitiesSnapshot = await _firestore
          .collection('activities')
          .where('userName', isEqualTo: await _getUserDisplayName(userID))
          .orderBy('createdAt', descending: false)
          .get();

      if (activitiesSnapshot.docs.isEmpty) {
        print('✅ No activities found to sync');
        return;
      }

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

      for (var activityDoc in activitiesSnapshot.docs) {
        final activityData = activityDoc.data();
        final activityId = activityDoc.id;

        final alreadySynced = activityData['syncedToGoals'] == true;
        if (alreadySynced) continue;

        final activityDate = (activityData['createdAt'] as Timestamp?)?.toDate();
        if (activityDate == null) continue;

        final calories = ActivityParser.parseDouble(activityData['calories']);
        final time = ActivityParser.parseTimeToMinutes(activityData['time'] as String?);

        for (var goal in goals) {
          if (activityDate.isBefore(goal.startDate) ||
              activityDate.isAfter(goal.endDate)) {
            continue;
          }

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

        await activityDoc.reference.update({'syncedToGoals': true});
      }

      print('✅ Activity sync completed: $syncedCount updates made');
    } catch (e) {
      print('❌ Error syncing activities with goals: $e');
    }
  }

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

      final caloriesValue = ActivityParser.parseDouble(calories);
      final timeValue = ActivityParser.parseTimeToMinutes(time);

      for (var goal in goals) {
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

      await _firestore
          .collection('activities')
          .doc(activityId)
          .update({'syncedToGoals': true});

    } catch (e) {
      print('❌ Error processing new activity: $e');
    }
  }

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

  Future<String> _getUserDisplayName(String userID) async {
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
}