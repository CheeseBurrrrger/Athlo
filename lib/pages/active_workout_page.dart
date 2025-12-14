import 'package:athlo/models/custom_workout.dart';
import 'package:athlo/models/workout_session.dart';
import 'package:athlo/pages/workout_summary_page.dart';
import 'package:athlo/services/auth_service.dart';
import 'package:athlo/services/workout_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

class ActiveWorkoutPage extends StatefulWidget {
  final CustomWorkout workout;

  const ActiveWorkoutPage({Key? key, required this.workout}) : super(key: key);

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  late WorkoutSession session;
  int currentExerciseIndex = 0;
  Timer? workoutTimer;
  Timer? restTimer;
  int restTimeRemaining = 0;
  bool isResting = false;

  // Controllers for input fields
  final List<List<TextEditingController>> _repsControllers = [];
  final List<List<TextEditingController>> _weightControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startWorkoutTimer();
    _initializeControllers();
  }

  void _initializeSession() {
    session = WorkoutSession(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      workoutId: widget.workout.id,
      userId: authService.value.currentUser!.uid,
      startTime: DateTime.now(),
      exercises: widget.workout.exercises.map((exercise) {
        return ExerciseSession(
          exerciseId: exercise.name,
          name: exercise.name,
          equipment: exercise.equipment,
          sets: List.generate(3, (_) => SetData()),
        );
      }).toList(),
    );
  }

  void _initializeControllers() {
    for (var exercise in session.exercises) {
      List<TextEditingController> repsControllers = [];
      List<TextEditingController> weightControllers = [];
      for (var _ in exercise.sets) {
        repsControllers.add(TextEditingController());
        weightControllers.add(TextEditingController());
      }
      _repsControllers.add(repsControllers);
      _weightControllers.add(weightControllers);
    }
  }

  void _startWorkoutTimer() {
    workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _startRestTimer(int seconds) {
    setState(() {
      isResting = true;
      restTimeRemaining = seconds;
    });

    restTimer?.cancel();
    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimeRemaining > 0) {
        setState(() => restTimeRemaining--);
      } else {
        timer.cancel();
        setState(() => isResting = false);
      }
    });
  }

  void _completeSet(int setIndex) {
    final currentExercise = session.exercises[currentExerciseIndex];
    final set = currentExercise.sets[setIndex];

    // Validate input
    if (set.reps == 0) {
      _showQuickFeedback('Please enter reps', isError: true);
      return;
    }

    setState(() {
      set.isCompleted = true;
      set.completedAt = DateTime.now();
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start rest timer only if not the last set of the exercise
    bool isLastSet = setIndex == currentExercise.sets.length - 1;
    if (!isLastSet) {
      _startRestTimer(90);
    }

    _showQuickFeedback('Set ${setIndex + 1} completed! 💪');
  }

  void _nextExercise() {
    if (currentExerciseIndex < session.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        isResting = false;
        restTimer?.cancel();
      });
      HapticFeedback.lightImpact();
    } else {
      _finishWorkout();
    }
  }

  void _previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        isResting = false;
        restTimer?.cancel();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _finishWorkout() async {
    session.endTime = DateTime.now();
    session.status = 'completed';

    try {
      await _sessionService.saveSession(session);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => WorkoutSummaryPage(session: session),
          ),
        );
      }
    } catch (e) {
      print('Error saving workout: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => WorkoutSummaryPage(session: session),
          ),
        );
      }
    }
  }

  void _quitWorkout() {
    showCupertinoDialog(
      context: context,
      builder: (context) =>
          CupertinoAlertDialog(
            title: const Text('Quit Workout?'),
            content: const Text('Your progress will be saved'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Quit'),
                onPressed: () async {
                  session.endTime = DateTime.now();
                  session.status = 'abandoned';

                  try {
                    await _sessionService.saveSession(session);
                  } catch (e) {
                    print('Error saving partial workout: $e');
                  }

                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _showQuickFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError
            ? CupertinoColors.systemRed
            : CupertinoColors.activeGreen,
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _adjustRestTime(int seconds) {
    setState(() {
      restTimeRemaining = (restTimeRemaining + seconds).clamp(0, 300);
      if (restTimeRemaining == 0) {
        restTimer?.cancel();
        isResting = false;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _showExerciseDetails() {
    final currentExercise = widget.workout.exercises[currentExerciseIndex];
    final color = widget.workout.color != null
        ? Color(int.parse(widget.workout.color!))
        : CupertinoColors.activeBlue;

    showCupertinoModalPopup(
      context: context,
      builder: (context) =>
          Material(
            color: CupertinoColors.systemBackground,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.85,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  CupertinoNavigationBar(
                    backgroundColor: CupertinoColors.systemBackground,
                    border: null,
                    middle: Text(
                      currentExercise.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Equipment
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.settings, size: 14,
                                      color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentExercise.equipment,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // GIF
                            if (currentExercise.gifUrl.isNotEmpty)
                              Container(
                                height: 250,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    currentExercise.gifUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child,
                                        loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CupertinoActivityIndicator(
                                            color: color),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.photo,
                                              size: 50,
                                              color: CupertinoColors
                                                  .systemGrey3,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'GIF not available',
                                              style: TextStyle(
                                                color: CupertinoColors
                                                    .systemGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            // Target muscles
                            if (currentExercise.targetMuscles.isNotEmpty) ...[
                              const Text(
                                'Target Muscles',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: currentExercise.targetMuscles.map((
                                    muscle) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      muscle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Secondary muscles
                            if (currentExercise.secondaryMuscles
                                .isNotEmpty) ...[
                              const Text(
                                'Secondary Muscles',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: currentExercise.secondaryMuscles.map((
                                    muscle) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey6,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      muscle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.label,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Instructions
                            if (currentExercise.instructions.isNotEmpty) ...[
                              const Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...currentExercise.instructions
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.systemGrey,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    workoutTimer?.cancel();
    restTimer?.cancel();
    for (var controllers in _repsControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    for (var controllers in _weightControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = session.exercises[currentExerciseIndex];
    final duration = session.duration;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark),
          onPressed: _quitWorkout,
        ),
        middle: Text(
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(
              2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: Text(
          '${currentExerciseIndex + 1}/${session.exercises.length}',
          style: const TextStyle(
              color: CupertinoColors.systemGrey, fontSize: 14),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: session.progressPercentage / 100,
                  backgroundColor: CupertinoColors.systemGrey5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.workout.color != null
                        ? Color(int.parse(widget.workout.color!))
                        : CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ),

            // Rest Timer Overlay
            if (isResting)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.systemOrange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.timer,
                      size: 36,
                      color: CupertinoColors.systemOrange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${restTimeRemaining ~/ 60}:${(restTimeRemaining % 60)
                          .toString()
                          .padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemOrange,
                      ),
                    ),
                    const Text(
                      'Rest Time',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          onPressed: () => _adjustRestTime(-15),
                          child: const Text('-15s', style: TextStyle(
                              fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          child: const Text('Skip Rest'),
                          onPressed: () {
                            restTimer?.cancel();
                            setState(() => isResting = false);
                            HapticFeedback.mediumImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          onPressed: () => _adjustRestTime(15),
                          child: const Text('+15s', style: TextStyle(
                              fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Info with Demo Button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentExercise.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentExercise.equipment,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Info button to view exercise details
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _showExerciseDetails,
                          child: Icon(
                            CupertinoIcons.info_circle,
                            color: widget.workout.color != null
                                ? Color(int.parse(widget.workout.color!))
                                : CupertinoColors.activeBlue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    // Show GIF if available
                    if (widget.workout.exercises[currentExerciseIndex].gifUrl
                        .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.workout.exercises[currentExerciseIndex]
                                .gifUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.photo,
                                      size: 40,
                                      color: CupertinoColors.systemGrey3,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'GIF not available',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Sets section with progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentExercise.sets
                                .where((s) => s.isCompleted)
                                .length}/${currentExercise.sets
                                .length} completed',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Column headers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 56),
                          Expanded(
                            child: Text(
                              'REPS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemGrey.withOpacity(
                                    0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'WEIGHT (KG)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemGrey.withOpacity(
                                    0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                    ),

                    // Sets
                    ...currentExercise.sets
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final set = entry.value;
                      return _buildSetRow(index, set);
                    }),

                    const SizedBox(height: 12),

                    // Add Set Button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          currentExercise.sets.add(SetData());
                          _repsControllers[currentExerciseIndex].add(
                              TextEditingController());
                          _weightControllers[currentExerciseIndex].add(
                              TextEditingController());
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.add_circled, size: 20),
                            SizedBox(width: 8),
                            Text('Add Set',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (currentExerciseIndex > 0)
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(12),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.chevron_left, size: 16,
                                color: CupertinoColors.black),
                            SizedBox(width: 4),
                            Text(
                              'Previous',
                              style: TextStyle(
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onPressed: _previousExercise,
                      ),
                    ),
                  if (currentExerciseIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: currentExercise.isCompleted
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: currentExercise.isCompleted
                          ? _nextExercise
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentExerciseIndex == session.exercises.length - 1
                                ? 'Finish Workout'
                                : 'Next Exercise',
                            style: TextStyle(
                              color: currentExercise.isCompleted
                                  ? CupertinoColors.white
                                  : CupertinoColors.systemGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (currentExercise.isCompleted &&
                              currentExerciseIndex < session.exercises.length -
                                  1) ...[
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: CupertinoColors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int index, SetData set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? CupertinoColors.activeGreen.withOpacity(0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: set.isCompleted
              ? CupertinoColors.activeGreen
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: set.isCompleted
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (!set.isCompleted)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: set.isCompleted
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps Input
          Expanded(
            child: CupertinoTextField(
              controller: _repsControllers[currentExerciseIndex][index],
              placeholder: '0',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !set.isCompleted,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (value) {
                set.reps = int.tryParse(value) ?? 0;
              },
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
          ),
          const SizedBox(width: 12),

          // Weight Input
          Expanded(
            child: CupertinoTextField(
              controller: _weightControllers[currentExerciseIndex][index],
              placeholder: '0',
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              textAlign: TextAlign.center,
              enabled: !set.isCompleted,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (value) {
                set.weight = double.tryParse(value);
              },
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
          ),
          const SizedBox(width: 12),

          // Complete Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: set.isCompleted ? null : () => _completeSet(index),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? CupertinoColors.activeGreen
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: set.isCompleted
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemGrey3,
                  width: 2,
                ),
              ),
              child: Icon(
                set.isCompleted
                    ? CupertinoIcons.checkmark_alt
                    : CupertinoIcons.checkmark_alt,
                size: 18,
                color: set.isCompleted
                    ? CupertinoColors.white
                    : CupertinoColors.systemGrey3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}