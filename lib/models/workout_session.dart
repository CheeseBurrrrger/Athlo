import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class WorkoutSession {
  final String id;
  final String workoutId;
  final String userId;
  final DateTime startTime;
  DateTime? endTime;
  String status; // 'in_progress', 'completed', 'abandoned'
  List<ExerciseSession> exercises;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.status = 'in_progress',
    required this.exercises,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get completedExercises {
    return exercises.where((e) => e.isCompleted).length;
  }

  double get progressPercentage {
    if (exercises.isEmpty) return 0;
    return (completedExercises / exercises.length) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutId: json['workoutId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      status: json['status'] ?? 'in_progress',
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseSession.fromJson(e))
          .toList(),
    );
  }
}

class ExerciseSession {
  final String exerciseId;
  final String name;
  final String equipment;
  List<SetData> sets;
  String? notes;

  ExerciseSession({
    required this.exerciseId,
    required this.name,
    required this.equipment,
    required this.sets,
    this.notes,
  });

  bool get isCompleted {
    return sets.isNotEmpty && sets.every((set) => set.isCompleted);
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'equipment': equipment,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      exerciseId: json['exerciseId'],
      name: json['name'],
      equipment: json['equipment'],
      sets: (json['sets'] as List).map((s) => SetData.fromJson(s)).toList(),
      notes: json['notes'],
    );
  }
}

class SetData {
  int reps;
  double? weight;
  bool isCompleted;
  DateTime? completedAt;

  SetData({
    this.reps = 0,
    this.weight,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SetData.fromJson(Map<String, dynamic> json) {
    return SetData(
      reps: json['reps'] ?? 0,
      weight: json['weight'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}