import 'package:flutter/cupertino.dart';
import '../../../domain/models/custom_workout.dart';
import '../../pages/custom_workout_detail_page.dart';
import './workout_card_actions.dart';

class CustomWorkoutCard extends StatelessWidget {
  final CustomWorkout workout;
  final VoidCallback onDeleted;

  const CustomWorkoutCard({
    Key? key,
    required this.workout,
    required this.onDeleted,
  }) : super(key: key);

  Color _getColor() {
    try {
      return Color(int.parse(workout.color));
    } catch (e) {
      return const Color(0xFF3C467B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      onLongPress: () => _showOptions(context),
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
                _buildHeader(color),
                Expanded(child: _buildContent(color)),
              ],
            ),
            _buildBadge(color),
            _buildMenuButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
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
    );
  }

  Widget _buildContent(Color color) {
    return Padding(
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
          _buildInfoRow(CupertinoIcons.time, workout.duration),
          const SizedBox(height: 4),
          _buildInfoRow(
            CupertinoIcons.sportscourt,
            '${workout.exercises.length} exercises',
          ),
          const Spacer(),
          _buildLevelBadge(color),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CupertinoColors.systemGrey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.systemGrey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(Color color) {
    return Container(
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
    );
  }

  Widget _buildBadge(Color color) {
    return Positioned(
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
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 20,
        child: const Icon(CupertinoIcons.ellipsis, size: 20),
        onPressed: () => _showOptions(context),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CustomWorkoutDetailPage(workout: workout),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    WorkoutCardActions.show(
      context: context,
      workout: workout,
      onDeleted: onDeleted,
    );
  }
}