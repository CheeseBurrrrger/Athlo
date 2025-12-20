import 'package:flutter/cupertino.dart';
import '../../../domain/models/custom_workout.dart';
import '../../pages/custom_workout_detail_page.dart';

class FeaturedWorkoutCard extends StatelessWidget {
  final CustomWorkout workout;

  const FeaturedWorkoutCard({
    Key? key,
    required this.workout,
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
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => CustomWorkoutDetailPage(workout: workout),
        ),
      ),
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
            _buildFeaturedBadge(),
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
          CupertinoIcons.star_fill,
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

  Widget _buildFeaturedBadge() {
    return Positioned(
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
          children: const [
            Icon(
              CupertinoIcons.star_fill,
              size: 10,
              color: CupertinoColors.white,
            ),
            SizedBox(width: 4),
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
    );
  }
}