import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/activity.dart';
import '../domain/repositories/activity_repository.dart';

class FirebaseActivityService implements ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Activity>> getActivities() {
    return _firestore
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          userName: data['userName'] ?? 'Unknown',
          activityType: data['activityType'] ?? '-',
          distance: data['distance'] ?? '-',
          time: data['time'] ?? '-',
          calories: data['calories'] ?? '-',
          createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Future<void> addActivity(Activity activity) async {
    await _firestore.collection('activities').add({
      'userName': activity.userName,
      'activityType': activity.activityType,
      'distance': activity.distance,
      'time': activity.time,
      'calories': activity.calories,
      'createdAt': Timestamp.fromDate(activity.createdAt),
    });
  }
}