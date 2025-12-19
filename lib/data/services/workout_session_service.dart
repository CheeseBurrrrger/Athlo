import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/workout_session.dart';

class WorkoutSessionService {
  final CollectionReference _sessionsRef =
  FirebaseFirestore.instance.collection('workout_sessions');

  Future<void> saveSession(WorkoutSession session) async {
    try {
      await _sessionsRef.doc(session.id).set(session.toJson());
    } catch (e) {
      print('Error saving workout session: $e');
      rethrow;
    }
  }

  Stream<List<WorkoutSession>> getUserSessions(String userId) {
    return _sessionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          WorkoutSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<WorkoutSession?> getSession(String sessionId) async {
    try {
      final doc = await _sessionsRef.doc(sessionId).get();
      if (doc.exists) {
        return WorkoutSession.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching session: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    try {
      final sessions = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      int totalWorkouts = sessions.docs.length;
      int totalMinutes = 0;
      int todayMinutes = 0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      for (var doc in sessions.docs) {
        final session =
        WorkoutSession.fromJson(doc.data() as Map<String, dynamic>);
        final durationMinutes = session.duration.inMinutes;
        totalMinutes += durationMinutes;

        if (session.startTime.isAfter(todayStart) &&
            session.startTime.isBefore(todayEnd)) {
          todayMinutes += durationMinutes;
        }
      }

      int currentStreak = await _calculateStreak(userId);

      return {
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'averageDuration':
        totalWorkouts > 0 ? totalMinutes ~/ totalWorkouts : 0,
        'todayMinutes': todayMinutes,
        'currentStreak': currentStreak,
      };
    } catch (e) {
      print('Error getting workout stats: $e');
      return {
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'averageDuration': 0,
        'todayMinutes': 0,
        'currentStreak': 0,
      };
    }
  }

  Future<int> _calculateStreak(String userId) async {
    try {
      final sessions = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('startTime', descending: true)
          .get();

      if (sessions.docs.isEmpty) return 0;

      Set<String> workoutDates = {};
      for (var doc in sessions.docs) {
        final session =
        WorkoutSession.fromJson(doc.data() as Map<String, dynamic>);
        final dateKey =
            '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
        workoutDates.add(dateKey);
      }

      List<DateTime> uniqueDates = workoutDates.map((dateStr) {
        final parts = dateStr.split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }).toList();

      uniqueDates.sort((a, b) => b.compareTo(a));

      int streak = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (uniqueDates.isEmpty) return 0;

      final lastWorkoutDate = uniqueDates[0];
      final daysDifference = todayDate.difference(lastWorkoutDate).inDays;

      if (daysDifference > 1) return 0;

      DateTime expectedDate = todayDate;
      for (var workoutDate in uniqueDates) {
        final diff = expectedDate.difference(workoutDate).inDays;

        if (diff == 0) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (diff == 1 && streak == 0) {
          streak++;
          expectedDate = workoutDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getStatsForDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final sessions = await _sessionsRef
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      int totalWorkouts = sessions.docs.length;
      int totalMinutes = 0;

      for (var doc in sessions.docs) {
        final session =
        WorkoutSession.fromJson(doc.data() as Map<String, dynamic>);
        totalMinutes += session.duration.inMinutes;
      }

      return {
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'averageDuration':
        totalWorkouts > 0 ? totalMinutes ~/ totalWorkouts : 0,
      };
    } catch (e) {
      print('Error getting stats for date range: $e');
      return {
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'averageDuration': 0,
      };
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionsRef.doc(sessionId).delete();
    } catch (e) {
      print('Error deleting session: $e');
      rethrow;
    }
  }
}