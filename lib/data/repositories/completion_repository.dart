import 'package:isar/isar.dart';

import '../../core/utils/date_utils.dart';
import '../models/completion.dart';
import '../services/isar_service.dart';

class CompletionRepository {
  final _db = IsarService.instance.db;

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

  /// Whether [activityId] is completed on [dateKey].
  Future<bool> isCompleted(int activityId, String dateKey) async {
    final c = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();
    return c != null;
  }

  /// All completions for any activity on [dateKey].
  Future<List<Completion>> getForDate(String dateKey) =>
      _col.where().filter().dateKeyEqualTo(dateKey).findAll();

  /// All completions across all activities (for analytics / export).
  Future<List<Completion>> getAll() => _col.where().findAll();

  // ── Writes ─────────────────────────────────────────────────────────────────

  /// Toggles a completion for [activityId] on [dateKey].
  /// Returns the photoPath if it was removed, or null if it was added.
  Future<String?> toggle(int activityId, String dateKey, {String? photoPath}) async {
    final existing = await _col
        .where()
        .filter()
        .activityIdEqualTo(activityId)
        .dateKeyEqualTo(dateKey)
        .findFirst();

    if (existing != null) {
      final oldPath = existing.photoPath;
      await _db.writeTxn(() => _col.delete(existing.id));
      return oldPath;
    } else {
      final c = Completion()
        ..activityId = activityId
        ..dateKey = dateKey
        ..photoPath = photoPath
        ..completedAt = DateTime.now();
      await _db.writeTxn(() => _col.put(c));
      return null;
    }
  }

  /// Marks [activityId] as done today, no-op if already done.
  Future<void> markToday(int activityId, {String? photoPath}) async {
    final key = PaceDateUtils.todayKey();
    final exists = await isCompleted(activityId, key);
    if (exists) return;
    final c = Completion()
      ..activityId = activityId
      ..dateKey = key
      ..photoPath = photoPath
      ..completedAt = DateTime.now();
    await _db.writeTxn(() => _col.put(c));
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
