import 'package:flutter/cupertino.dart';

class WorkoutConstants {
  static final List<Map<String, dynamic>> popularWorkouts = [
    {
      'title': 'Morning Cardio Burn',
      'duration': '25 min',
      'calories': '300 cal',
      'level': 'Beginner',
      'icon': CupertinoIcons.flame,
      'color': const Color(0xFF6E8CFB),
    },
    {
      'title': 'HIIT Intensity',
      'duration': '20 min',
      'calories': '400 cal',
      'level': 'Advanced',
      'icon': CupertinoIcons.bolt_fill,
      'color': const Color(0xFF636CCB),
    },
    {
      'title': 'Yoga Flow',
      'duration': '40 min',
      'calories': '150 cal',
      'level': 'All Levels',
      'icon': CupertinoIcons.heart,
      'color': const Color(0xFF50589C),
    },
  ];
}