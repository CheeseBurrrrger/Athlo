import 'package:athlo/pages/add_activity_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  State<ActivityFeedPage> createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {

  // 🔧 Helper: format timestamp menjadi "Just now / 2 hours ago"
  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return "Just now";

    final date = ts.toDate();
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    return "${diff.inDays} days ago";
  }

  // 🔧 Helper: mapping ikon berdasarkan activityType
  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case "running":
        return Icons.directions_run;
      case "cycling":
        return Icons.directions_bike;
      case "gym workout":
        return Icons.fitness_center;
      case "yoga":
        return Icons.self_improvement;
      case "swimming":
        return Icons.pool;
      case "hiking":
        return Icons.terrain;
      default:
        return Icons.sports; // fallback ikon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1974F5),
        title: const Text(
          'Community Feed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // STREAMBUILDER → real-time feed dari Firestore
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No activities yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              // 🔒 Pastikan semua field aman
              final userName = data['userName'] ?? "Unknown User";
              final activityType = data['activityType'] ?? "Unknown";
              final distance = data['distance'] ?? "-";
              final time = data['time'] ?? "-";
              final calories = data['calories'] ?? "-";
              final ts = data['createdAt'];

              return ActivityCard(
                activity: Activity(
                  userName: userName,
                  userAvatar: userName[0],
                  activityType: activityType,
                  distance: distance,
                  time: time,
                  calories: calories,
                  timestamp: _formatTimestamp(ts),
                  likes: 0,
                  comments: 0,
                  icon: _getActivityIcon(activityType),
                  color: const Color(0xFF6E8CFB),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddActivityPage()),
          );
        },
        backgroundColor: const Color(0xFF6E8CFB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

//
// ───────────────────────────────────────── ACTIVITY MODEL ──────────────
//

class Activity {
  final String userName;
  final String userAvatar;
  final String activityType;
  final String distance;
  final String time;
  final String calories;
  final String timestamp;
  final int likes;
  final int comments;
  final IconData icon;
  final Color color;

  Activity({
    required this.userName,
    required this.userAvatar,
    required this.activityType,
    required this.distance,
    required this.time,
    required this.calories,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.icon,
    required this.color,
  });
}

//
// ─────────────────────────────────────── ACTIVITY CARD UI ──────────────
//

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildActivityInfo(),
            const SizedBox(height: 12),
            _buildStats(),
            const Divider(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: activity.color,
          child: Text(
            activity.userAvatar,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(activity.timestamp,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Icon(activity.icon, color: activity.color, size: 28),
      ],
    );
  }

  Widget _buildActivityInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: activity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(activity.icon, color: activity.color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Completed ${activity.activityType}',
            style: TextStyle(
              color: activity.color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activity.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStat(Icons.straighten, '${activity.distance} km'),
        _buildStat(Icons.timer, activity.time),
        _buildStat(Icons.local_fire_department, '${activity.calories} kcal'),
      ],
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildAction(Icons.favorite_border, activity.likes.toString()),
        const SizedBox(width: 16),
        _buildAction(Icons.chat_bubble_outline, activity.comments.toString()),
      ],
    );
  }

  Widget _buildAction(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
