import 'package:isar/isar.dart';

import '../../core/utils/date_utils.dart';
import '../models/completion.dart';
import '../services/isar_service.dart';

class CompletionRepository {
  Isar get _db => IsarService.instance.db;

  IsarCollection<Completion> get _col => _db.completions;

  // ── Reads ──────────────────────────────────────────────────────────────────

  /// Live stream of all completions for [activityId].
  Stream<List<Completion>> watchForActivity(int activityId) => _col
      .where()
      .filter()
      .activityIdEqualTo(activityId)
      .watch(fireImmediately: true);

  /// One-time fetch of all dateKeys for [activityId] (for analytics).
  Future<Set<String>> getDateKeysForActivity(int activityId) async {
    final completions = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .findAll();
    return {for (final c in completions) c.dateKey};
  }

  /// Whether [activityId] is fully completed on [dateKey] (checkInCount >= target).
  Future<bool> isCompleted(int activityId, String dateKey, {int target = 1}) async {
    final c = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    return c != null && c.checkInCount >= target;
  }

  /// Today's check-in count for [activityId] (0 if no record exists).
  Future<int> getCheckInCount(int activityId, String dateKey) async {
    final c = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    return c?.checkInCount ?? 0;
  }

  /// All completions for any activity on [dateKey].
  Future<List<Completion>> getForDate(String dateKey) =>
      _col.where().filter().dateKeyEqualTo(dateKey).findAll();

  /// All completions across all activities (for analytics / export).
  Future<List<Completion>> getAll() => _col.where().findAll();

  // ── Writes ─────────────────────────────────────────────────────────────────

  /// Increments check-in count for [activityId] on [dateKey] toward [target].
  /// Cycle: 0→1→…→target→0 (record deleted when count reaches target and tapped again).
  /// Returns the new checkInCount (0 = undo/deleted), isFullyComplete, and any removed photoPath.
  Future<({int checkInCount, bool isFullyComplete, String? removedPhotoPath})> checkIn(
    int activityId,
    String dateKey,
    int target, {
    String? photoPath,
  }) async {
    final existing = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();

    if (existing == null) {
      final c = Completion()
        ..activityId = activityId
        ..dateKey = dateKey
        ..checkInCount = 1
        ..photoPath = photoPath
        ..completedAt = DateTime.now();
      await _db.writeTxn(() => _col.put(c));
      return (checkInCount: 1, isFullyComplete: target <= 1, removedPhotoPath: null);
    }

    if (existing.checkInCount >= target) {
      final oldPath = existing.photoPath;
      await _db.writeTxn(() => _col.delete(existing.id));
      return (checkInCount: 0, isFullyComplete: false, removedPhotoPath: oldPath);
    }

    existing.checkInCount += 1;
    if (photoPath != null) existing.photoPath = photoPath;
    existing.completedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(existing));
    return (
      checkInCount: existing.checkInCount,
      isFullyComplete: existing.checkInCount >= target,
      removedPhotoPath: null,
    );
  }

  /// Toggles full completion for [activityId] on [dateKey] (calendar editing).
  /// Add: sets checkInCount = target in one tap. Remove: deletes the record.
  Future<({bool isNowComplete, String? removedPhotoPath})> toggleFull(
    int activityId,
    String dateKey,
    int target, {
    String? photoPath,
  }) async {
    final existing = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    if (existing != null) {
      final oldPath = existing.photoPath;
      await _db.writeTxn(() => _col.delete(existing.id));
      return (isNowComplete: false, removedPhotoPath: oldPath);
    }
    final c = Completion()
      ..activityId = activityId
      ..dateKey = dateKey
      ..checkInCount = target
      ..photoPath = photoPath
      ..completedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(c));
    return (isNowComplete: true, removedPhotoPath: null);
  }

  /// Marks [activityId] as fully done today. No-op if already fully complete.
  Future<void> markToday(int activityId, {String? photoPath, int target = 1}) async {
    final key = PaceDateUtils.todayKey();
    final exists = await isCompleted(activityId, key, target: target);
    if (exists) return;
    final c = Completion()
      ..activityId = activityId
      ..dateKey = key
      ..checkInCount = target
      ..photoPath = photoPath
      ..completedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(c));
  }

  Future<void> updatePhoto(
      int activityId, String dateKey, String? newPhotoPath) async {
    final existing = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    if (existing == null) return;
    existing.photoPath = newPhotoPath;
    await _db.writeTxn(() => _col.put(existing));
  }

  Future<void> updateNote(int activityId, String dateKey, String? note) async {
    final existing = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    if (existing == null) return;
    existing.note = (note == null || note.trim().isEmpty) ? null : note.trim();
    await _db.writeTxn(() => _col.put(existing));
  }

  Future<void> deleteAllForActivity(int activityId) async {
    final ids = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .idProperty()
        .findAll();
    await _db.writeTxn(() => _col.deleteAll(ids));
  }

  Future<void> importBatch(List<Completion> completions) async {
    await _db.writeTxn(() => _col.putAll(completions));
  }
}
