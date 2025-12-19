import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/custom_workout.dart';

class FeaturedWorkoutService {
  final CollectionReference _featuredWorkoutsRef =
  FirebaseFirestore.instance.collection('featured_workouts');

  Future<void> add(CustomWorkout workout) async {
    try {
      await _featuredWorkoutsRef.doc(workout.id).set(workout.toJson());
      print('Featured workout added successfully');
    } catch (e) {
      print('Error adding featured workout: $e');
      rethrow;
    }
  }

  Stream<List<CustomWorkout>>? readAll() {
    try {
      return _featuredWorkoutsRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return CustomWorkout.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      print('Error reading featured workouts stream: $e');
      return null;
    }
  }

  Future<List<CustomWorkout>> getFeaturedWorkouts() async {
    try {
      final snapshot = await _featuredWorkoutsRef.get();
      return snapshot.docs.map((doc) {
        return CustomWorkout.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting featured workouts: $e');
      return [];
    }
  }

  Future<void> delete(String workoutId) async {
    try {
      await _featuredWorkoutsRef.doc(workoutId).delete();
      print('Featured workout deleted successfully');
    } catch (e) {
      print('Error deleting featured workout: $e');
      rethrow;
    }
  }

  Future<CustomWorkout?> getById(String workoutId) async {
    try {
      final doc = await _featuredWorkoutsRef.doc(workoutId).get();
      if (doc.exists) {
        return CustomWorkout.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting featured workout: $e');
      return null;
    }
  }
}