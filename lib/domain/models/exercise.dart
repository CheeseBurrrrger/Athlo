class Exercise {
  final String exerciseId;
  final String name;
  final String gifUrl;
  final List<String> targetMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gifUrl: json['gifUrl']?.toString() ?? '',
      targetMuscles: json['targetMuscles'] != null
          ? List<String>.from(json['targetMuscles'])
          : [],
      bodyParts: json['bodyParts'] != null
          ? List<String>.from(json['bodyParts'])
          : [],
      equipments: json['equipments'] != null
          ? List<String>.from(json['equipments'])
          : [],
      secondaryMuscles: json['secondaryMuscles'] != null
          ? List<String>.from(json['secondaryMuscles'])
          : [],
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }

  String get equipment => equipments.isNotEmpty ? equipments.first : 'body weight';
}