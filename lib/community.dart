import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Community',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6E8CFB),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6E8CFB),
          primary: const Color(0xFF6E8CFB),
          secondary: const Color(0xFF50589C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6E8CFB),
          elevation: 0,
        ),
      ),
      home: const ActivityFeedPage(),
    );
  }
}

class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  State<ActivityFeedPage> createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Feed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: const SinglePageLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6E8CFB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SinglePageLayout extends StatelessWidget {
  const SinglePageLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activities = _getActivities();
    final challenges = _getChallenges();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Activity Feed', Icons.feed),
        const SizedBox(height: 16),
        ...activities.map((activity) => ActivityCard(activity: activity)),

        const SizedBox(height: 32),

        _buildSectionHeader('Challenges', Icons.emoji_events),
        const SizedBox(height: 16),
        _buildChallengesGrid(context, challenges),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6E8CFB), size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6E8CFB),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesGrid(BuildContext context, List<Challenge> challenges) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return ChallengeCard(challenge: challenges[index]);
          },
        );
      },
    );
  }

  List<Activity> _getActivities() {
    return [
      Activity(
        userName: 'Dody Syah',
        userAvatar: 'D',
        activityType: 'Run',
        distance: '5.2',
        time: '28:45',
        calories: '342',
        timestamp: '2 hours ago',
        likes: 24,
        comments: 5,
        icon: Icons.directions_run,
        color: const Color(0xFF6E8CFB),
      ),
      Activity(
        userName: 'Fikri Irfan',
        userAvatar: 'F',
        activityType: 'Cycling',
        distance: '15.8',
        time: '52:30',
        calories: '528',
        timestamp: '4 hours ago',
        likes: 31,
        comments: 8,
        icon: Icons.directions_bike,
        color: const Color(0xFF50589C),
      ),
      Activity(
        userName: 'Raditya Ramadhan',
        userAvatar: 'R',
        activityType: 'Gym Workout',
        distance: '-',
        time: '1:15:00',
        calories: '456',
        timestamp: '5 hours ago',
        likes: 18,
        comments: 3,
        icon: Icons.fitness_center,
        color: const Color(0xFF6E8CFB),
      ),
      Activity(
        userName: 'Javier Hafizh',
        userAvatar: 'J',
        activityType: 'Swimming',
        distance: '1.5',
        time: '45:20',
        calories: '398',
        timestamp: '6 hours ago',
        likes: 42,
        comments: 12,
        icon: Icons.pool,
        color: const Color(0xFF50589C),
      ),
    ];
  }

  List<Challenge> _getChallenges() {
    return [
      Challenge(
        title: '50km October Run',
        description: 'Run 50km total this month',
        participants: 234,
        daysLeft: 12,
        progress: 0.65,
        icon: Icons.directions_run,
        color: const Color(0xFF6E8CFB),
        backgroundImage: 'run_bg.jpg',
      ),
      Challenge(
        title: '100 Push-ups Daily',
        description: 'Do 100 push-ups every day',
        participants: 567,
        daysLeft: 7,
        progress: 0.42,
        icon: Icons.fitness_center,
        color: const Color(0xFF50589C),
        backgroundImage: 'pushup_bg.jpg',
      ),
      Challenge(
        title: 'Yoga Week Challenge',
        description: '7 days of yoga practice',
        participants: 189,
        daysLeft: 3,
        progress: 0.85,
        icon: Icons.self_improvement,
        color: const Color(0xFF6E8CFB),
        backgroundImage: 'yoga_bg.jpg',
      ),
      Challenge(
        title: '10km Cycling Sprint',
        description: 'Complete 10km in under 30min',
        participants: 312,
        daysLeft: 15,
        progress: 0.30,
        icon: Icons.directions_bike,
        color: const Color(0xFF50589C),
        backgroundImage: 'cycling_bg.jpg',
      ),
    ];
  }
}

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
          Text('Completed ${activity.activityType}',
              style: TextStyle(
                  color: activity.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
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
        const SizedBox(width: 16),
        _buildAction(Icons.share_outlined, 'Share'),
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

class Challenge {
  final String title;
  final String description;
  final int participants;
  final int daysLeft;
  final double progress;
  final IconData icon;
  final Color color;
  final String backgroundImage;

  Challenge({
    required this.title,
    required this.description,
    required this.participants,
    required this.daysLeft,
    required this.progress,
    required this.icon,
    required this.color,
    required this.backgroundImage,
  });
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({Key? key, required this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage('assets/images/${challenge.backgroundImage}'),
            fit: BoxFit.cover,
            colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(challenge.icon, color: Colors.white, size: 32),
                  const Spacer(),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${challenge.daysLeft} days',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(challenge.description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 14)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('${challenge.participants} participants',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: challenge.progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text('${(challenge.progress * 100).toInt()}% completed',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}