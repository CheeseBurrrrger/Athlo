class NutritionFood {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final String category; // bulking / cutting / lean
  final String userId;
  final DateTime createdAt;

  NutritionFood({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.category,
    required this.userId,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'category': category,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory NutritionFood.fromFirestore(Map<String, dynamic> data) {
    return NutritionFood(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  NutritionFood copyWith({
    String? id,
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    String? category,
    String? userId,
    DateTime? createdAt,
  }) {
    return NutritionFood(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
