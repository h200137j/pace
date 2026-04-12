import 'package:isar/isar.dart';

import '../models/activity.dart';
import '../services/isar_service.dart';

class ActivityRepository {
  final _db = IsarService.instance.db;

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
    int targetDaysMask = 127, // every day
  }) async {
    final activity = Activity()
      ..name = name
      ..type = type
      ..colorValue = colorValue
      ..iconCodePoint = iconCodePoint
      ..targetDaysMask = targetDaysMask
      ..createdAt = DateTime.now();

    await _db.writeTxn(() => _col.put(activity));
    return activity;
  }

  Future<void> update(Activity activity) =>
      _db.writeTxn(() => _col.put(activity));

  Future<void> archive(int id) async {
    final activity = await _col.get(id);
    if (activity == null) return;
    activity.archivedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(activity));
  }

  Future<void> delete(int id) =>
      _db.writeTxn(() => _col.delete(id));
}
