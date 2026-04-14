import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/gamification_service.dart';
import '../core/utils/date_utils.dart';
import '../data/models/completion.dart';
import '../data/repositories/completion_repository.dart';
import '../core/services/photo_service.dart';
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

/// Whether a specific activity is done today, derived from the stream.
final todayDoneProvider = Provider.family<bool, int>((ref, activityId) {
  final completions =
      ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final today = PaceDateUtils.todayKey();
  return completions.any((c) => c.dateKey == today);
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

// ── Notifier ───────────────────────────────────────────────────────────────

class CompletionNotifier extends StateNotifier<AsyncValue<void>> {
  CompletionNotifier(this._repo, this._gamificationService)
      : super(const AsyncValue.data(null));

  final CompletionRepository _repo;
  final GamificationService _gamificationService;

  Future<XpAwardOutcome?> toggle(
    int activityId,
    String dateKey, {
    String? photoPath,
  }) async {
    try {
      final wasCompleted = await _repo.isCompleted(activityId, dateKey);
      final deletedPhotoPath = await _repo.toggle(activityId, dateKey, photoPath: photoPath);
      if (deletedPhotoPath != null) {
        await PhotoService.instance.deleteImage(deletedPhotoPath);
      }
      if (!wasCompleted) {
        return _gamificationService.awardCompletionXp(
          activityId: activityId,
          dateKey: dateKey,
          hasPhoto: photoPath != null,
        );
      }
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<XpAwardOutcome?> markToday(int activityId, {String? photoPath}) async {
    try {
      final key = PaceDateUtils.todayKey();
      final wasCompleted = await _repo.isCompleted(activityId, key);
      await _repo.markToday(activityId, photoPath: photoPath);
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
