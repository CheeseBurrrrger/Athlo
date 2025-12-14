class NutritionPlan {
  final String userId;
  final String type; // bulking / cutting / lean / maintenance
  final List<String> selectedFoodIds;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final DateTime updatedAt;

  NutritionPlan({
    required this.userId,
    required this.type,
    required this.selectedFoodIds,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.updatedAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'selectedFoodIds': selectedFoodIds,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory NutritionPlan.fromFirestore(Map<String, dynamic> data) {
    return NutritionPlan(
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      selectedFoodIds: List<String>.from(data['selectedFoodIds'] ?? []),
      targetCalories: data['targetCalories'] ?? 0,
      targetProtein: data['targetProtein'] ?? 0,
      targetCarbs: data['targetCarbs'] ?? 0,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  NutritionPlan copyWith({
    String? userId,
    String? type,
    List<String>? selectedFoodIds,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    DateTime? updatedAt,
  }) {
    return NutritionPlan(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      selectedFoodIds: selectedFoodIds ?? this.selectedFoodIds,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
