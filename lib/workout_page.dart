import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  WorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Workout Plans', style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF3C467B))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddWorkoutBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C467B), Color(0xFF50589C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Raih Target Fitness Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih program latihan sesuai level dan tujuan Anda',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickStat('12', 'Workouts\nCompleted', const Color(0xFF6E8CFB), Icons.check_circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat('45', 'Minutes\nToday', const Color(0xFF636CCB), Icons.timer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat('5', 'Day\nStreak', const Color(0xFF50589C), Icons.local_fire_department),
                  ),
                ],
              ),
            ),

            // Featured Programs Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Featured Programs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double childAspectRatio;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6;
                childAspectRatio = 0.9;
              } else if (constraints.maxWidth >= 800) {
                crossAxisCount = 3;
                childAspectRatio = 0.8;
              } else {
                crossAxisCount = 2;
                childAspectRatio = 0.65;
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: workoutPrograms.length,
                itemBuilder: (context, index) {
                  final program = workoutPrograms[index];
                  return _buildWorkoutCard(
                    context,
                    program['title']!,
                    program['duration']!,
                    program['level']!,
                    program['target']!,
                    program['exercises']!,
                    program['icon'] as IconData,
                    program['color'] as Color,
                    program['badge']!,
                  );
                },
              );
            },
          ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Popular Workouts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popularWorkouts.length,
              itemBuilder: (context, index) {
                final workout = popularWorkouts[index];
                return _buildPopularWorkoutCard(
                  context,
                  workout['title']!,
                  workout['duration']!,
                  workout['calories']!,
                  workout['level']!,
                  workout['icon'] as IconData,
                  workout['color'] as Color,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
      BuildContext context,
      String title,
      String duration,
      String level,
      String target,
      String exercises,
      IconData icon,
      Color color,
      String badge,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailPage(
              title: title,
              duration: duration,
              level: level,
              target: target,
              exercises: exercises,
              icon: icon,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(duration, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.fitness_center, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                exercises,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ),
    );
  }

  Widget _buildPopularWorkoutCard(
      BuildContext context,
      String title,
      String duration,
      String calories,
      String level,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Icon(Icons.local_fire_department, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(calories, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> workoutPrograms = [
    {
      'title': '3-Day Split',
      'duration': '60-75 min',
      'level': 'Intermediate',
      'target': 'Full Body',
      'exercises': '8 exercises',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF6E8CFB),
      'badge': 'Popular',
    },
    {
      'title': 'Full Body Strength',
      'duration': '45-60 min',
      'level': 'Beginner',
      'target': 'All Muscles',
      'exercises': '10 exercises',
      'icon': Icons.settings_accessibility,
      'color': const Color(0xFF636CCB),
      'badge': 'New',
    },
    {
      'title': 'Upper Body Focus',
      'duration': '50 min',
      'level': 'Advanced',
      'target': 'Chest, Back, Arms',
      'exercises': '12 exercises',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF50589C),
      'badge': '',
    },
    {
      'title': 'Leg Day Power',
      'duration': '55 min',
      'level': 'Intermediate',
      'target': 'Legs, Glutes',
      'exercises': '9 exercises',
      'icon': Icons.directions_run,
      'color': const Color(0xFF6E8CFB),
      'badge': 'Trending',
    },
    {
      'title': 'Core Blast',
      'duration': '30 min',
      'level': 'All Levels',
      'target': 'Abs, Core',
      'exercises': '6 exercises',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF3C467B),
      'badge': '',
    },
    {
      'title': 'Push Pull Legs',
      'duration': '70 min',
      'level': 'Advanced',
      'target': 'Full Body',
      'exercises': '15 exercises',
      'icon': Icons.sports_gymnastics,
      'color': const Color(0xFF636CCB),
      'badge': '',
    },
  ];

  final List<Map<String, dynamic>> popularWorkouts = [
    {
      'title': 'Morning Cardio Burn',
      'duration': '25 min',
      'calories': '300 cal',
      'level': 'Beginner',
      'icon': Icons.directions_run,
      'color': const Color(0xFF6E8CFB),
    },
    {
      'title': 'HIIT Intensity',
      'duration': '20 min',
      'calories': '400 cal',
      'level': 'Advanced',
      'icon': Icons.flash_on,
      'color': const Color(0xFF636CCB),
    },
    {
      'title': 'Yoga Flow',
      'duration': '40 min',
      'calories': '150 cal',
      'level': 'All Levels',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF50589C),
    },
  ];
}

// Detail Page for Workout
class WorkoutDetailPage extends StatelessWidget {
  final String title;
  final String duration;
  final String level;
  final String target;
  final String exercises;
  final IconData icon;
  final Color color;

  const WorkoutDetailPage({
    Key? key,
    required this.title,
    required this.duration,
    required this.level,
    required this.target,
    required this.exercises,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(Icons.access_time, 'Duration', duration, color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(Icons.bar_chart, 'Level', level, color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(Icons.track_changes, 'Target', target, color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(Icons.fitness_center, 'Exercises', exercises, color),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Workout Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Program latihan ini dirancang untuk memaksimalkan hasil dengan fokus pada $target. '
                        'Cocok untuk level $level yang ingin meningkatkan kekuatan dan massa otot.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Exercise List
                  const Text(
                    'Exercise List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._buildExerciseList(color),

                  const SizedBox(height: 24),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Starting workout! 💪')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseList(Color color) {
    final exercises = [
      {'name': 'Barbell Bench Press', 'sets': '4 sets × 8-10 reps'},
      {'name': 'Dumbbell Rows', 'sets': '4 sets × 10-12 reps'},
      {'name': 'Shoulder Press', 'sets': '3 sets × 10 reps'},
      {'name': 'Bicep Curls', 'sets': '3 sets × 12 reps'},
      {'name': 'Tricep Dips', 'sets': '3 sets × 10-12 reps'},
      {'name': 'Cable Flyes', 'sets': '3 sets × 12-15 reps'},
    ];

    return exercises.map((exercise) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fitness_center, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise['sets']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline, color: color, size: 28),
          ],
        ),
      );
    }).toList();
  }
}
void _showAddWorkoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Custom Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Workout Name',
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Target Muscles',
                      prefixIcon: const Icon(Icons.track_changes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Number of Exercises',
                      prefixIcon: const Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom workout created! 💪')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C467B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Workout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildLevelChip(String label, Color color) {
  return FilterChip(
    label: Text(label),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    backgroundColor: color.withOpacity(0.1),
    side: BorderSide(color: color),
    onSelected: (selected) {},
  );
}