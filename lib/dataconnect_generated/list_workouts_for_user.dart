part of 'generated.dart';

class ListWorkoutsForUserVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListWorkoutsForUserVariablesBuilder(this._dataConnect, );
  Deserializer<ListWorkoutsForUserData> dataDeserializer = (dynamic json)  => ListWorkoutsForUserData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListWorkoutsForUserData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListWorkoutsForUserData, void> ref() {
    
    return _dataConnect.query("ListWorkoutsForUser", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListWorkoutsForUserWorkouts {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final String workoutType;
  ListWorkoutsForUserWorkouts.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  date = nativeFromJson<DateTime>(json['date']),
  durationMinutes = nativeFromJson<int>(json['durationMinutes']),
  workoutType = nativeFromJson<String>(json['workoutType']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkoutsForUserWorkouts otherTyped = other as ListWorkoutsForUserWorkouts;
    return id == otherTyped.id && 
    date == otherTyped.date && 
    durationMinutes == otherTyped.durationMinutes && 
    workoutType == otherTyped.workoutType;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, date.hashCode, durationMinutes.hashCode, workoutType.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['date'] = nativeToJson<DateTime>(date);
    json['durationMinutes'] = nativeToJson<int>(durationMinutes);
    json['workoutType'] = nativeToJson<String>(workoutType);
    return json;
  }

  ListWorkoutsForUserWorkouts({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.workoutType,
  });
}

@immutable
class ListWorkoutsForUserData {
  final List<ListWorkoutsForUserWorkouts> workouts;
  ListWorkoutsForUserData.fromJson(dynamic json):
  
  workouts = (json['workouts'] as List<dynamic>)
        .map((e) => ListWorkoutsForUserWorkouts.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkoutsForUserData otherTyped = other as ListWorkoutsForUserData;
    return workouts == otherTyped.workouts;
    
  }
  @override
  int get hashCode => workouts.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['workouts'] = workouts.map((e) => e.toJson()).toList();
    return json;
  }

  ListWorkoutsForUserData({
    required this.workouts,
  });
}

