import '../../data/models/activity.dart';
import '../utils/date_utils.dart';

class EasterEggMonthUnlock {
  const EasterEggMonthUnlock({
    required this.monthIndex,
    required this.monthStart,
    required this.eggDate,
    required this.title,
    required this.unlocked,
  });

  final int monthIndex;
  final DateTime monthStart;
  final DateTime eggDate;
  final String title;
  final bool unlocked;
}

class EliteEasterEggProgress {
  const EliteEasterEggProgress({
    required this.eligible,
    required this.targetCount,
    required this.unlockedCount,
    required this.unlockedTitles,
    required this.metaTrophyUnlocked,
    required this.months,
  });

  final bool eligible;
  final int targetCount;
  final int unlockedCount;
  final List<String> unlockedTitles;
  final bool metaTrophyUnlocked;
  final List<EasterEggMonthUnlock> months;
}

class EasterEggHint {
  const EasterEggHint({
    required this.monthLabel,
    required this.message,
    required this.eggAlreadyFound,
  });

  final String monthLabel;
  final String message;
  final bool eggAlreadyFound;
}

class EliteChallengeEasterEggService {
  const EliteChallengeEasterEggService._();

  static const int targetEggCount = 12;
  static const String metaTrophyTitle = 'Celestial Vault';

  static const List<String> _monthEggNames = [
    'Frost Sigil',
    'Dawn Ember',
    'Verdant Spark',
    'Rainlight Rune',
    'Bloom Cipher',
    'Suncrest Shard',
    'Highsky Glyph',
    'Harvest Ember',
    'Equinox Seal',
    'Amber Circuit',
    'Nightglass Mark',
    'Aurora Core',
  ];

  static bool isEligible(Activity activity) {
    if (activity.type != ActivityType.challenge) return false;
    if (activity.difficulty != ActivityDifficulty.elite) return false;

    final start = PaceDateUtils.toDateOnly(activity.startDate ?? activity.createdAt);
    final end = PaceDateUtils.toDateOnly(
      activity.endDate ?? DateTime.utc(start.year + 1, start.month, start.day),
    );

    return end.difference(start).inDays + 1 >= 365;
  }

  static EliteEasterEggProgress evaluate({
    required Activity activity,
    required Set<String> completionDateKeys,
  }) {
    if (!isEligible(activity)) {
      return const EliteEasterEggProgress(
        eligible: false,
        targetCount: 0,
        unlockedCount: 0,
        unlockedTitles: [],
        metaTrophyUnlocked: false,
        months: [],
      );
    }

    final start = PaceDateUtils.toDateOnly(activity.startDate ?? activity.createdAt);
    final end = PaceDateUtils.toDateOnly(
      activity.endDate ?? DateTime.utc(start.year + 1, start.month, start.day),
    );

    final months = <EasterEggMonthUnlock>[];
    for (var i = 0; i < targetEggCount; i++) {
      final monthStart = DateTime.utc(start.year, start.month + i, 1);
      final monthEnd = DateTime.utc(monthStart.year, monthStart.month + 1, 0);

      final activeStart = _maxDate(monthStart, start);
      final activeEnd = _minDate(monthEnd, end);
      if (activeStart.isAfter(activeEnd)) {
        continue;
      }

      final day = _randomDayWithinActiveWindow(
        activity: activity,
        monthStart: monthStart,
        minDay: activeStart.day,
        maxDay: activeEnd.day,
      );

      final eggDate = DateTime.utc(monthStart.year, monthStart.month, day);
      final unlocked = completionDateKeys.contains(PaceDateUtils.toDateKey(eggDate));
      final title = '${PaceDateUtils.shortMonth(monthStart.month)} ${_monthEggNames[i]}';

      months.add(
        EasterEggMonthUnlock(
          monthIndex: i,
          monthStart: monthStart,
          eggDate: eggDate,
          title: title,
          unlocked: unlocked,
        ),
      );
    }

    final unlockedTitles = months
        .where((m) => m.unlocked)
        .map((m) => m.title)
        .toList(growable: false);

    return EliteEasterEggProgress(
      eligible: true,
      targetCount: targetEggCount,
      unlockedCount: unlockedTitles.length,
      unlockedTitles: unlockedTitles,
      metaTrophyUnlocked: unlockedTitles.length >= targetEggCount,
      months: months,
    );
  }

  static String? unlockedEggTitleForDate({
    required Activity activity,
    required String dateKey,
  }) {
    if (!isEligible(activity)) return null;

    final date = PaceDateUtils.toDateOnly(PaceDateUtils.fromDateKey(dateKey));
    final start = PaceDateUtils.toDateOnly(activity.startDate ?? activity.createdAt);
    final end = PaceDateUtils.toDateOnly(
      activity.endDate ?? DateTime.utc(start.year + 1, start.month, start.day),
    );

    if (date.isBefore(start) || date.isAfter(end)) return null;

    final monthDelta = (date.year - start.year) * 12 + (date.month - start.month);
    if (monthDelta < 0 || monthDelta >= targetEggCount) return null;

    final monthStart = DateTime.utc(date.year, date.month, 1);
    final monthEnd = DateTime.utc(date.year, date.month + 1, 0);
    final activeStart = _maxDate(monthStart, start);
    final activeEnd = _minDate(monthEnd, end);
    if (activeStart.isAfter(activeEnd)) return null;

    final day = _randomDayWithinActiveWindow(
      activity: activity,
      monthStart: monthStart,
      minDay: activeStart.day,
      maxDay: activeEnd.day,
    );

    if (date.day != day) return null;
    return '${PaceDateUtils.shortMonth(monthStart.month)} ${_monthEggNames[monthDelta]}';
  }

  static EasterEggHint? monthlyHint({
    required Activity activity,
    required Set<String> completionDateKeys,
    DateTime? now,
  }) {
    if (!isEligible(activity)) return null;

    final progress = evaluate(
      activity: activity,
      completionDateKeys: completionDateKeys,
    );

    final today = PaceDateUtils.toDateOnly(now ?? DateTime.now());
    final start = PaceDateUtils.toDateOnly(activity.startDate ?? activity.createdAt);
    final monthDelta = (today.year - start.year) * 12 + (today.month - start.month);
    if (monthDelta < 0 || monthDelta >= targetEggCount) return null;

    final activeMonth = progress.months.where((m) => m.monthIndex == monthDelta);
    if (activeMonth.isEmpty) return null;
    final month = activeMonth.first;

    if (month.unlocked) {
      return EasterEggHint(
        monthLabel: PaceDateUtils.shortMonth(month.monthStart.month),
        message: 'Egg secured for this month.',
        eggAlreadyFound: true,
      );
    }

    if (today.day < 20) return null;

    final phase = _monthPhase(month.eggDate.day);
    return EasterEggHint(
      monthLabel: PaceDateUtils.shortMonth(month.monthStart.month),
      message: 'Radar ping: this month\'s egg is in the $phase of the month.',
      eggAlreadyFound: false,
    );
  }

  static String _monthPhase(int day) {
    if (day <= 10) return 'early days';
    if (day <= 20) return 'middle days';
    return 'late days';
  }

  static int _randomDayWithinActiveWindow({
    required Activity activity,
    required DateTime monthStart,
    required int minDay,
    required int maxDay,
  }) {
    final range = maxDay - minDay + 1;
    final hash = _stableHash(
      '${activity.id}:${activity.createdAt.toUtc().millisecondsSinceEpoch}:${monthStart.year}:${monthStart.month}',
    );
    return minDay + (hash % range);
  }

  static int _stableHash(String input) {
    var hash = 2166136261;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  static DateTime _maxDate(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
  static DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}