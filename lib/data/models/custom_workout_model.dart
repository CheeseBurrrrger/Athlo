import 'package:athlo/data/models/exercise.dart';
import 'package:athlo/domain/entities/custom_workout.dart';

class CustomWorkoutModel extends CustomWorkout {
  CustomWorkoutModel({
    required super.id,
    required super.title,
    required super.level,
    required super.duration,
    required super.targetMuscle,
    required super.color,
    required super.exercises,
    required super.uId,
    required super.createdAt,
  });

  factory CustomWorkoutModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CustomWorkoutModel(
      id: json['id'],
      title: json['title'],
      level: json['level'],
      duration: json['duration'],
      targetMuscle: json['targetMuscle'],
      color: json['color'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      uId: json['uId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'level': level,
      'duration': duration,
      'targetMuscle': targetMuscle,
      'color': color,
    };
  }
}