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
  Stream<QuerySnapshot<Object?>> readAll(){
    return userRef.snapshots();
  }
  // Stream<List<CustomWorkout>> readSpecificUser(String userId) {
  //   return userRef
  //       .where('uId', isEqualTo: userId)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //       .map((doc) => CustomWorkout.fromJson(doc.data() as Map<String, dynamic>))
  //       .toList());
  // }
  Stream<List<CustomWorkout>> readSpecificUser(String userId) {
    return userRef
        .where('uId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CustomWorkout.fromFirestore(doc))  // Changed to fromFirestore
        .toList());
  }
  // void hapus (CustomWorkout customWorkout){
  //   DocumentReference documentReference = userRef.doc(customWorkout.title);
  //   documentReference.delete();
  // }
  // void edit (CustomWorkout customWorkout){
  //   DocumentReference documentReference = userRef.doc(customWorkout.id);
  //   documentReference.update(customWorkout.toJson());
  // }
  Future<void> edit(CustomWorkout customWorkout) async {
    DocumentReference documentReference = userRef.doc(customWorkout.id);
    await documentReference.update(customWorkout.toJson());
  }
  Future<void> delete(String documentId) async {
    try {
      DocumentReference documentReference = userRef.doc(documentId);
      await documentReference.delete();
      print('Document deleted: $documentId');
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }
}