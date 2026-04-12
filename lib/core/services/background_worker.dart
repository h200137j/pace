import 'package:workmanager/workmanager.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/services/isar_service.dart';
import '../utils/date_utils.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 1. Initialize Isar
      await IsarService.instance.init();
      
      final activityRepo = ActivityRepository();
      final completionRepo = CompletionRepository();
      
      // 2. Query all challenges
      final allActivities = await activityRepo.getAll();
      final challenges = allActivities.where((a) => a.type == ActivityType.challenge).toList();
      
      final todayKey = PaceDateUtils.todayKey();
      
      for (final challenge in challenges) {
        final isDoneToday = await completionRepo.isCompleted(challenge.id, todayKey);
        
        if (isDoneToday) {
          // If done, cancel any existing sticky notification
          await NotificationService.instance.cancelNotification(challenge.id);
        } else {
          // If not done, show/update the persistent notification
          await NotificationService.instance.showChallengeNotification(challenge);
        }
      }
      
      return Future.value(true);
    } catch (e) {
      // Log errors if necessary
      return Future.value(false);
    }
  });
}

class BackgroundWorker {
  static final BackgroundWorker instance = BackgroundWorker._();
  BackgroundWorker._();

  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  Future<void> registerChallengeCheck() async {
    await Workmanager().registerPeriodicTask(
      'challenge-check-task',
      'checkChallenges',
      frequency: const Duration(minutes: 15), // Lowest allowed for Android
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }
}
