import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
import '../../data/models/activity.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/services/isar_service.dart';
import '../utils/date_utils.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'mark_done') {
    final payload = notificationResponse.payload;
    if (payload != null) {
      final activityId = int.tryParse(payload);
      if (activityId != null) {
        // Initialize Isar for background isolate
        await IsarService.instance.init();
        
        // Mark as done
        final repo = CompletionRepository();
        await repo.toggle(activityId, PaceDateUtils.todayKey());
        
        // Cancel the notification
        final plugin = FlutterLocalNotificationsPlugin();
        await plugin.cancel(activityId);
      }
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle foreground/terminated tap
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create channel for Android
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'challenge_reminders',
            'Challenge Reminders',
            description: 'Persistent notifications for pending challenges',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ));
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    } else if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> showChallengeNotification(Activity activity) async {
    const androidDetails = AndroidNotificationDetails(
      'challenge_reminders',
      'Challenge Reminders',
      channelDescription: 'Persistent notifications for pending challenges',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'mark_done',
          'Mark Done',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      activity.id,
      'Challenge Pending: ${activity.name}',
      'Don\'t forget to complete your challenge for today!',
      notificationDetails,
      payload: activity.id.toString(),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
