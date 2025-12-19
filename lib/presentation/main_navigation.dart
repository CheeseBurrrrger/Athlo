import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/nutrition_page.dart';
import 'pages/community.dart';
import 'pages/progress_tracker.dart';
import 'pages/workout_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2; // mulai dari tengah biar tidak error saat awal

  final List<Widget> _pages = [
    const ProfilePage(),
    WorkoutPage(),
    const ActivityFeedPage(),
    const ProgressTrackerPage(),
    NutritionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, -4), // 🔼 shadow ke atas
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // IKON NAVBAR BIASA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.person, 0),
                _navItem(Icons.fitness_center, 1),
                _navItem(Icons.people, 2),
                _navItem(Icons.show_chart, 3),
                _navItem(Icons.restaurant_menu, 4),
              ],
            ),

            // ⭐ FLOATING CIRCLE - HANYA NAIK, TIDAK BERGESER X
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              top: -15,
              left:
                  _getCircleX(context, _selectedIndex) -
                  24, // hitung posisi icon
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1974F5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // ⭐ ICON DI ATAS CIRCLE
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              top: 2,
              left: _getCircleX(context, _selectedIndex) - 8,
              child: Icon(
                _getIcon(_selectedIndex),
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mengambil posisi X dari icon yg dipilih
  double _getCircleX(BuildContext context, int index) {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = width / 5;
    return itemWidth * index + itemWidth / 2;
  }

  // Mengambil icon sesuai index
  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.fitness_center;
      case 2:
        return Icons.people;
      case 3:
        return Icons.show_chart;
      case 4:
        return Icons.restaurant_menu;
      default:
        return Icons.circle;
    }
  }

  // Tampilan icon navbar biasa
  Widget _navItem(IconData icon, int index) {
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        size: 28,
        color: isActive
            ? Colors.transparent
            : const Color(0xFF1974F5),

      ),
    );
  }
}
