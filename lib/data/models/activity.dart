import 'package:isar/isar.dart';

part 'activity.g.dart';

/// The type of tracking an activity uses.
enum ActivityType {
  challenge, // Long-running challenge (e.g. 30-day coding)
  task,      // Recurring daily task (e.g. drink water)
  focus,     // Timed deep-work session tracking
}

/// Core model for a user-created habit/activity.
@Collection()
class Activity {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  @Enumerated(EnumType.name)
  late ActivityType type;

  /// ARGB color value (stored as int for Isar compatibility).
  late int colorValue;

  /// Material icon code point.
  late int iconCodePoint;

  /// Bitmask for target days: bit 0 = Mon, bit 6 = Sun.
  /// 127 (0111 1111) = every day.
  late int targetDaysMask;

  /// Whether a daily photo is required to complete this activity.
  bool requiresPhoto = false;

  late DateTime createdAt;

  DateTime? archivedAt;

  /// Whether the activity is archived (hidden from home dashboard).
  bool get isArchived => archivedAt != null;

  /// True if [weekday] (1=Mon … 7=Sun) is in the target mask.
  bool isTargetDay(int weekday) => (targetDaysMask >> (weekday - 1)) & 1 == 1;
}
