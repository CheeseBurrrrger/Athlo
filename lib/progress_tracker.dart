import 'package:flutter/material.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  String selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C467B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _showPeriodSelector(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildAchievementSection(),
            const SizedBox(height: 16),
            _buildRecentActivity(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3C467B),
            const Color(0xFF50589C),
            const Color(0xFF636CCB),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedPeriod,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Keep it up! 💪',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re doing great this week',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return GridView.count(
            crossAxisCount: isWide ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 1.1 : 0.95,
            children: [
              _buildStatCard(
                icon: Icons.fitness_center,
                title: 'Total Workouts',
                value: '24',
                unit: 'sessions',
                color: const Color(0xFF3C467B),
                onTap: () => _showDetailDialog('Workouts'),
              ),
              _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Calories Burned',
                value: '3,450',
                unit: 'kcal',
                color: const Color(0xFF50589C),
                onTap: () => _showDetailDialog('Calories'),
              ),
              _buildStatCard(
                icon: Icons.favorite,
                title: 'Avg Heart Rate',
                value: '142',
                unit: 'bpm',
                color: const Color(0xFF636CCB),
                onTap: () => _showDetailDialog('Heart Rate'),
              ),
              _buildStatCard(
                icon: Icons.timer,
                title: 'Total Duration',
                value: '18.5',
                unit: 'hours',
                color: const Color(0xFF6E8CFB),
                onTap: () => _showDetailDialog('Duration'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAchievementBadge(
                emoji: '🔥',
                title: '7 Day Streak',
                description: 'Keep the fire burning',
                color: const Color(0xFF3C467B),
                isUnlocked: true,
              ),
              _buildAchievementBadge(
                emoji: '💪',
                title: 'Strong Start',
                description: '10 workouts completed',
                color: const Color(0xFF50589C),
                isUnlocked: true,
              ),
              _buildAchievementBadge(
                emoji: '🏆',
                title: 'Champion',
                description: '50 workouts to unlock',
                color: const Color(0xFF636CCB),
                isUnlocked: false,
              ),
              _buildAchievementBadge(
                emoji: '⚡',
                title: 'Speed Demon',
                description: 'Complete 5 HIIT sessions',
                color: const Color(0xFF6E8CFB),
                isUnlocked: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required String emoji,
    required String title,
    required String description,
    required Color color,
    required bool isUnlocked,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isUnlocked ? null : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? color : Colors.grey[300]!,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 32,
              color: isUnlocked ? Colors.white : Colors.grey[400],
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.white70 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.directions_run,
          title: 'Morning Run',
          date: 'Today, 06:30 AM',
          calories: '320 kcal',
          duration: '45 min',
          color: const Color(0xFF3C467B),
        ),
        _buildActivityItem(
          icon: Icons.fitness_center,
          title: 'Strength Training',
          date: 'Yesterday, 07:00 PM',
          calories: '280 kcal',
          duration: '60 min',
          color: const Color(0xFF50589C),
        ),
        _buildActivityItem(
          icon: Icons.self_improvement,
          title: 'Yoga Session',
          date: '2 days ago, 06:00 AM',
          calories: '150 kcal',
          duration: '30 min',
          color: const Color(0xFF636CCB),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String date,
    required String calories,
    required String duration,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(
                    calories,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPeriodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPeriodOption('Weekly', 'Last 7 days'),
            _buildPeriodOption('Monthly', 'Last 30 days'),
            _buildPeriodOption('Yearly', 'Last 12 months'),
            _buildPeriodOption('All Time', 'Since you started'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(String title, String subtitle) {
    final isSelected = selectedPeriod == title;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF3C467B) : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF3C467B))
          : null,
      onTap: () {
        setState(() {
          selectedPeriod = title;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showDetailDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$category Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart, size: 80, color: Color(0xFF636CCB)),
            const SizedBox(height: 16),
            Text(
              'Detailed $category statistics and charts will be displayed here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}