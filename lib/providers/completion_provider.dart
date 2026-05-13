import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/gamification_service.dart';
import '../core/utils/date_utils.dart';
import '../data/models/completion.dart';
import '../data/repositories/completion_repository.dart';
import '../core/services/photo_service.dart';
import 'activity_provider.dart';
import 'gamification_provider.dart';

// ── Repository Provider ────────────────────────────────────────────────────

final completionRepositoryProvider = Provider<CompletionRepository>(
  (ref) => CompletionRepository(),
);

// ── Stream Providers ───────────────────────────────────────────────────────

/// All completions for a given activity, live.
final completionsForActivityProvider =
    StreamProvider.family<List<Completion>, int>((ref, activityId) {
  return ref.watch(completionRepositoryProvider).watchForActivity(activityId);
});

/// Today's check-in count for an activity (0 if no record).
final todayCheckInCountProvider = Provider.family<int, int>((ref, activityId) {
  final completions =
      ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final today = PaceDateUtils.todayKey();
  final matches = completions.where((c) => c.dateKey == today);
  return matches.isEmpty ? 0 : matches.first.checkInCount;
});

/// Whether [activityId] is fully done today given [target] required check-ins.
/// Param is (activityId, dailyCheckInTarget).
final todayDoneProvider = Provider.family<bool, (int, int)>((ref, args) {
  final (activityId, target) = args;
  return ref.watch(todayCheckInCountProvider(activityId)) >= target;
});

/// Set of all dateKeys for an activity (used in streak calculator).
final dateKeysProvider =
    FutureProvider.family<Set<String>, int>((ref, activityId) {
  return ref
      .watch(completionRepositoryProvider)
      .getDateKeysForActivity(activityId);
});

/// Map of dateKey to Completion for a specific activity.
final completionMapProvider = Provider.family<Map<String, Completion>, int>((ref, activityId) {
  final completions = ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  return {for (final c in completions) c.dateKey: c};
});

/// DateKeys of fully completed days (checkInCount >= activity.dailyCheckInTarget).
final doneCompletionKeysProvider = Provider.family<Set<String>, int>((ref, activityId) {
  final activity = ref.watch(activityByIdProvider(activityId)).valueOrNull;
  final target = activity?.dailyCheckInTarget ?? 1;
  final completions = ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  return completions
      .where((c) => c.checkInCount >= target)
      .map((c) => c.dateKey)
      .toSet();
});

// ── Notifier ───────────────────────────────────────────────────────────────

class CompletionNotifier extends StateNotifier<AsyncValue<void>> {
  CompletionNotifier(this._repo, this._gamificationService)
      : super(const AsyncValue.data(null));

  final CompletionRepository _repo;
  final GamificationService _gamificationService;

  Future<XpAwardOutcome?> checkIn(
    int activityId,
    String dateKey,
    int target, {
    String? photoPath,
  }) async {
    try {
      final result = await _repo.checkIn(activityId, dateKey, target, photoPath: photoPath);
      if (result.removedPhotoPath != null) {
        await PhotoService.instance.deleteImage(result.removedPhotoPath!);
      }
      // No XP on undo (checkInCount == 0).
      if (result.checkInCount == 0) return null;
      return _gamificationService.awardCompletionXp(
        activityId: activityId,
        dateKey: dateKey,
        hasPhoto: photoPath != null,
        checkInNumber: result.checkInCount,
        dailyCheckInTarget: target,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// All-or-nothing toggle for calendar/history editing — completes fully in one tap or removes.
  Future<XpAwardOutcome?> toggleFull(
    int activityId,
    String dateKey,
    int target, {
    String? photoPath,
  }) async {
    try {
      final result = await _repo.toggleFull(activityId, dateKey, target, photoPath: photoPath);
      if (result.removedPhotoPath != null) {
        await PhotoService.instance.deleteImage(result.removedPhotoPath!);
      }
      if (result.isNowComplete) {
        return _gamificationService.awardCompletionXp(
          activityId: activityId,
          dateKey: dateKey,
          hasPhoto: photoPath != null,
          checkInNumber: target,
          dailyCheckInTarget: target,
        );
      }
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<XpAwardOutcome?> markToday(int activityId, {String? photoPath, int target = 1}) async {
    try {
      final key = PaceDateUtils.todayKey();
      final wasCompleted = await _repo.isCompleted(activityId, key, target: target);
      await _repo.markToday(activityId, photoPath: photoPath, target: target);
      if (!wasCompleted) {
        return _gamificationService.awardCompletionXp(
          activityId: activityId,
          dateKey: key,
          hasPhoto: photoPath != null,
        );
      }
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final completionNotifierProvider =
    StateNotifierProvider<CompletionNotifier, AsyncValue<void>>(
  (ref) => CompletionNotifier(
    ref.watch(completionRepositoryProvider),
    ref.watch(gamificationServiceProvider),
  ),
);
