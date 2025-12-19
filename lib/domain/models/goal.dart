import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalMetric { calories, duration, workouts }

enum GoalPeriod { weekly, monthly, custom }

enum GoalStatus { active, paused, completed, ended }

class Goal {
  final String id;
  final String userID;
  final String title;
  final GoalMetric metric;
  final double targetValue;
  final double currentValue;
  final GoalPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoLink;
  final bool reminderEnabled;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  Goal({
    required this.id,
    required this.userID,
    required this.title,
    required this.metric,
    required this.targetValue,
    this.currentValue = 0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.autoLink = true,
    this.reminderEnabled = false,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.completedAt,
  });

  double get progressPercentage =>
      targetValue > 0 ? (currentValue / targetValue * 100).clamp(0, 100) : 0;

  String get progressStatus {
    if (status == GoalStatus.completed) return 'Met';
    if (status == GoalStatus.paused) return 'Paused';
    if (status == GoalStatus.ended) return 'Ended';

    final totalDays = endDate.difference(startDate).inDays;
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final progressRatio = totalDays > 0 ? daysElapsed / totalDays : 0;

    if (progressPercentage >= 100) return 'Met';
    if (progressPercentage >= 70) return 'On track';
    if (progressRatio >= 0.5 && progressPercentage < 50) return 'Behind';
    return 'On track';
  }

  String get statusColor {
    switch (progressStatus) {
      case 'Met':
        return '#4CAF50'; // Green
      case 'On track':
        return '#4CAF50'; // Green
      case 'Behind':
        return '#FF9800'; // Orange
      case 'Paused':
      case 'Ended':
        return '#9E9E9E'; // Gray
      default:
        return '#2196F3'; // Blue
    }
  }

  String get encouragementMessage {
    switch (progressStatus) {
      case 'Met':
        return 'Goal achieved! 🎉';
      case 'On track':
        return 'Keep pushing! You\'re doing great! 💪';
      case 'Behind':
        return 'Don\'t give up! Every step counts! 🔥';
      case 'Paused':
        return 'Ready to continue?';
      case 'Ended':
        return 'Goal ended';
      default:
        return 'Let\'s do this! 🚀';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'title': title,
      'metric': metric.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'autoLink': autoLink,
      'reminderEnabled': reminderEnabled,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userID: json['userID'] as String,
      title: json['title'] as String,
      metric: GoalMetric.values.firstWhere((e) => e.name == json['metric']),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      period: GoalPeriod.values.firstWhere((e) => e.name == json['period']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      autoLink: json['autoLink'] as bool? ?? true,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      status: GoalStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Goal copyWith({
    String? id,
    String? userID,
    String? title,
    GoalMetric? metric,
    double? targetValue,
    double? currentValue,
    GoalPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoLink,
    bool? reminderEnabled,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      title: title ?? this.title,
      metric: metric ?? this.metric,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoLink: autoLink ?? this.autoLink,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}