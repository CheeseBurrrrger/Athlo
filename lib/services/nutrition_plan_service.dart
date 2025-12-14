import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition_plan.dart';

class NutritionPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'nutrition_plans';

  // CREATE/UPDATE - Set user plan (upsert)
  Future<void> setUserPlan(NutritionPlan plan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(plan.userId)
          .set(plan.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan rencana nutrisi: $e');
    }
  }

  // READ - Get user plan
  Stream<NutritionPlan?> getUserPlan(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return NutritionPlan.fromFirestore(doc.data()!);
      }
      return null;
    });
  }

  // READ - Get user plan (one-time)
  Future<NutritionPlan?> getUserPlanOnce(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
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
          .doc(plan.userId)
          .update(plan.toJson());
    } catch (e) {
      throw Exception('Gagal update rencana nutrisi: $e');
    }
  }

  // UPDATE - Add food to plan
  Future<void> addFoodToPlan(String userId, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'selectedFoodIds': FieldValue.arrayUnion([foodId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menambah makanan ke rencana: $e');
    }
  }

  // UPDATE - Remove food from plan
  Future<void> removeFoodFromPlan(String userId, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'selectedFoodIds': FieldValue.arrayRemove([foodId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menghapus makanan dari rencana: $e');
    }
  }

  // UPDATE - Change plan type
  Future<void> changePlanType(
    String userId,
    String newType,
    int targetCal,
    int targetProt,
    int targetCarbs,
  ) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'type': newType,
        'targetCalories': targetCal,
        'targetProtein': targetProt,
        'targetCarbs': targetCarbs,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal mengubah tipe program: $e');
    }
  }

  // DELETE - Delete user plan
  Future<void> deleteUserPlan(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus rencana nutrisi: $e');
    }
  }
}
