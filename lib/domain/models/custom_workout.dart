import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uId': uId,
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
      uId: json['uId'],
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
  factory CustomWorkout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CustomWorkout(
      id: doc.id,
      title: data['title'] ?? '',
      duration: data['duration'] ?? '',
      uId: data['uId']??'',
      level: data['level']??'',
      targetMuscle: data['targetMuscle']??'',
      exercises: (data['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      color:data['color']?? '',
      createdAt: _parseDateTime(data['createdAt']),
    );
  }
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}