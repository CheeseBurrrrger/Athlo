import 'package:athlo/workout_page.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'nutrition_page.dart';
import 'community.dart';
import 'progress_tracker.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of pages - replace placeholders when you create the actual pages
  final List<Widget> _pages = [
    const ProfilePage(),
    WorkoutPage(),
    const FitnessApp(),
    const ProgressTrackerPage(),
    NutritionGridApp(),
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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF3C467B),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 28),
                activeIcon: Icon(Icons.person, size: 32),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center, size: 28),
                activeIcon: Icon(Icons.fitness_center, size: 32),
                label: 'Workout',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people, size: 28),
                activeIcon: Icon(Icons.people, size: 32),
                label: 'Community',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart, size: 28),
                activeIcon: Icon(Icons.show_chart, size: 32),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu, size: 28),
                activeIcon: Icon(Icons.restaurant_menu, size: 32),
                label: 'Nutrition',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder page for pages you haven't created yet
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C467B),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: const Color(0xFF3C467B).withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Coming Soon! 🚀',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}