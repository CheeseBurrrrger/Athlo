import 'package:athlo/models/custom_workout.dart';
import 'package:athlo/models/workout_session.dart';
import 'package:athlo/pages/workout_summary_page.dart';
import 'package:athlo/services/workout_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startWorkoutTimer();
  }

  void _initializeSession() {
    session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: widget.workout.id,
      userId: widget.workout.uId,
      startTime: DateTime.now(),
      exercises: widget.workout.exercises.map((exercise) {
        return ExerciseSession(
          exerciseId: exercise.name,
          name: exercise.name,
          equipment: exercise.equipment,
          sets: List.generate(3, (_) => SetData()), // Default 3 sets
        );
      }).toList(),
    );
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
    setState(() {
      final currentExercise = session.exercises[currentExerciseIndex];
      currentExercise.sets[setIndex].isCompleted = true;
      currentExercise.sets[setIndex].completedAt = DateTime.now();
    });

    // Start rest timer (90 seconds default)
    _startRestTimer(90);

    // Show feedback
    _showFeedback('Set ${setIndex + 1} completed! 💪');
  }

  void _nextExercise() {
    if (currentExerciseIndex < session.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      _finishWorkout();
    }
  }

  void _previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
      });
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
      builder: (context) => CupertinoAlertDialog(
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
                // Save partial session
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


  void _showFeedback(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    workoutTimer?.cancel();
    restTimer?.cancel();
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
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${currentExerciseIndex + 1}/${session.exercises.length}',
          style: const TextStyle(color: CupertinoColors.systemGrey),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
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
                margin: const EdgeInsets.all(16),
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
                      size: 40,
                      color: CupertinoColors.systemOrange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restTimeRemaining.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemOrange,
                      ),
                    ),
                    const Text('Rest Time'),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      child: const Text('Skip Rest'),
                      onPressed: () {
                        restTimer?.cancel();
                        setState(() => isResting = false);
                      },
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
                    // Exercise Info
                    Text(
                      currentExercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentExercise.equipment,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sets
                    ...currentExercise.sets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final set = entry.value;
                      return _buildSetRow(index, set);
                    }),

                    const SizedBox(height: 16),

                    // Add Set Button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          currentExercise.sets.add(SetData());
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.add_circled),
                            SizedBox(width: 8),
                            Text('Add Set'),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: CupertinoColors.systemGrey5,
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: CupertinoColors.black),
                        ),
                        onPressed: _previousExercise,
                      ),
                    ),
                  if (currentExerciseIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: currentExercise.isCompleted
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemGrey4,
                      onPressed: currentExercise.isCompleted
                          ? _nextExercise
                          : null,
                      child: Text(
                        currentExerciseIndex == session.exercises.length - 1
                            ? 'Finish Workout'
                            : 'Next Exercise',
                        style: TextStyle(
                          color: currentExercise.isCompleted
                              ? CupertinoColors.white
                              : CupertinoColors.systemGrey,
                          fontWeight: FontWeight.bold,
                        ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? CupertinoColors.activeGreen.withOpacity(0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: set.isCompleted
              ? CupertinoColors.activeGreen
              : CupertinoColors.systemGrey4,
          width: set.isCompleted ? 2 : 1,
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
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: set.isCompleted
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Reps Input
          Expanded(
            child: CupertinoTextField(
              placeholder: 'Reps',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !set.isCompleted,
              onChanged: (value) {
                set.reps = int.tryParse(value) ?? 0;
              },
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight Input (optional)
          Expanded(
            child: CupertinoTextField(
              placeholder: 'Weight',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !set.isCompleted,
              onChanged: (value) {
                set.weight = double.tryParse(value);
              },
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Complete Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: set.isCompleted ? null : () => _completeSet(index),
            child: Icon(
              set.isCompleted
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              size: 32,
              color: set.isCompleted
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}