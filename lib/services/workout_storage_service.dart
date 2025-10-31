import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_workout.dart';

class WorkoutStorageService {
  static const String _key = 'custom_workouts';

  // Save workout
  Future<void> saveWorkout(CustomWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    // Add new workout
    workouts.add(workout);

    // Convert to JSON and save
    final jsonList = workouts.map((w) => w.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // Get all workouts
  Future<List<CustomWorkout>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CustomWorkout.fromJson(json)).toList();
  }

  // Update workout
  Future<void> updateWorkout(CustomWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    // Find and replace
    final index = workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      workouts[index] = workout;

      // Save
      final jsonList = workouts.map((w) => w.toJson()).toList();
      await prefs.setString(_key, json.encode(jsonList));
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    // Remove workout
    workouts.removeWhere((w) => w.id == workoutId);

    // Save
    final jsonList = workouts.map((w) => w.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}