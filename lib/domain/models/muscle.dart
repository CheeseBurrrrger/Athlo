class Muscle{
  final String id;
  final String name;

  Muscle({
    required this.id,
    required this.name,
  });

  factory Muscle.fromJson(Map<String, dynamic> json){
    return Muscle(
      id: json['id'].toString(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'name': name,
    };
  }
}