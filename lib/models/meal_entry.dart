class MealEntry {
  final String id;
  final String userId;
  final String mealType; // sarapan / makan_siang / makan_malam / snack
  final String time;
  final String description;
  final int calories;
  final DateTime date;

  MealEntry({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.time,
    required this.description,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mealType': mealType,
      'time': time,
      'description': description,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory MealEntry.fromFirestore(Map<String, dynamic> data) {
    return MealEntry(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      mealType: data['mealType'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      calories: data['calories'] ?? 0,
      date: data['date'] != null
          ? DateTime.parse(data['date'])
          : DateTime.now(),
    );
  }
}
