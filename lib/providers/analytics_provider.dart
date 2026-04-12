import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';
import '../core/utils/streak_calculator.dart';
import 'completion_provider.dart';

// ── Streak Provider ────────────────────────────────────────────────────────

final streakProvider = Provider.family<StreakResult, int>((ref, activityId) {
  final completions =
      ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final keys = completions.map((c) => c.dateKey).toSet();
  return StreakCalculator.calculate(keys);
});

// ── Analytics Providers ────────────────────────────────────────────────────

/// Returns a map of dateKey → bool for the last [days] days.
final recentDailyProvider =
    Provider.family<Map<String, bool>, ({int activityId, int days})>(
  (ref, args) {
    final completions =
        ref.watch(completionsForActivityProvider(args.activityId)).valueOrNull ??
            [];
    final keys = completions.map((c) => c.dateKey).toSet();

    final end = PaceDateUtils.toDateOnly(DateTime.now());
    final start = end.subtract(Duration(days: args.days - 1));
    final range = PaceDateUtils.dateRange(start, end);

    return {
      for (final d in range)
        PaceDateUtils.toDateKey(d): keys.contains(PaceDateUtils.toDateKey(d))
    };
  },
);

/// Returns weekly completion rates (7 values) for the bar chart.
final weeklyRatesProvider = Provider.family<List<double>, int>((ref, activityId) {
  final completions =
      ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final keys = completions.map((c) => c.dateKey).toSet();

  final today = PaceDateUtils.toDateOnly(DateTime.now());
  final weekStart = PaceDateUtils.weekStart(today);

  return List.generate(7, (i) {
    final d = weekStart.add(Duration(days: i));
    return keys.contains(PaceDateUtils.toDateKey(d)) ? 1.0 : 0.0;
  });
});

/// Returns a 52-week heatmap grid: list of 364 cells, each 0.0–1.0.
final yearHeatmapProvider = Provider.family<List<double>, int>((ref, activityId) {
  final completions =
      ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final keys = completions.map((c) => c.dateKey).toSet();

  final today = PaceDateUtils.toDateOnly(DateTime.now());
  final end = today;
  final start = end.subtract(const Duration(days: 363));
  final range = PaceDateUtils.dateRange(start, end);

  return range.map((d) {
    final key = PaceDateUtils.toDateKey(d);
    return keys.contains(key) ? 1.0 : 0.0;
  }).toList();
});

/// Monthly completions for calendar dot view.
final monthlyCompletionsProvider =
    Provider.family<Set<String>, ({int activityId, DateTime month})>(
  (ref, args) {
    final completions =
        ref.watch(completionsForActivityProvider(args.activityId)).valueOrNull ??
            [];
    final keys = completions.map((c) => c.dateKey).toSet();

    final start = PaceDateUtils.monthStart(args.month);
    final days = PaceDateUtils.daysInMonth(args.month);
    final monthKeys = List.generate(
      days,
      (i) => PaceDateUtils.toDateKey(start.add(Duration(days: i))),
    );
    return {for (final k in monthKeys) if (keys.contains(k)) k};
  },
);
