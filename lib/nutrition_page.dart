import 'package:athlo/pages/my_nutrition_plan_page.dart';
import 'package:athlo/pages/nutrition_food_list_page.dart';
import 'package:flutter/material.dart';
import '../services/nutrition_plan_service.dart';
import '../widgets/nutrition_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({Key? key}) : super(key: key);

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final NutritionPlanService _planService = NutritionPlanService();
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Nutrition Plan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF3C467B),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyNutritionPlanPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  Text(
                    'Pilih Program Nutrisi Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rencana makan yang disesuaikan dengan tujuan fitness Anda',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Current Plan Info
            StreamBuilder(
              stream: _planService.getUserPlan(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final plan = snapshot.data!;
                  return Container(
                    margin: EdgeInsets.all(16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Program Aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF6E8CFB).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                plan.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E8CFB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                              '${plan.targetCalories}',
                              'Kalori',
                              Color(0xFF6E8CFB),
                              Icons.local_fire_department,
                            ),
                            SizedBox(width: 12),
                            _buildStatChip(
                              '${plan.targetProtein}g',
                              'Protein',
                              Color(0xFF636CCB),
                              Icons.egg,
                            ),
                            SizedBox(width: 12),
                            _buildStatChip(
                              '${plan.targetCarbs}g',
                              'Karbo',
                              Color(0xFF50589C),
                              Icons.rice_bowl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),

            // Nutrition Programs Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Program Nutrisi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: nutritionPrograms.length,
              itemBuilder: (context, index) {
                final program = nutritionPrograms[index];
                return NutritionCard(
                  title: program['title']!,
                  subtitle: program['subtitle']!,
                  calories: program['calories']!,
                  protein: program['protein']!,
                  icon: program['icon']!,
                  color: program['color']!,
                  badge: program['badge']!,
                  onTap: () => _selectProgram(context, program, user!.uid),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectProgram(
    BuildContext context,
    Map<String, dynamic> program,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Program ${program['title']}?'),
        content: Text(
          'Apakah Anda ingin menggunakan program ${program['title']}?\n\n'
          'Target:\n'
          '• Kalori: ${program['calories']} kcal\n'
          '• Protein: ${program['protein']}\n'
          '• Karbo: ${program['carbs']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: program['color']),
            child: Text('Ya, Pilih'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Update Firebase via NutritionPlanService
      await _planService.changePlanType(
        userId,
        program['type']!,
        int.parse(program['calories']!.replaceAll(',', '')),
        int.parse(program['protein']!.replaceAll('g', '')),
        int.parse(program['carbs']!.replaceAll('g', '')),
      );

      // UI otomatis refresh karena StreamBuilder mendeteksi perubahan
      setState(() {});

      // Navigate ke food list page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionFoodListPage(
            programType: program['type']!,
            programTitle: program['title']!,
            programColor: program['color']!,
            targetCalories: int.parse(program['calories']!.replaceAll(',', '')),
            targetProtein: int.parse(program['protein']!.replaceAll('g', '')),
            targetCarbs: int.parse(program['carbs']!.replaceAll('g', '')),
          ),
        ),
      );
    }
  }

  final List<Map<String, dynamic>> nutritionPrograms = [
    {
      'title': 'Cutting',
      'subtitle': 'Bakar lemak sambil pertahankan otot',
      'calories': '1,800',
      'protein': '180g',
      'carbs': '150g',
      'icon': Icons.fitness_center,
      'color': Color(0xFF6E8CFB),
      'badge': 'Popular',
      'type': 'cutting',
    },
    {
      'title': 'Bulking',
      'subtitle': 'Tambah massa otot dengan surplus kalori',
      'calories': '3,200',
      'protein': '200g',
      'carbs': '400g',
      'icon': Icons.trending_up,
      'color': Color(0xFF636CCB),
      'badge': 'Trending',
      'type': 'bulking',
    },
    {
      'title': 'Maintenance',
      'subtitle': 'Pertahankan berat badan ideal',
      'calories': '2,450',
      'protein': '150g',
      'carbs': '250g',
      'icon': Icons.balance,
      'color': Color(0xFF50589C),
      'badge': '',
      'type': 'maintenance',
    },
    {
      'title': 'Lean Gain',
      'subtitle': 'Tambah otot tanpa banyak lemak',
      'calories': '2,700',
      'protein': '190g',
      'carbs': '300g',
      'icon': Icons.speed,
      'color': Color(0xFF6E8CFB),
      'badge': 'New',
      'type': 'lean',
    },
    {
      'title': 'Keto',
      'subtitle': 'Diet rendah karbo, tinggi lemak',
      'calories': '2,000',
      'protein': '140g',
      'carbs': '50g',
      'icon': Icons.local_fire_department,
      'color': Color(0xFF3C467B),
      'badge': '',
      'type': 'keto',
    },
    {
      'title': 'Vegan',
      'subtitle': 'Nutrisi nabati seimbang',
      'calories': '2,300',
      'protein': '120g',
      'carbs': '280g',
      'icon': Icons.eco,
      'color': Color(0xFF50589C),
      'badge': '',
      'type': 'vegan',
    },
  ];
}
