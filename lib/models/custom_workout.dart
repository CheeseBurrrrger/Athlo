import 'exercise.dart';

class CustomWorkout {
  final String id;
  final String title;
  final String duration;
  final String level;
  final String targetMuscle;
  final List<Exercise> exercises;
  final String color;
  final DateTime createdAt;

  CustomWorkout({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.targetMuscle,
    required this.exercises,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'level': level,
      'targetMuscle': targetMuscle,
      'exercises': exercises.map((e) => e.toJson()).toList(), // Store full objects
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomWorkout.fromJson(Map<String, dynamic> json) {
    return CustomWorkout(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      level: json['level'],
      targetMuscle: json['targetMuscle'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}