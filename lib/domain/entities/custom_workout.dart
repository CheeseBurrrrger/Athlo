import '../../data/models/exercise.dart';

class CustomWorkout {
  final String id;
  final String uId;
  final String title;
  final String duration;
  final String level;
  final String targetMuscle;
  final List<Exercise> exercises;
  final String color;
  final DateTime createdAt;

  CustomWorkout({
    required this.id,
    required this.uId,
    required this.title,
    required this.duration,
    required this.level,
    required this.targetMuscle,
    required this.exercises,
    required this.color,
    required this.createdAt,
  });
}