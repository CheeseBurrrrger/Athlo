part of 'generated.dart';

class ListMealsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMealsVariablesBuilder(this._dataConnect, );
  Deserializer<ListMealsData> dataDeserializer = (dynamic json)  => ListMealsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMealsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListMealsData, void> ref() {
    
    return _dataConnect.query("ListMeals", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMealsMeals {
  final String id;
  final DateTime date;
  final String mealType;
  final double? totalCalories;
  ListMealsMeals.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  date = nativeFromJson<DateTime>(json['date']),
  mealType = nativeFromJson<String>(json['mealType']),
  totalCalories = json['totalCalories'] == null ? null : nativeFromJson<double>(json['totalCalories']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMealsMeals otherTyped = other as ListMealsMeals;
    return id == otherTyped.id && 
    date == otherTyped.date && 
    mealType == otherTyped.mealType && 
    totalCalories == otherTyped.totalCalories;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, date.hashCode, mealType.hashCode, totalCalories.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['date'] = nativeToJson<DateTime>(date);
    json['mealType'] = nativeToJson<String>(mealType);
    if (totalCalories != null) {
      json['totalCalories'] = nativeToJson<double?>(totalCalories);
    }
    return json;
  }

  ListMealsMeals({
    required this.id,
    required this.date,
    required this.mealType,
    this.totalCalories,
  });
}

@immutable
class ListMealsData {
  final List<ListMealsMeals> meals;
  ListMealsData.fromJson(dynamic json):
  
  meals = (json['meals'] as List<dynamic>)
        .map((e) => ListMealsMeals.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMealsData otherTyped = other as ListMealsData;
    return meals == otherTyped.meals;
    
  }
  @override
  int get hashCode => meals.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['meals'] = meals.map((e) => e.toJson()).toList();
    return json;
  }

  ListMealsData({
    required this.meals,
  });
}

