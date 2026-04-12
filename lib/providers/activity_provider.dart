import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/activity.dart';
import '../data/repositories/activity_repository.dart';

// ── Repository Provider ────────────────────────────────────────────────────

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(),
);

// ── Stream Provider ────────────────────────────────────────────────────────

final activitiesProvider = StreamProvider<List<Activity>>((ref) {
  return ref.watch(activityRepositoryProvider).watchAll();
});

final activityByIdProvider =
    StreamProvider.family<Activity?, int>((ref, id) {
  return ref.watch(activityRepositoryProvider).watchById(id);
});

// ── Notifier ───────────────────────────────────────────────────────────────

class ActivityNotifier extends StateNotifier<AsyncValue<void>> {
  ActivityNotifier(this._repo) : super(const AsyncValue.data(null));

  final ActivityRepository _repo;

  Future<Activity?> create({
    required String name,
    required ActivityType type,
    required Color color,
    required int iconCodePoint,
    int targetDaysMask = 127,
  }) async {
    state = const AsyncValue.loading();
    try {
      final act = await _repo.create(
        name: name,
        type: type,
        colorValue: color.value,
        iconCodePoint: iconCodePoint,
        targetDaysMask: targetDaysMask,
      );
      state = const AsyncValue.data(null);
      return act;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> update(Activity activity) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(activity);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archive(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.archive(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, AsyncValue<void>>(
  (ref) => ActivityNotifier(ref.watch(activityRepositoryProvider)),
);
