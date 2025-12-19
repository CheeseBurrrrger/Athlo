import 'package:athlo/services/auth_service.dart';
import 'package:athlo/services/custom_workout_service.dart';
import 'package:athlo/services/workout_session_service.dart';
import 'package:athlo/services/featured_workout_service.dart';
import 'package:athlo/widgets/add_feature_workout_bottom_sheet.dart' hide AddFeaturedWorkoutBottomSheet;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/custom_workout_detail_page.dart';
import '../pages/workout_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import '../widgets/workout_card.dart';
import '../widgets/popular_workout_card.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/add_workout_bottom_sheet.dart';
import '../widgets/add_feature_workout_bottom_sheet.dart';
import '../widgets/edit_workout_bottom_sheet.dart';
import '../services/workout_storage_service.dart';
import '../models/custom_workout.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutStorageService _storageService = WorkoutStorageService();
  WorkoutService workoutService = WorkoutService();
  WorkoutSessionService workoutSessionService = WorkoutSessionService();
  FeaturedWorkoutService featuredWorkoutService = FeaturedWorkoutService();

  List<CustomWorkout> customWorkouts = [];
  bool isLoading = true;
  Map<String, dynamic> workoutStats = {
    'totalWorkouts': 0,
    'totalMinutes': 0,
    'averageDuration': 0,
    'todayMinutes': 0,
    'currentStreak': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
    _loadWorkoutStats();
  }

  Future<void> _loadWorkoutStats() async {
    try {
      final uId = authService.value.currentUser!.uid;
      final stats = await workoutSessionService.getWorkoutStats(uId);
      setState(() {
        workoutStats = stats;
      });
    } catch (e) {
      print('Error loading workout stats: $e');
    }
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

  Future<void> _editWorkout(CustomWorkout workout) async {
    final result = await showCupertinoModalPopup(
      context: context,
      builder: (context) => EditWorkoutBottomSheet(workout: workout),
    );

    if (result == true) {
      await _loadCustomWorkouts();
      if (mounted) {
        _showSuccessDialog('Workout updated successfully');
      }
    }
  }

  Future<void> _deleteWorkout(CustomWorkout workout) async {
    print('Attempting to delete workout with ID: ${workout.id}');

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await workoutService.delete(workout.id);

        if (mounted) {
          _showSuccessDialog('Workout deleted');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Failed to delete workout: $e');
        }
      }
    }
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      return const Color(0xFF3C467B);
    }
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 6;
    } else if (width > 900) {
      return 4;
    } else if (width > 600) {
      return 3;
    } else {
      return 2;
    }
  }

  double _getGridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 0.75;
    } else if (width > 900) {
      return 0.7;
    } else if (width > 600) {
      return 0.65;
    } else {
      return 0.6;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uId = authService.value.currentUser!.uid;
    print("userId : " + uId);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Workout Plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
<<<<<<< HEAD
        backgroundColor: const Color(0xFF1974F5),
=======
        backgroundColor: CupertinoColors.activeBlue,
>>>>>>> ec265f766ea74e51ab4935f9a07c17d6aae6dfdf
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.star, color: CupertinoColors.white),
          onPressed: () async {
            final result = await showCupertinoModalPopup(
              context: context,
              builder: (context) => const AddFeaturedWorkoutBottomSheet(),
            );

            if (result == true) {
            }
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () async {
            final result = await showCupertinoModalPopup(
              context: context,
              builder: (context) => const AddWorkoutBottomSheet(),
            );

            if (result == true) {
              _loadCustomWorkouts();
            }
          },
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
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
                        color: CupertinoColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih program latihan sesuai level dan tujuan Anda',
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: QuickStatCard(
                        value: workoutStats['totalWorkouts'].toString(),
                        label: 'Workouts\nCompleted',
                        color: const Color(0xFF6E8CFB),
                        icon: CupertinoIcons.check_mark_circled_solid,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickStatCard(
                        value: workoutStats['todayMinutes'].toString(),
                        label: 'Minutes\nToday',
                        color: const Color(0xFF636CCB),
                        icon: CupertinoIcons.timer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickStatCard(
                        value: workoutStats['currentStreak'].toString(),
                        label: 'Day\nStreak',
                        color: const Color(0xFF50589C),
                        icon: CupertinoIcons.flame_fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            StreamBuilder<List>(
              stream: workoutService.readSpecificUser(uId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    ),
                  );
                }
                final customWorkouts = snapshot.data ?? [];
                if (customWorkouts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getGridCrossAxisCount(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: _getGridChildAspectRatio(context),
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final workout = customWorkouts[index];
                            return _buildCustomWorkoutCard(workout);
                          },
                          childCount: customWorkouts.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Featured Programs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            StreamBuilder<List<CustomWorkout>>(
              stream: featuredWorkoutService.readAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    ),
                  );
                }
                final featuredWorkouts = snapshot.data ?? [];
                if (featuredWorkouts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.star,
                              size: 48,
                              color: CupertinoColors.systemGrey3,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No featured workouts yet',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the star icon to add one',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey2,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getGridCrossAxisCount(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: _getGridChildAspectRatio(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final workout = featuredWorkouts[index];
                        return _buildFeaturedWorkoutCard(workout);
                      },
                      childCount: featuredWorkouts.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Popular Workouts
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Popular Workouts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final workout = popularWorkouts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PopularWorkoutCard(
                        title: workout['title']!,
                        duration: workout['duration']!,
                        calories: workout['calories']!,
                        level: workout['level']!,
                        icon: workout['icon'] as IconData,
                        color: workout['color'] as Color,
                      ),
                    );
                  },
                  childCount: popularWorkouts.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
          CupertinoPageRoute(
            builder: (context) => CustomWorkoutDetailPage(workout: workout),
          ),
        );
      },
      onLongPress: () {
        _showWorkoutOptions(workout);
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.08),
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
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.sportscourt,
                      size: 50,
                      color: CupertinoColors.white,
                    ),
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
                            color: CupertinoColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              size: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout.duration,
                              style: const TextStyle(
                                fontSize: 11,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.sportscourt,
                              size: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${workout.exercises.length} exercises',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CupertinoColors.systemGrey,
                                ),
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
                  color: CupertinoColors.white,
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
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 20,
                child: const Icon(CupertinoIcons.ellipsis, size: 20),
                onPressed: () => _showWorkoutOptions(workout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedWorkoutCard(CustomWorkout workout) {
    final color = _getColorFromHex(workout.color);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CustomWorkoutDetailPage(workout: workout),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.08),
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
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.star_fill,
                      size: 50,
                      color: CupertinoColors.white,
                    ),
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
                            color: CupertinoColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              size: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout.duration,
                              style: const TextStyle(
                                fontSize: 11,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.sportscourt,
                              size: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${workout.exercises.length} exercises',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CupertinoColors.systemGrey,
                                ),
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
                  color: CupertinoColors.systemYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 10,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutOptions(CustomWorkout workout) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          workout.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showWorkoutDetails(workout);
            },
            child: const Text('View Details'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _editWorkout(workout);
            },
            child: const Text('Edit Workout'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkout(workout);
            },
            child: const Text('Delete Workout'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showWorkoutDetails(CustomWorkout workout) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(workout.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildDetailRow('Duration', workout.duration),
              _buildDetailRow('Level', workout.level),
              _buildDetailRow('Target Muscle', workout.targetMuscle),
              const SizedBox(height: 16),
              const Text(
                'Exercises:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
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
          CupertinoDialogAction(
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
      'icon': CupertinoIcons.sportscourt,
      'color': const Color(0xFF6E8CFB),
      'badge': 'Popular',
    },
    {
      'title': 'Full Body Strength',
      'duration': '45-60 min',
      'level': 'Beginner',
      'target': 'All Muscles',
      'exercises': '10 exercises',
      'icon': CupertinoIcons.person,
      'color': const Color(0xFF636CCB),
      'badge': 'New',
    },
    {
      'title': 'Upper Body Focus',
      'duration': '50 min',
      'level': 'Advanced',
      'target': 'Chest, Back, Arms',
      'exercises': '12 exercises',
      'icon': CupertinoIcons.arrow_up_circle,
      'color': const Color(0xFF50589C),
      'badge': '',
    },
    {
      'title': 'Leg Day Power',
      'duration': '55 min',
      'level': 'Intermediate',
      'target': 'Legs, Glutes',
      'exercises': '9 exercises',
      'icon': CupertinoIcons.arrow_down_circle,
      'color': const Color(0xFF6E8CFB),
      'badge': 'Trending',
    },
    {
      'title': 'Core Blast',
      'duration': '30 min',
      'level': 'All Levels',
      'target': 'Abs, Core',
      'exercises': '6 exercises',
      'icon': CupertinoIcons.circle_grid_3x3,
      'color': const Color(0xFF3C467B),
      'badge': '',
    },
    {
      'title': 'Push Pull Legs',
      'duration': '70 min',
      'level': 'Advanced',
      'target': 'Full Body',
      'exercises': '15 exercises',
      'icon': CupertinoIcons.bolt,
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
      'icon': CupertinoIcons.flame,
      'color': const Color(0xFF6E8CFB),
    },
    {
      'title': 'HIIT Intensity',
      'duration': '20 min',
      'calories': '400 cal',
      'level': 'Advanced',
      'icon': CupertinoIcons.bolt_fill,
      'color': const Color(0xFF636CCB),
    },
    {
      'title': 'Yoga Flow',
      'duration': '40 min',
      'calories': '150 cal',
      'level': 'All Levels',
      'icon': CupertinoIcons.heart,
      'color': const Color(0xFF50589C),
    },
  ];
}