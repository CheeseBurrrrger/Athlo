library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'list_workouts_for_user.dart';

part 'update_goal.dart';

part 'list_meals.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  ListWorkoutsForUserVariablesBuilder listWorkoutsForUser () {
    return ListWorkoutsForUserVariablesBuilder(dataConnect, );
  }
  
  
  UpdateGoalVariablesBuilder updateGoal () {
    return UpdateGoalVariablesBuilder(dataConnect, );
  }
  
  
  ListMealsVariablesBuilder listMeals () {
    return ListMealsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'athlo',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
