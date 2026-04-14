import 'package:isar/isar.dart';

import '../../core/utils/date_utils.dart';
import '../models/activity.dart';
import '../services/isar_service.dart';

class ActivityRepository {
  Isar get _db => IsarService.instance.db;

  IsarCollection<Activity> get _col => _db.activitys;

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// Stream of all non-archived activities, ordered by creation date.
  Stream<List<Activity>> watchAll() => _col
      .where()
      .filter()
      .archivedAtIsNull()
      .sortByCreatedAt()
      .watch(fireImmediately: true);

  /// Stream of a single activity by [id].
  Stream<Activity?> watchById(int id) =>
      _col.watchObject(id, fireImmediately: true);

  Future<Activity?> findById(int id) => _col.get(id);

  Future<List<Activity>> getAll() =>
      _col.where().filter().archivedAtIsNull().findAll();

  Future<List<Activity>> getAllIncludingArchived() => _col.where().findAll();

  // ── Writes ─────────────────────────────────────────────────────────────────

  Future<Activity> create({
    required String name,
    required ActivityType type,
    required int colorValue,
    required int iconCodePoint,
    ActivityDifficulty difficulty = ActivityDifficulty.medium,
    int targetDaysMask = 127, // every day
    bool requiresPhoto = false,
    DateTime? challengeEndDate,
    bool endDateUserSelected = false,
  }) async {
    final now = DateTime.now();
    final startDate = PaceDateUtils.toDateOnly(now);
    DateTime? resolvedEndDate;
    if (type == ActivityType.challenge) {
      final minEndDate = startDate.add(const Duration(days: 6));
      final maxEndDate = startDate.add(const Duration(days: 366));
      var candidate = PaceDateUtils.toDateOnly(
        challengeEndDate ?? DateTime.utc(now.year, 12, 31),
      );
      if (candidate.isBefore(minEndDate)) candidate = minEndDate;
      if (candidate.isAfter(maxEndDate)) candidate = maxEndDate;
      resolvedEndDate = candidate;
    }
    final plannedDurationDays = resolvedEndDate == null
        ? 0
        : resolvedEndDate
                .difference(startDate)
                .inDays +
            1;

    final activity = Activity()
      ..name = name
      ..type = type
      ..colorValue = colorValue
      ..iconCodePoint = iconCodePoint
      ..difficulty = difficulty
      ..targetDaysMask = targetDaysMask
      ..requiresPhoto = requiresPhoto
      ..startDate = type == ActivityType.challenge ? startDate : null
      ..endDate = resolvedEndDate
      ..endDateUserSelected = type == ActivityType.challenge && endDateUserSelected
      ..plannedDurationDays = plannedDurationDays
      ..createdAt = now;

    await _db.writeTxn(() => _col.put(activity));
    return activity;
  }

  Future<void> update(Activity activity) async {
    final existing = await _col.get(activity.id);

    if (activity.type == ActivityType.challenge) {
      final now = PaceDateUtils.toDateOnly(DateTime.now());

      // End date is immutable once it is set.
      final existingEndDate = existing?.endDate;
      final resolvedEndDate = existingEndDate ??
          activity.endDate ??
          DateTime.utc(now.year, 12, 31);

      final startDate = PaceDateUtils.toDateOnly(
        activity.startDate ?? existing?.startDate ?? activity.createdAt,
      );
      final minEndDate = startDate.add(const Duration(days: 6));
      var normalizedEndDate = PaceDateUtils.toDateOnly(resolvedEndDate);
      if (normalizedEndDate.isBefore(minEndDate)) {
        normalizedEndDate = minEndDate;
      }
      final normalizedStartDate = normalizedEndDate.isBefore(startDate)
          ? normalizedEndDate
          : startDate;

      activity
        ..startDate = normalizedStartDate
        ..endDate = normalizedEndDate
        ..endDateUserSelected = existingEndDate != null
            ? (existing?.endDateUserSelected ?? false)
            : activity.endDateUserSelected
        ..plannedDurationDays =
            normalizedEndDate.difference(normalizedStartDate).inDays + 1;
    } else {
      activity
        ..startDate = null
        ..endDate = null
        ..endDateUserSelected = false
        ..plannedDurationDays = 0;
    }

    await _db.writeTxn(() => _col.put(activity));
  }

  Future<void> archive(int id) async {
    final activity = await _col.get(id);
    if (activity == null) return;
    activity.archivedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(activity));
  }

  Future<void> delete(int id) =>
      _db.writeTxn(() => _col.delete(id));
}
