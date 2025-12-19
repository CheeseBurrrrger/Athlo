import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_food.dart';
import '../models/nutrition_plan.dart';
import '../services/nutrition_food_service.dart';
import '../services/nutrition_plan_service.dart';
import '../widgets/food_tile.dart';

class MyNutritionPlanPage extends StatelessWidget {
  final NutritionPlanService _planService = NutritionPlanService();
  final NutritionFoodService _foodService = NutritionFoodService();

  MyNutritionPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Rencana Nutrisi Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF3C467B),
        elevation: 0,
      ),
      body: StreamBuilder<NutritionPlan?>(
        stream: _planService.getUserPlan(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final plan = snapshot.data;

          if (plan == null) {
            return _buildEmptyState(context);
          }

          return _buildPlanContent(context, plan, user.uid);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 100, color: Colors.grey.shade400),
          SizedBox(height: 20),
          Text(
            'Belum Ada Rencana Nutrisi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Pilih program nutrisi terlebih dahulu dari halaman utama',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            label: Text('Kembali ke Halaman Utama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3C467B),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanContent(
    BuildContext context,
    NutritionPlan plan,
    String userId,
  ) {
    return FutureBuilder<List<NutritionFood>>(
      future: _foodService.getFoodsByIds(plan.selectedFoodIds),
      builder: (context, foodSnapshot) {
        if (foodSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final foods = foodSnapshot.data ?? [];

        // Calculate total macros
        int totalCalories = 0;
        int totalProtein = 0;
        int totalCarbs = 0;

        for (var food in foods) {
          totalCalories += food.calories;
          totalProtein += food.protein;
          totalCarbs += food.carbs;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with program info
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3C467B), Color(0xFF50589C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Program: ${_getProgramName(plan.type)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deletePlan(context, userId),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Terakhir diupdate: ${_formatDate(plan.updatedAt)}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Target vs Actual
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Harian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildProgressCard(
                      'Kalori',
                      totalCalories,
                      plan.targetCalories,
                      Colors.orange,
                      Icons.local_fire_department,
                    ),
                    SizedBox(height: 10),
                    _buildProgressCard(
                      'Protein',
                      totalProtein,
                      plan.targetProtein,
                      Colors.blue,
                      Icons.egg,
                    ),
                    SizedBox(height: 10),
                    _buildProgressCard(
                      'Karbohidrat',
                      totalCarbs,
                      plan.targetCarbs,
                      Colors.green,
                      Icons.rice_bowl,
                    ),
                  ],
                ),
              ),

              // Food List
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Makanan Terpilih (${foods.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalCalories kcal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C467B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),

              if (foods.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Belum ada makanan dipilih',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    return FoodTile(
                      food: foods[index],
                      isSelected: true,
                      onTap: () =>
                          _removeFoodFromPlan(context, userId, foods[index]),
                    );
                  },
                ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(
    String label,
    int current,
    int target,
    Color color,
    IconData icon,
  ) {
    double percentage = target > 0 ? (current / target * 100).clamp(0, 100) : 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$current / $target ${label == 'Kalori' ? 'kcal' : 'g'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _getProgramName(String type) {
    switch (type.toLowerCase()) {
      case 'cutting':
        return 'Cutting';
      case 'bulking':
        return 'Bulking';
      case 'lean':
        return 'Lean Gain';
      case 'maintenance':
        return 'Maintenance';
      case 'keto':
        return 'Keto';
      case 'vegan':
        return 'Vegan';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _removeFoodFromPlan(
    BuildContext context,
    String userId,
    NutritionFood food,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus dari Rencana?'),
        content: Text('Hapus "${food.name}" dari rencana nutrisi Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _planService.removeFoodFromPlan(userId, food.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Makanan dihapus dari rencana')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  void _deletePlan(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Rencana Nutrisi?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus seluruh rencana nutrisi? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _planService.deleteUserPlan(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rencana nutrisi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
