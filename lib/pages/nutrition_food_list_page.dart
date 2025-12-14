import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_food.dart';
import '../models/nutrition_plan.dart';
import '../services/nutrition_food_service.dart';
import '../services/nutrition_plan_service.dart';
import '../widgets/food_tile.dart';
import 'add_nutrition_food_page.dart';

class NutritionFoodListPage extends StatefulWidget {
  final String programType;
  final String programTitle;
  final Color programColor;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;

  const NutritionFoodListPage({
    Key? key,
    required this.programType,
    required this.programTitle,
    required this.programColor,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
  }) : super(key: key);

  @override
  State<NutritionFoodListPage> createState() => _NutritionFoodListPageState();
}

class _NutritionFoodListPageState extends State<NutritionFoodListPage> {
  final NutritionFoodService _foodService = NutritionFoodService();
  final NutritionPlanService _planService = NutritionPlanService();
  final Set<String> _selectedFoodIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPlan();
  }

  Future<void> _loadExistingPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final plan = await _planService.getUserPlanOnce(user.uid);
      if (plan != null && plan.type == widget.programType) {
        setState(() {
          _selectedFoodIds.addAll(plan.selectedFoodIds);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.programTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: widget.programColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with targets
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.programColor.withOpacity(0.8),
                  widget.programColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Harian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTargetChip(
                      '${widget.targetCalories}',
                      'Kalori',
                      Icons.local_fire_department,
                    ),
                    _buildTargetChip(
                      '${widget.targetProtein}g',
                      'Protein',
                      Icons.egg,
                    ),
                    _buildTargetChip(
                      '${widget.targetCarbs}g',
                      'Karbo',
                      Icons.rice_bowl,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab untuk System Foods dan My Foods
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: widget.programColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: widget.programColor,
                    tabs: [
                      Tab(text: 'Makanan Sistem'),
                      Tab(text: 'Makanan Saya'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSystemFoodsTab(),
                        _buildUserFoodsTab(user!.uid),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_food',
            backgroundColor: widget.programColor,
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddNutritionFoodPage(category: widget.programType),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'save_plan',
            backgroundColor: Colors.green,
            icon: Icon(Icons.save),
            label: Text('Simpan Rencana'),
            onPressed: _selectedFoodIds.isEmpty ? null : _savePlan,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSystemFoodsTab() {
    return StreamBuilder<List<NutritionFood>>(
      stream: _foodService.readFoodsByCategory(widget.programType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final foods = snapshot.data ?? [];

        if (foods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada makanan untuk program ini',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 12, bottom: 80),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final isSelected = _selectedFoodIds.contains(food.id);

            return FoodTile(
              food: food,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFoodIds.remove(food.id);
                  } else {
                    _selectedFoodIds.add(food.id);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserFoodsTab(String userId) {
    return StreamBuilder<List<NutritionFood>>(
      stream: _foodService.readUserFoods(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final foods = snapshot.data ?? [];

        if (foods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada makanan custom',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Tambahkan makanan sendiri dengan tombol + di bawah',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 12, bottom: 80),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final isSelected = _selectedFoodIds.contains(food.id);

            return FoodTile(
              food: food,
              isSelected: isSelected,
              showActions: true,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFoodIds.remove(food.id);
                  } else {
                    _selectedFoodIds.add(food.id);
                  }
                });
              },
              onEdit: () => _editFood(food),
              onDelete: () => _deleteFood(food),
            );
          },
        );
      },
    );
  }

  void _editFood(NutritionFood food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNutritionFoodPage(
          category: widget.programType,
          existingFood: food,
        ),
      ),
    );
  }

  void _deleteFood(NutritionFood food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Makanan?'),
        content: Text('Apakah Anda yakin ingin menghapus "${food.name}"?'),
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
        await _foodService.deleteFood(food.id);
        _selectedFoodIds.remove(food.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Makanan berhasil dihapus')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  Future<void> _savePlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final plan = NutritionPlan(
        userId: user.uid,
        type: widget.programType,
        selectedFoodIds: _selectedFoodIds.toList(),
        targetCalories: widget.targetCalories,
        targetProtein: widget.targetProtein,
        targetCarbs: widget.targetCarbs,
        updatedAt: DateTime.now(),
      );

      await _planService.setUserPlan(plan);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Rencana nutrisi berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
