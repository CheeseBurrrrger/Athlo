import '../../domain/models/goal.dart';

class GoalCalculations {
  static double calculateProgressPercentage(double current, double target) {
    return target > 0 ? (current / target * 100).clamp(0, 100) : 0;
  }

  static String determineProgressStatus(
      DateTime startDate,
      DateTime endDate,
      double progressPercentage,
      GoalStatus status,
      ) {
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

  static String getStatusColor(String progressStatus) {
    switch (progressStatus) {
      case 'Met':
      case 'On track':
        return '#4CAF50';
      case 'Behind':
        return '#FF9800';
      case 'Paused':
      case 'Ended':
        return '#9E9E9E';
      default:
        return '#2196F3';
    }
  }

  static String getEncouragementMessage(String progressStatus) {
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

  static (DateTime, DateTime) calculateDateRange(
      GoalPeriod period,
      DateTime? customStart,
      DateTime? customEnd,
      ) {
    final now = DateTime.now();

    if (period == GoalPeriod.custom) {
      return (
      customStart ?? now,
      customEnd ?? now.add(const Duration(days: 7))
      );
    }

    if (period == GoalPeriod.weekly) {
      final startOfWeek = now;
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
      return (startOfWeek, endOfWeek);
    }

    // Monthly
    final startOfMonth = now;
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59);
    return (startOfMonth, endOfMonth);
  }
}