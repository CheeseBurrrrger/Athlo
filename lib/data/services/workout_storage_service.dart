import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/custom_workout.dart';

class WorkoutStorageService {
  static const String _key = 'custom_workouts';

  Future<void> saveWorkout(CustomWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    workouts.add(workout);

    final jsonList = workouts.map((w) => w.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<List<CustomWorkout>> getWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CustomWorkout.fromJson(json)).toList();
  }

  Future<void> updateWorkout(CustomWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    final index = workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      workouts[index] = workout;

      final jsonList = workouts.map((w) => w.toJson()).toList();
      await prefs.setString(_key, json.encode(jsonList));
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final workouts = await getWorkouts();

    workouts.removeWhere((w) => w.id == workoutId);

    final jsonList = workouts.map((w) => w.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}