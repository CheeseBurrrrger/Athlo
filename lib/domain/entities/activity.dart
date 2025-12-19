import 'package:flutter/material.dart';

class Activity {
  final String userName;
  final String activityType;
  final String distance;
  final String time;
  final String calories;
  final DateTime createdAt;

  Activity({
    required this.userName,
    required this.activityType,
    required this.distance,
    required this.time,
    required this.calories,
    required this.createdAt,
  });

  String get avatar => userName.isNotEmpty ? userName[0] : '?';
}
