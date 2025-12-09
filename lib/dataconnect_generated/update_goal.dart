part of 'generated.dart';

class UpdateGoalVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  UpdateGoalVariablesBuilder(this._dataConnect, );
  Deserializer<UpdateGoalData> dataDeserializer = (dynamic json)  => UpdateGoalData.fromJson(jsonDecode(json));
  
  Future<OperationResult<UpdateGoalData, void>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateGoalData, void> ref() {
    
    return _dataConnect.mutation("UpdateGoal", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class UpdateGoalGoalUpdate {
  final String id;
  UpdateGoalGoalUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateGoalGoalUpdate otherTyped = other as UpdateGoalGoalUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateGoalGoalUpdate({
    required this.id,
  });
}

@immutable
class UpdateGoalData {
  final UpdateGoalGoalUpdate? goal_update;
  UpdateGoalData.fromJson(dynamic json):
  
  goal_update = json['goal_update'] == null ? null : UpdateGoalGoalUpdate.fromJson(json['goal_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateGoalData otherTyped = other as UpdateGoalData;
    return goal_update == otherTyped.goal_update;
    
  }
  @override
  int get hashCode => goal_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (goal_update != null) {
      json['goal_update'] = goal_update!.toJson();
    }
    return json;
  }

  UpdateGoalData({
    this.goal_update,
  });
}

