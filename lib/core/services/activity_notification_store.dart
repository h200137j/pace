import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityNotificationStore {
  static const _prefix = 'notif_slots_';

  static Future<List<TimeOfDay>> loadSlots(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix$activityId') ?? [];
    return raw.map((s) {
      final parts = s.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();
  }

  static Future<void> saveSlots(int activityId, List<TimeOfDay> slots) async {
    final prefs = await SharedPreferences.getInstance();
    final data = slots.map((t) => '${t.hour}:${t.minute}').toList();
    await prefs.setStringList('$_prefix$activityId', data);
  }

  static Future<void> clearSlots(int activityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$activityId');
  }
}
