import '../pages/custom_workout_detail_page.dart';
import 'package:flutter/material.dart';
import '../widgets/workout_card.dart';
import '../widgets/popular_workout_card.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/add_workout_bottom_sheet.dart';
import '../services/workout_storage_service.dart';
import '../models/custom_workout.dart';
import 'workout_detail_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutStorageService _storageService = WorkoutStorageService();
  List<CustomWorkout> customWorkouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
  }

  Future<void> _loadCustomWorkouts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final workouts = await _storageService.getWorkouts();
      setState(() {
        customWorkouts = workouts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading workouts: $e');
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteWorkout(workoutId);
        await _loadCustomWorkouts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete workout: $e')),
          );
        }
      }
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      return const Color(0xFF3C467B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Workout Plans',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3C467B)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddWorkoutBottomSheet(),
              );

              // Reload workouts if a new one was added
              if (result == true) {
                _loadCustomWorkouts();
              }
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
                    child: QuickStatCard(
                      value: '12',
                      label: 'Workouts\nCompleted',
                      color: const Color(0xFF6E8CFB),
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickStatCard(
                      value: '45',
                      label: 'Minutes\nToday',
                      color: const Color(0xFF636CCB),
                      icon: Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickStatCard(
                      value: '5',
                      label: 'Day\nStreak',
                      color: const Color(0xFF50589C),
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
            ),

            // Custom Workouts Section
            if (customWorkouts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Custom Workouts',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${customWorkouts.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                    childAspectRatio = 0.9;
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 3;
                    childAspectRatio = 0.75;
                  } else {
                    crossAxisCount = 2;
                    childAspectRatio = 0.6;
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
                    itemCount: customWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = customWorkouts[index];
                      return _buildCustomWorkoutCard(workout);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],

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
                  crossAxisCount = 4;
                  childAspectRatio = 0.9;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.75;
                } else {
                  crossAxisCount = 2;
                  childAspectRatio = 0.6;
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
                    return WorkoutCard(
                      title: program['title']!,
                      duration: program['duration']!,
                      level: program['level']!,
                      target: program['target']!,
                      exercises: program['exercises']!,
                      icon: program['icon'] as IconData,
                      color: program['color'] as Color,
                      badge: program['badge']!,
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
                return PopularWorkoutCard(
                  title: workout['title']!,
                  duration: workout['duration']!,
                  calories: workout['calories']!,
                  level: workout['level']!,
                  icon: workout['icon'] as IconData,
                  color: workout['color'] as Color,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomWorkoutCard(CustomWorkout workout) {
    final color = _getColorFromHex(workout.color);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomWorkoutDetailPage(
              workout: workout,
            ),
          ),
        );
      },
      onLongPress: () {
        _showWorkoutOptions(workout);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                    child: Icon(Icons.fitness_center, size: 50, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              workout.duration,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.fitness_center, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${workout.exercises.length} exercises',
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
                            workout.level,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                  'Custom',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showWorkoutOptions(workout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutOptions(CustomWorkout workout) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              workout.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF3C467B)),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showWorkoutDetails(workout);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Workout'),
              onTap: () {
                Navigator.pop(context);
                _deleteWorkout(workout.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(CustomWorkout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workout.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Duration', workout.duration),
              _buildDetailRow('Level', workout.level),
              _buildDetailRow('Target Muscle', workout.targetMuscle),
              const SizedBox(height: 16),
              const Text(
                'Exercises:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Fixed: Now iterating over Exercise objects, not Strings
              ...workout.exercises.map((exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            exercise.equipment,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
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


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
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