import 'package:flutter/cupertino.dart';

class WorkoutLevel {
  final String label;
  final Color color;

  const WorkoutLevel({
    required this.label,
    required this.color,
  });
}

class WorkoutLevels {
  static const beginner = WorkoutLevel(
    label: 'Beginner',
    color: Color(0xFF6E8CFB),
  );

  static const intermediate = WorkoutLevel(
    label: 'Intermediate',
    color: Color(0xFF636CCB),
  );

  static const advanced = WorkoutLevel(
    label: 'Advanced',
    color: Color(0xFF50589C),
  );

  static const all = [beginner, intermediate, advanced];
}