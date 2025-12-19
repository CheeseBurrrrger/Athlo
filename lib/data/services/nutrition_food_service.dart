import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/nutrition_food.dart';

class NutritionFoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'nutrition_foods';

  // CREATE - Tambah makanan baru
  Future<void> addFood(NutritionFood food) async {
    try {
      await _firestore.collection(_collection).doc(food.id).set(food.toJson());
    } catch (e) {
      throw Exception('Gagal menambah makanan: $e');
    }
  }

  // READ - Ambil makanan berdasarkan kategori
  Stream<List<NutritionFood>> readFoodsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionFood.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // READ - Ambil makanan user (custom foods)
  Stream<List<NutritionFood>> readUserFoods(String userID) {
    return _firestore
        .collection(_collection)
        .where('userID', isEqualTo: userID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionFood.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // READ - Ambil makanan berdasarkan ID
  Future<NutritionFood?> getFoodById(String foodId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(foodId).get();
      if (doc.exists) {
        return NutritionFood.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil makanan: $e');
    }
  }

  // READ - Ambil multiple foods by IDs
  Future<List<NutritionFood>> getFoodsByIds(List<String> foodIds) async {
    if (foodIds.isEmpty) return [];

    try {
      final docs = await Future.wait(
        foodIds.map((id) => _firestore.collection(_collection).doc(id).get()),
      );

      return docs
          .where((doc) => doc.exists)
          .map((doc) => NutritionFood.fromFirestore(doc.data()!))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar makanan: $e');
    }
  }

  // UPDATE - Update makanan
  Future<void> updateFood(NutritionFood food) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(food.id)
          .update(food.toJson());
    } catch (e) {
      throw Exception('Gagal update makanan: $e');
    }
  }

  // DELETE - Hapus makanan
  Future<void> deleteFood(String foodId) async {
    try {
      await _firestore.collection(_collection).doc(foodId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus makanan: $e');
    }
  }

  // SEARCH - Cari makanan berdasarkan nama
  Stream<List<NutritionFood>> searchFoods(String query) {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NutritionFood.fromFirestore(doc.data()))
              .where(
                (food) => food.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList(),
        );
  }
}
