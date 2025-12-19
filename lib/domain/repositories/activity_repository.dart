import '../entities/activity.dart';

abstract class ActivityRepository {
  Stream<List<Activity>> getActivities();
  Future<void> addActivity(Activity activity);
}