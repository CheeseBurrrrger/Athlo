// services/nutrition_plan_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/nutrition_plan.dart';

class NutritionPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'nutrition_plans';

  // CREATE/UPDATE - Set user plan (upsert)
  Future<void> setUserPlan(NutritionPlan plan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(plan.userID)
          .set(plan.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan rencana nutrisi: $e');
    }
  }

  // READ - Get user plan
  Stream<NutritionPlan?> getUserPlan(String userID) {
    return _firestore.collection(_collection).doc(userID).snapshots().map((
        doc,
        ) {
      if (doc.exists) {
        return NutritionPlan.fromFirestore(doc.data()!);
      }
      return null;
    });
  }

  // READ - Get user plan (one-time)
  Future<NutritionPlan?> getUserPlanOnce(String userID) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userID).get();
      if (doc.exists) {
        return NutritionPlan.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil rencana nutrisi: $e');
    }
  }

  // UPDATE - Update specific fields
  Future<void> updateUserPlan(NutritionPlan plan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(plan.userID)
          .update(plan.toJson());
    } catch (e) {
      throw Exception('Gagal update rencana nutrisi: $e');
    }
  }

  // UPDATE - Add food to plan
  Future<void> addFoodToPlan(String userID, String foodId) async {
    try {
      // Use set with merge to create document if it doesn't exist
      await _firestore.collection(_collection).doc(userID).set({
        'selectedFoodIds': FieldValue.arrayUnion([foodId]),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal menambah makanan ke rencana: $e');
    }
  }

  // UPDATE - Remove food from plan
  Future<void> removeFoodFromPlan(String userID, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(userID).update({
        'selectedFoodIds': FieldValue.arrayRemove([foodId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menghapus makanan dari rencana: $e');
    }
  }

  // UPDATE - Change plan type (FIXED - uses set with merge)
  Future<void> changePlanType(
      String userID,
      String newType,
      int targetCal,
      int targetProt,
      int targetCarbs,
      ) async {
    try {
      // Use set with merge: true to create or update the document
      await _firestore.collection(_collection).doc(userID).set({
        'userID': userID, // Include userID in case document doesn't exist
        'type': newType,
        'targetCalories': targetCal,
        'targetProtein': targetProt,
        'targetCarbs': targetCarbs,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(), // Only set if new
      }, SetOptions(merge: true)); // merge: true creates if doesn't exist

      print('✅ Plan type changed successfully for user: $userID');
    } catch (e) {
      print('❌ Error changing plan type: $e');
      throw Exception('Gagal mengubah tipe program: $e');
    }
  }

  // DELETE - Delete user plan
  Future<void> deleteUserPlan(String userID) async {
    try {
      await _firestore.collection(_collection).doc(userID).delete();
    } catch (e) {
      throw Exception('Gagal menghapus rencana nutrisi: $e');
    }
  }

  // HELPER - Check if user has a plan
  Future<bool> userHasPlan(String userID) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userID).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user has plan: $e');
      return false;
    }
  }

  // HELPER - Initialize default plan for new user
  Future<void> initializeDefaultPlan(String userID) async {
    try {
      final exists = await userHasPlan(userID);
      if (!exists) {
        await _firestore.collection(_collection).doc(userID).set({
          'userID': userID,
          'type': 'maintenance',
          'targetCalories': 2450,
          'targetProtein': 150,
          'targetCarbs': 250,
          'selectedFoodIds': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        print('✅ Default plan initialized for user: $userID');
      }
    } catch (e) {
      print('❌ Error initializing default plan: $e');
    }
  }
}
