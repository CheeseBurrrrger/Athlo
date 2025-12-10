import 'package:athlo/models/custom_workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutService{
  static final COLLECTION_REF = 'custom_workout';
  final firestore = FirebaseFirestore.instance;
  late final CollectionReference userRef;
  WorkoutService(){
    userRef = firestore.collection(COLLECTION_REF);
  }
  void add (CustomWorkout customWorkout){
    String docId = '${customWorkout.title}_${customWorkout.targetMuscle}_${customWorkout.level}';
    DocumentReference documentReference = userRef.doc(docId);
    documentReference.set(customWorkout.toJson());
  }
  Stream<QuerySnapshot<Object?>> read(){
    return userRef.snapshots();
}
}