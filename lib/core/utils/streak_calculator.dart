import '../utils/date_utils.dart';

class StreakResult {
  final int current;
  final int longest;
  final int totalCompletions;

  const StreakResult({
    required this.current,
    required this.longest,
    required this.totalCompletions,
  });
}

/// Pure streak calculation logic — no Flutter or Isar dependencies.
class StreakCalculator {
  StreakCalculator._();

  /// Given a set of completed dateKeys, calculates current and longest streaks.
  /// A streak counts consecutive calendar days ending at today.
  static StreakResult calculate(Set<String> completedKeys) {
    if (completedKeys.isEmpty) {
      return const StreakResult(current: 0, longest: 0, totalCompletions: 0);
    }

    final today = PaceDateUtils.toDateOnly(DateTime.now());

    // Sort dates ascending
    final sorted = completedKeys.toList()..sort();
    final dates = sorted.map(PaceDateUtils.fromDateKey).toList();

    int longest = 1;
    int run = 1;

    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    // Current streak: count backwards from today
    int current = 0;
    var cursor = today;
    while (true) {
      final key = PaceDateUtils.toDateKey(cursor);
      if (completedKeys.contains(key)) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return StreakResult(
      current: current,
      longest: longest,
      totalCompletions: completedKeys.length,
    );
  }

  /// Completion rate for a date range ([start] to [end] inclusive).
  static double completionRate(
    Set<String> completedKeys,
    DateTime start,
    DateTime end,
  ) {
    final days = PaceDateUtils.dateRange(start, end);
    if (days.isEmpty) return 0;
    final done =
        days.where((d) => completedKeys.contains(PaceDateUtils.toDateKey(d))).length;
    return done / days.length;
  }
}
