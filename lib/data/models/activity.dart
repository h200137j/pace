import 'package:isar/isar.dart';

part 'activity.g.dart';

/// The type of tracking an activity uses.
enum ActivityType {
  challenge, // Long-running challenge (e.g. 30-day coding)
  task,      // Recurring daily task (e.g. drink water)
  focus,     // Timed deep-work session tracking
}

/// Difficulty impacts XP awarded for each completion.
enum ActivityDifficulty {
  easy,
  medium,
  hard,
  elite,
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

  @Enumerated(EnumType.name)
  ActivityDifficulty difficulty = ActivityDifficulty.medium;

  /// Challenge window start (date-only). Defaults to created day when missing.
  DateTime? startDate;

  /// Challenge window end (date-only). For challenge type, set on creation and immutable.
  DateTime? endDate;

  /// True when user selected the end date manually; false when defaulted to year end.
  bool endDateUserSelected = false;

  /// Cached inclusive duration in days for challenge windows.
  int plannedDurationDays = 0;

  late DateTime createdAt;

  DateTime? archivedAt;

  /// Whether the activity is archived (hidden from home dashboard).
  bool get isArchived => archivedAt != null;

  /// Returns whether challenge end date can be edited.
  bool get canSetChallengeEndDate => type == ActivityType.challenge && endDate == null;

  /// True if [weekday] (1=Mon … 7=Sun) is in the target mask.
  bool isTargetDay(int weekday) => (targetDaysMask >> (weekday - 1)) & 1 == 1;
}
