enum ProgressSource { manual, session }

class GoalProgressEntry {
  final String id;
  final String goalId;
  final double value;
  final ProgressSource source;
  final String? sessionId;
  final String? sessionTitle;
  final String? notes;
  final DateTime timestamp;
  final double progressPercentage;

  GoalProgressEntry({
    required this.id,
    required this.goalId,
    required this.value,
    required this.source,
    this.sessionId,
    this.sessionTitle,
    this.notes,
    required this.timestamp,
    required this.progressPercentage,
  });

  /// Returns a user-friendly label for the source
  String get sourceLabel {
    if (source == ProgressSource.session && sessionTitle != null) {
      return 'From session: $sessionTitle';
    } else if (source == ProgressSource.manual) {
      return 'Manual update';
    }
    return 'Update';
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'value': value,
      'source': source.name,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'progressPercentage': progressPercentage,
    };
  }

  /// Create from JSON (Firestore document)
  factory GoalProgressEntry.fromJson(Map<String, dynamic> json) {
    return GoalProgressEntry(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      value: (json['value'] as num).toDouble(),
      source: ProgressSource.values.firstWhere(
            (e) => e.name == json['source'],
        orElse: () => ProgressSource.manual,
      ),
      sessionId: json['sessionId'] as String?,
      sessionTitle: json['sessionTitle'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
    );
  }

  /// Create a copy with modified fields
  GoalProgressEntry copyWith({
    String? id,
    String? goalId,
    double? value,
    ProgressSource? source,
    String? sessionId,
    String? sessionTitle,
    String? notes,
    DateTime? timestamp,
    double? progressPercentage,
  }) {
    return GoalProgressEntry(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      value: value ?? this.value,
      source: source ?? this.source,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  @override
  String toString() {
    return 'GoalProgressEntry(id: $id, goalId: $goalId, value: $value, source: ${source.name}, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalProgressEntry &&
        other.id == id &&
        other.goalId == goalId &&
        other.value == value &&
        other.source == source &&
        other.sessionId == sessionId &&
        other.sessionTitle == sessionTitle &&
        other.notes == notes &&
        other.timestamp == timestamp &&
        other.progressPercentage == progressPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      goalId,
      value,
      source,
      sessionId,
      sessionTitle,
      notes,
      timestamp,
      progressPercentage,
    );
  }
}