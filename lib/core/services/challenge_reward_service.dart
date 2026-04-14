import '../constants/xp_config.dart';
import 'challenge_easter_egg_service.dart';
import '../utils/date_utils.dart';
import '../../data/models/activity.dart';

class ChallengeRewardDefinition {
  const ChallengeRewardDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String key;
  final String title;
  final String description;
  final ChallengeRewardMetric metric;
  final int target;
}

enum ChallengeRewardMetric {
  completions,
  photoCompletions,
  xp,
  currentStreak,
  longestStreak,
  badgeCount,
  durationDays,
  completionRate,
}

class ChallengeRewardProfile {
  const ChallengeRewardProfile({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.targetDayCount,
    required this.lengthMultiplier,
    required this.projectedChallengeXp,
    required this.completionRatePercent,
    required this.badges,
    required this.trophies,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final int targetDayCount;
  final double lengthMultiplier;
  final int projectedChallengeXp;
  final int completionRatePercent;
  final List<ChallengeRewardDefinition> badges;
  final List<ChallengeRewardDefinition> trophies;
}

class ChallengeRewardProgress {
  const ChallengeRewardProgress({
    required this.profile,
    required this.challengeXp,
    required this.badgesUnlocked,
    required this.trophiesUnlocked,
    required this.easterEggsUnlocked,
    required this.easterEggsTarget,
    required this.unlockedBadgeTitles,
    required this.unlockedTrophyTitles,
    required this.unlockedEasterEggTitles,
    required this.easterEggMetaTrophyUnlocked,
  });

  final ChallengeRewardProfile profile;
  final int challengeXp;
  final int badgesUnlocked;
  final int trophiesUnlocked;
  final int easterEggsUnlocked;
  final int easterEggsTarget;
  final List<String> unlockedBadgeTitles;
  final List<String> unlockedTrophyTitles;
  final List<String> unlockedEasterEggTitles;
  final bool easterEggMetaTrophyUnlocked;
}

class ChallengeRewardService {
  const ChallengeRewardService._();

  static ChallengeRewardProfile buildProfile({
    required Activity activity,
    required int completionCount,
    required int photoCompletionCount,
    required int currentStreak,
    required int longestStreak,
    required int challengeXp,
  }) {
    final startDate = PaceDateUtils.toDateOnly(
      activity.startDate ?? activity.createdAt,
    );
    final endDate = PaceDateUtils.toDateOnly(
      activity.endDate ?? DateTime.utc(startDate.year, 12, 31),
    );

    final durationDays = _inclusiveDays(startDate, endDate);
    final targetDayCount = _targetDaysWithinWindow(
      activity.targetDaysMask,
      startDate,
      endDate,
    );
    final lengthMultiplier = challengeLengthMultiplier(durationDays);
    final projectedChallengeXp =
        (targetDayCount * XpConfig.completionBaseXp * lengthMultiplier).round();
    final completionRatePercent = targetDayCount == 0
        ? 0
        : ((completionCount / targetDayCount) * 100).round();

    final badges = _buildBadges(
      durationDays: durationDays,
      targetDayCount: targetDayCount,
      projectedChallengeXp: projectedChallengeXp,
    );
    final trophies = _buildTrophies(
      durationDays: durationDays,
      projectedChallengeXp: projectedChallengeXp,
    );

    return ChallengeRewardProfile(
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      targetDayCount: targetDayCount,
      lengthMultiplier: lengthMultiplier,
      projectedChallengeXp: projectedChallengeXp,
      completionRatePercent: completionRatePercent,
      badges: badges,
      trophies: trophies,
    );
  }

  static double challengeLengthMultiplier(int durationDays) {
    final normalized = ((durationDays - 7) / (365 - 7)).clamp(0.0, 1.0);
    return 1.0 + (0.5 * normalized);
  }

  static ChallengeRewardProgress evaluate({
    required Activity activity,
    required int completionCount,
    required int photoCompletionCount,
    required int currentStreak,
    required int longestStreak,
    required int challengeXp,
    Set<String> completionDateKeys = const {},
  }) {
    final profile = buildProfile(
      activity: activity,
      completionCount: completionCount,
      photoCompletionCount: photoCompletionCount,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      challengeXp: challengeXp,
    );

    final unlockedBadgeTitles = <String>[];
    for (final badge in profile.badges) {
      if (_metricValue(
            badge.metric,
            profile: profile,
            completionCount: completionCount,
            photoCompletionCount: photoCompletionCount,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            challengeXp: challengeXp,
            badgeCount: unlockedBadgeTitles.length,
          ) >=
          badge.target) {
        unlockedBadgeTitles.add(badge.title);
      }
    }

    final badgeCount = unlockedBadgeTitles.length;
    final unlockedTrophyTitles = <String>[];
    for (final trophy in profile.trophies) {
      if (_metricValue(
            trophy.metric,
            profile: profile,
            completionCount: completionCount,
            photoCompletionCount: photoCompletionCount,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            challengeXp: challengeXp,
            badgeCount: badgeCount,
          ) >=
          trophy.target) {
        unlockedTrophyTitles.add(trophy.title);
      }
    }

    final easterEggProgress = EliteChallengeEasterEggService.evaluate(
      activity: activity,
      completionDateKeys: completionDateKeys,
    );

    if (easterEggProgress.metaTrophyUnlocked) {
      unlockedTrophyTitles.add(EliteChallengeEasterEggService.metaTrophyTitle);
    }

    return ChallengeRewardProgress(
      profile: profile,
      challengeXp: challengeXp,
      badgesUnlocked: badgeCount,
      trophiesUnlocked: unlockedTrophyTitles.length,
      easterEggsUnlocked: easterEggProgress.unlockedCount,
      easterEggsTarget: easterEggProgress.targetCount,
      unlockedBadgeTitles: unlockedBadgeTitles,
      unlockedTrophyTitles: unlockedTrophyTitles,
      unlockedEasterEggTitles: easterEggProgress.unlockedTitles,
      easterEggMetaTrophyUnlocked: easterEggProgress.metaTrophyUnlocked,
    );
  }

  static int _inclusiveDays(DateTime start, DateTime end) {
    final normalizedStart = PaceDateUtils.toDateOnly(start);
    final normalizedEnd = PaceDateUtils.toDateOnly(end);
    final days = normalizedEnd.difference(normalizedStart).inDays + 1;
    return days < 1 ? 1 : days;
  }

  static int _targetDaysWithinWindow(
    int targetDaysMask,
    DateTime start,
    DateTime end,
  ) {
    var count = 0;
    for (final day in PaceDateUtils.dateRange(start, end)) {
      if (((targetDaysMask >> (day.weekday - 1)) & 1) == 1) {
        count += 1;
      }
    }
    return count < 1 ? 1 : count;
  }

  static List<ChallengeRewardDefinition> _buildBadges({
    required int durationDays,
    required int targetDayCount,
    required int projectedChallengeXp,
  }) {
    final completionPcts = [5, 15, 30, 50, 75];
    final streakPcts = [5, 10, 20, 30, 45];
    final xpPcts = [10, 25, 40, 60, 85];
    final pacePcts = [60, 70, 80, 90, 100];
    final finishPcts = [40, 60, 80, 95, 100];

    return [
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'duration_completion_${i + 1}',
          title: _badgeTitle('Completion', i + 1),
          description: '${completionPcts[i]}% of target days',
          metric: ChallengeRewardMetric.completions,
          target: _percentTarget(targetDayCount, completionPcts[i]),
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'duration_streak_${i + 1}',
          title: _badgeTitle('Streak', i + 1),
          description: '${streakPcts[i]}% of challenge duration streak',
          metric: ChallengeRewardMetric.longestStreak,
          target: _percentTarget(durationDays, streakPcts[i]),
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'duration_xp_${i + 1}',
          title: _badgeTitle('XP', i + 1),
          description: '${xpPcts[i]}% of projected challenge XP',
          metric: ChallengeRewardMetric.xp,
          target: _percentTarget(projectedChallengeXp, xpPcts[i]),
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'duration_pace_${i + 1}',
          title: _badgeTitle('Pace', i + 1),
          description: '${pacePcts[i]}% completion rate',
          metric: ChallengeRewardMetric.completionRate,
          target: pacePcts[i],
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'duration_finish_${i + 1}',
          title: _badgeTitle('Finish', i + 1),
          description: '${finishPcts[i]}% completion quality',
          metric: ChallengeRewardMetric.completionRate,
          target: finishPcts[i],
        ),
    ];
  }

  static List<ChallengeRewardDefinition> _buildTrophies({
    required int durationDays,
    required int projectedChallengeXp,
  }) {
    final badgeCountTargets = [5, 10, 15, 20, 25];
    final durationPcts = [10, 25, 45, 70, 100];
    final xpPcts = [20, 40, 60, 80, 100];
    final pacePcts = [70, 80, 90, 95, 100];
    final streakPcts = [10, 20, 35, 50, 75];

    return [
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'trophy_badges_${i + 1}',
          title: _trophyTitle('Badge Crown', i + 1),
          description: '${badgeCountTargets[i]} challenge badges',
          metric: ChallengeRewardMetric.badgeCount,
          target: badgeCountTargets[i],
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'trophy_duration_${i + 1}',
          title: _trophyTitle('Endurance Crown', i + 1),
          description: '${durationPcts[i]}% of challenge duration',
          metric: ChallengeRewardMetric.durationDays,
          target: _percentTarget(durationDays, durationPcts[i]),
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'trophy_xp_${i + 1}',
          title: _trophyTitle('XP Crown', i + 1),
          description: '${xpPcts[i]}% of projected XP',
          metric: ChallengeRewardMetric.xp,
          target: _percentTarget(projectedChallengeXp, xpPcts[i]),
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'trophy_pace_${i + 1}',
          title: _trophyTitle('Reliability Crown', i + 1),
          description: '${pacePcts[i]}% completion rate',
          metric: ChallengeRewardMetric.completionRate,
          target: pacePcts[i],
        ),
      for (var i = 0; i < 5; i++)
        ChallengeRewardDefinition(
          key: 'trophy_streak_${i + 1}',
          title: _trophyTitle('Streak Crown', i + 1),
          description: '${streakPcts[i]}% of challenge duration streak',
          metric: ChallengeRewardMetric.longestStreak,
          target: _percentTarget(durationDays, streakPcts[i]),
        ),
    ];
  }

