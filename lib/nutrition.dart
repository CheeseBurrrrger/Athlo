import 'package:flutter/material.dart';

class NutritionGridApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Nutrition Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF3C467B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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

            // Daily Stats Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('2,450', 'Kalori Harian', Color(0xFF6E8CFB), Icons.local_fire_department),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('180g', 'Protein', Color(0xFF636CCB), Icons.egg),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('250g', 'Karbo', Color(0xFF50589C), Icons.rice_bowl),
                  ),
                ],
              ),
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
                return _buildNutritionCard(
                  program['title']!,
                  program['subtitle']!,
                  program['calories']!,
                  program['protein']!,
                  program['icon']!,
                  program['color']!,
                  program['badge']!,
                );
              },
            ),

            // Meal Plans Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rencana Makan Hari Ini',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildMealCard('Sarapan', '07:00 AM', 'Oatmeal + Pisang + Protein Shake', '450 kcal', Color(0xFF6E8CFB).withOpacity(0.15)),
                  SizedBox(height: 10),
                  _buildMealCard('Makan Siang', '12:30 PM', 'Nasi Merah + Ayam Panggang + Sayur', '680 kcal', Color(0xFF636CCB).withOpacity(0.15)),
                  SizedBox(height: 10),
                  _buildMealCard('Makan Malam', '07:00 PM', 'Salmon + Kentang + Brokoli', '550 kcal', Color(0xFF50589C).withOpacity(0.15)),
                  SizedBox(height: 10),
                  _buildMealCard('Snack', '03:00 PM', 'Greek Yogurt + Almond', '280 kcal', Color(0xFF3C467B).withOpacity(0.15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
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
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String title, String subtitle, String calories, String protein, IconData icon, Color color, String badge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 50, color: Colors.white),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(calories, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                              Text('Kalori', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(protein, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                              Text('Protein', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (badge.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String meal, String time, String description, String calories, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
              ],
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              calories,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> nutritionPrograms = [
    {
      'title': 'Cutting',
      'subtitle': 'Bakar lemak sambil pertahankan otot',
      'calories': '1,800',
      'protein': '180g',
      'icon': Icons.fitness_center,
      'color': Color(0xFF6E8CFB),
      'badge': 'Popular',
    },
    {
      'title': 'Bulking',
      'subtitle': 'Tambah massa otot dengan surplus kalori',
      'calories': '3,200',
      'protein': '200g',
      'icon': Icons.trending_up,
      'color': Color(0xFF636CCB),
      'badge': 'Trending',
    },
    {
      'title': 'Maintenance',
      'subtitle': 'Pertahankan berat badan ideal',
      'calories': '2,450',
      'protein': '150g',
      'icon': Icons.balance,
      'color': Color(0xFF50589C),
      'badge': '',
    },
    {
      'title': 'Lean Gain',
      'subtitle': 'Tambah otot tanpa banyak lemak',
      'calories': '2,700',
      'protein': '190g',
      'icon': Icons.speed,
      'color': Color(0xFF6E8CFB),
      'badge': 'New',
    },
    {
      'title': 'Keto',
      'subtitle': 'Diet rendah karbo, tinggi lemak',
      'calories': '2,000',
      'protein': '140g',
      'icon': Icons.local_fire_department,
      'color': Color(0xFF3C467B),
      'badge': '',
    },
    {
      'title': 'Vegan',
      'subtitle': 'Nutrisi nabati seimbang',
      'calories': '2,300',
      'protein': '120g',
      'icon': Icons.eco,
      'color': Color(0xFF50589C),
      'badge': '',
    },
  ];
}

// Untuk menjalankan: runApp(MaterialApp(home: NutritionGridApp()));