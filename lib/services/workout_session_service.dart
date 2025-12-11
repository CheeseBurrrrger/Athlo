import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';

class WorkoutSessionService {
  final CollectionReference _sessionsRef =
  FirebaseFirestore.instance.collection('workout_sessions');

  // Save a workout session
  Future<void> saveSession(WorkoutSession session) async {
    try {
      await _sessionsRef.doc(session.id).set(session.toJson());
    } catch (e) {
      print('Error saving workout session: $e');
      rethrow;
    }
  }

  // Get user's workout history
  Stream<List<WorkoutSession>> getUserSessions(String userId) {
    return _sessionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get specific session
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

  // Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    final sessions = await _sessionsRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();

    int totalWorkouts = sessions.docs.length;
    int totalMinutes = 0;

    for (var doc in sessions.docs) {
      final session = WorkoutSession.fromJson(doc.data() as Map<String, dynamic>);
      totalMinutes += session.duration.inMinutes;
    }

    return {
      'totalWorkouts': totalWorkouts,
      'totalMinutes': totalMinutes,
      'averageDuration': totalWorkouts > 0 ? totalMinutes ~/ totalWorkouts : 0,
    };
  }
}