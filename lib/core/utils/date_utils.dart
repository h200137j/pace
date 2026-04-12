/// Utility functions for date manipulation used throughout Pace.
class PaceDateUtils {
  PaceDateUtils._();

  /// Normalizes [dt] to midnight UTC so date comparisons are consistent.
  static DateTime toDateOnly(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  /// Returns an ISO-8601 date string (`yyyy-MM-dd`) for storage in Isar.
  static String toDateKey(DateTime dt) {
    final d = toDateOnly(dt);
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// Parses a dateKey string back to a [DateTime].
  static DateTime fromDateKey(String key) => DateTime.parse('${key}T00:00:00Z');

  /// Returns today's dateKey.
  static String todayKey() => toDateKey(DateTime.now());

  /// Returns every day between [start] and [end] inclusive.
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = toDateOnly(start);
    final last = toDateOnly(end);
    while (!current.isAfter(last)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  /// Returns the Monday of the week containing [date].
  static DateTime weekStart(DateTime date) {
    final d = toDateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Returns a list of 7 [DateTime]s for the week containing [date].
  static List<DateTime> weekDays(DateTime date) {
    final start = weekStart(date);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// Returns the first day of the month for [date].
  static DateTime monthStart(DateTime date) =>
      DateTime.utc(date.year, date.month, 1);

  /// Returns number of days in the month of [date].
  static int daysInMonth(DateTime date) =>
      DateTime.utc(date.year, date.month + 1, 0).day;

  /// Short weekday label (M T W T F S S).
  static String shortWeekday(int weekday) =>
      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];

  /// Short month label.
  static String shortMonth(int month) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][month - 1];
}
