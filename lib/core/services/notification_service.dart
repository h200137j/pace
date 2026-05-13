import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/activity.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/services/isar_service.dart';
import '../utils/date_utils.dart';
import 'activity_notification_store.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'mark_done') {
    final payload = notificationResponse.payload;
    if (payload != null) {
      final activityId = int.tryParse(payload);
      if (activityId != null) {
        await IsarService.instance.init();
        final repo = CompletionRepository();
        await repo.checkIn(activityId, PaceDateUtils.todayKey(), 1);
        final plugin = FlutterLocalNotificationsPlugin();
        for (int i = 0; i < NotificationService._maxSlots; i++) {
          await plugin.cancel(NotificationService.slotId(activityId, i));
        }
      }
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const _maxSlots = 10;
  static const _channelReminders = 'activity_reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static int slotId(int activityId, int slot) => activityId * 100 + slot;

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (_) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await android?.createNotificationChannel(const AndroidNotificationChannel(
        'challenge_reminders',
        'Challenge Reminders',
        description: 'Persistent notifications for pending challenges',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ));

      await android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelReminders,
        'Activity Reminders',
        description: 'Scheduled reminders for your activities',
        importance: Importance.high,
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

  // ── Persistent challenge notification (existing) ──────────────────────────

  Future<void> showChallengeNotification(Activity activity) async {
    final actions = activity.requiresPhoto
        ? const <AndroidNotificationAction>[]
        : const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'mark_done',
              'Mark Done',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ];

    final androidDetails = AndroidNotificationDetails(
      'challenge_reminders',
      'Challenge Reminders',
      channelDescription: 'Persistent notifications for pending challenges',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      actions: actions,
    );

    await _plugin.show(
      activity.id,
      'Challenge Pending: ${activity.name}',
      "Don't forget to complete your challenge for today!",
      NotificationDetails(android: androidDetails),
      payload: activity.id.toString(),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // ── Scheduled activity reminders ──────────────────────────────────────────

  NotificationDetails _scheduledDetails(
      int activityId, String name, bool requiresPhoto) {
    final actions = requiresPhoto
        ? const <AndroidNotificationAction>[]
        : const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'mark_done',
              'Mark Done',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ];

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelReminders,
        'Activity Reminders',
        channelDescription: 'Scheduled reminders for your activities',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon:
            const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        actions: actions,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleActivitySlots(
    int activityId,
    String name,
    bool requiresPhoto,
    List<TimeOfDay> slots,
  ) async {
    await cancelActivitySlots(activityId);
    final details = _scheduledDetails(activityId, name, requiresPhoto);

    for (int i = 0; i < slots.length && i < _maxSlots; i++) {
      final t = slots[i];
      final scheduled = _nextOccurrence(t.hour, t.minute);
      await _zonedSchedule(slotId(activityId, i), '⚡ $name',
          'Keep your streak alive — tap to check in!', scheduled, details,
          payload: activityId.toString());
    }
  }

  Future<void> cancelActivitySlots(int activityId) async {
    for (int i = 0; i < _maxSlots; i++) {
      await _plugin.cancel(slotId(activityId, i));
    }
  }

  /// Checks if today is completed; if so, cancels remaining notifications
  /// for today and reschedules all slots starting tomorrow.
  Future<void> onActivityCompletedToday(
    int activityId,
    String name,
    bool requiresPhoto,
    int dailyTarget,
  ) async {
    final slots = await ActivityNotificationStore.loadSlots(activityId);
    if (slots.isEmpty) return;

    final repo = CompletionRepository();
    final done = await repo.isCompleted(
        activityId, PaceDateUtils.todayKey(), target: dailyTarget);
    if (!done) return;

    await cancelActivitySlots(activityId);

    final details = _scheduledDetails(activityId, name, requiresPhoto);
    for (int i = 0; i < slots.length && i < _maxSlots; i++) {
      final t = slots[i];
      final tomorrow = _tomorrowAt(t.hour, t.minute);
      await _zonedSchedule(slotId(activityId, i), '⚡ $name',
          'Keep your streak alive — tap to check in!', tomorrow, details,
          payload: activityId.toString());
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime when,
    NotificationDetails details, {
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      // Fallback to inexact if SCHEDULE_EXACT_ALARM permission denied.
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    return tz.TZDateTime.from(target.toUtc(), tz.UTC);
  }

  tz.TZDateTime _tomorrowAt(int hour, int minute) {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1, hour, minute);
    return tz.TZDateTime.from(tomorrow.toUtc(), tz.UTC);
  }
}