  static int _percentTarget(int base, int percent) {
    final target = ((base * percent) / 100).round();
    return target < 1 ? 1 : target;
  }

  static int _metricValue(
    ChallengeRewardMetric metric, {
    required ChallengeRewardProfile profile,
    required int completionCount,
    required int photoCompletionCount,
    required int currentStreak,
    required int longestStreak,
    required int challengeXp,
    required int badgeCount,
  }) {
    switch (metric) {
      case ChallengeRewardMetric.completions:
        return completionCount;
      case ChallengeRewardMetric.photoCompletions:
        return photoCompletionCount;
      case ChallengeRewardMetric.xp:
        return challengeXp;
      case ChallengeRewardMetric.currentStreak:
        return currentStreak;
      case ChallengeRewardMetric.longestStreak:
        return longestStreak;
      case ChallengeRewardMetric.badgeCount:
        return badgeCount;
      case ChallengeRewardMetric.durationDays:
        return profile.durationDays;
      case ChallengeRewardMetric.completionRate:
        return profile.completionRatePercent;
    }
  }

  static String _badgeTitle(String family, int index) {
    const suffixes = ['I', 'II', 'III', 'IV', 'V'];
    return '$family ${suffixes[index - 1]}';
  }

  static String _trophyTitle(String family, int index) {
    const suffixes = ['I', 'II', 'III', 'IV', 'V'];
    return '$family ${suffixes[index - 1]}';
  }
}
