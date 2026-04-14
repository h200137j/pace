class ChallengeBadgeDefinition {
  const ChallengeBadgeDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.target,
    required this.metric,
  });

  final String key;
  final String title;
  final String description;
  final int target;
  final ChallengeMetric metric;
}

class ChallengeTrophyDefinition {
  const ChallengeTrophyDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.target,
    required this.metric,
  });

  final String key;
  final String title;
  final String description;
  final int target;
  final ChallengeMetric metric;
}

enum ChallengeMetric {
  completions,
  photoCompletions,
  xp,
  longestStreak,
  currentStreak,
  badgeCount,
}

class ChallengeAchievements {
  const ChallengeAchievements._();

  static const List<ChallengeBadgeDefinition> badges = [
    ChallengeBadgeDefinition(key: 'c_b1', title: 'Kickoff', description: '1 completion', target: 1, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b2', title: 'Warmup', description: '3 completions', target: 3, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b3', title: 'Starter', description: '5 completions', target: 5, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b4', title: 'Locked In', description: '7 completions', target: 7, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b5', title: 'Reliable', description: '10 completions', target: 10, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b6', title: 'Steady', description: '14 completions', target: 14, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b7', title: 'Builder', description: '21 completions', target: 21, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b8', title: 'Dedicated', description: '30 completions', target: 30, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b9', title: 'Hardwired', description: '45 completions', target: 45, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b10', title: 'Unbroken', description: '60 completions', target: 60, metric: ChallengeMetric.completions),
    ChallengeBadgeDefinition(key: 'c_b11', title: 'Photo Snap', description: '1 photo completion', target: 1, metric: ChallengeMetric.photoCompletions),
    ChallengeBadgeDefinition(key: 'c_b12', title: 'Photo Log', description: '5 photo completions', target: 5, metric: ChallengeMetric.photoCompletions),
    ChallengeBadgeDefinition(key: 'c_b13', title: 'Photo Stack', description: '10 photo completions', target: 10, metric: ChallengeMetric.photoCompletions),
    ChallengeBadgeDefinition(key: 'c_b14', title: 'Photo Journal', description: '20 photo completions', target: 20, metric: ChallengeMetric.photoCompletions),
    ChallengeBadgeDefinition(key: 'c_b15', title: 'Photo Archive', description: '40 photo completions', target: 40, metric: ChallengeMetric.photoCompletions),
    ChallengeBadgeDefinition(key: 'c_b16', title: 'XP Ignition', description: '100 challenge XP', target: 100, metric: ChallengeMetric.xp),
    ChallengeBadgeDefinition(key: 'c_b17', title: 'XP Climb', description: '250 challenge XP', target: 250, metric: ChallengeMetric.xp),
    ChallengeBadgeDefinition(key: 'c_b18', title: 'XP Forge', description: '500 challenge XP', target: 500, metric: ChallengeMetric.xp),
    ChallengeBadgeDefinition(key: 'c_b19', title: 'XP Core', description: '800 challenge XP', target: 800, metric: ChallengeMetric.xp),
    ChallengeBadgeDefinition(key: 'c_b20', title: 'XP Titan', description: '1200 challenge XP', target: 1200, metric: ChallengeMetric.xp),
    ChallengeBadgeDefinition(key: 'c_b21', title: 'Streak Seed', description: '3 longest streak', target: 3, metric: ChallengeMetric.longestStreak),
    ChallengeBadgeDefinition(key: 'c_b22', title: 'Streak Rise', description: '7 longest streak', target: 7, metric: ChallengeMetric.longestStreak),
    ChallengeBadgeDefinition(key: 'c_b23', title: 'Streak Run', description: '14 longest streak', target: 14, metric: ChallengeMetric.longestStreak),
    ChallengeBadgeDefinition(key: 'c_b24', title: 'Streak Crest', description: '21 longest streak', target: 21, metric: ChallengeMetric.longestStreak),
    ChallengeBadgeDefinition(key: 'c_b25', title: 'Streak Legend', description: '30 longest streak', target: 30, metric: ChallengeMetric.longestStreak),
  ];

  static const List<ChallengeTrophyDefinition> trophies = [
    ChallengeTrophyDefinition(key: 'c_t1', title: 'Bronze Crown', description: 'Unlock 3 challenge badges', target: 3, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t2', title: 'Silver Crown', description: 'Unlock 5 challenge badges', target: 5, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t3', title: 'Gold Crown', description: 'Unlock 8 challenge badges', target: 8, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t4', title: 'Platinum Crown', description: 'Unlock 10 challenge badges', target: 10, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t5', title: 'Diamond Crown', description: 'Unlock 12 challenge badges', target: 12, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t6', title: 'Mythic Crown', description: 'Unlock 15 challenge badges', target: 15, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t7', title: 'Orbit Crown', description: 'Unlock 18 challenge badges', target: 18, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t8', title: 'Nova Crown', description: 'Unlock 20 challenge badges', target: 20, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t9', title: 'Apex Crown', description: 'Unlock 22 challenge badges', target: 22, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t10', title: 'Master Crown', description: 'Unlock all 25 challenge badges', target: 25, metric: ChallengeMetric.badgeCount),
    ChallengeTrophyDefinition(key: 'c_t11', title: 'XP Bronze', description: '150 challenge XP', target: 150, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t12', title: 'XP Silver', description: '300 challenge XP', target: 300, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t13', title: 'XP Gold', description: '500 challenge XP', target: 500, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t14', title: 'XP Platinum', description: '800 challenge XP', target: 800, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t15', title: 'XP Diamond', description: '1200 challenge XP', target: 1200, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t16', title: 'XP Mythic', description: '1600 challenge XP', target: 1600, metric: ChallengeMetric.xp),
    ChallengeTrophyDefinition(key: 'c_t17', title: 'Marathon I', description: '25 completions', target: 25, metric: ChallengeMetric.completions),
    ChallengeTrophyDefinition(key: 'c_t18', title: 'Marathon II', description: '50 completions', target: 50, metric: ChallengeMetric.completions),
    ChallengeTrophyDefinition(key: 'c_t19', title: 'Marathon III', description: '75 completions', target: 75, metric: ChallengeMetric.completions),
    ChallengeTrophyDefinition(key: 'c_t20', title: 'Marathon IV', description: '100 completions', target: 100, metric: ChallengeMetric.completions),
    ChallengeTrophyDefinition(key: 'c_t21', title: 'Current Flow', description: 'Current streak 7', target: 7, metric: ChallengeMetric.currentStreak),
    ChallengeTrophyDefinition(key: 'c_t22', title: 'Current Force', description: 'Current streak 14', target: 14, metric: ChallengeMetric.currentStreak),
    ChallengeTrophyDefinition(key: 'c_t23', title: 'Current Surge', description: 'Current streak 21', target: 21, metric: ChallengeMetric.currentStreak),
    ChallengeTrophyDefinition(key: 'c_t24', title: 'Longest Flame', description: 'Longest streak 30', target: 30, metric: ChallengeMetric.longestStreak),
    ChallengeTrophyDefinition(key: 'c_t25', title: 'Hall of Pace', description: 'Longest streak 50', target: 50, metric: ChallengeMetric.longestStreak),
  ];
}

class ChallengeAchievementProgress {
  const ChallengeAchievementProgress({
    required this.challengeXp,
    required this.badgesUnlocked,
    required this.trophiesUnlocked,
    required this.unlockedBadgeTitles,
    required this.unlockedTrophyTitles,
  });

  final int challengeXp;
  final int badgesUnlocked;
  final int trophiesUnlocked;
  final List<String> unlockedBadgeTitles;
  final List<String> unlockedTrophyTitles;
}

ChallengeAchievementProgress evaluateChallengeAchievements({
  required int challengeXp,
  required int completions,
  required int photoCompletions,
  required int currentStreak,
  required int longestStreak,
}) {
  int metricValue(ChallengeMetric metric, {int badgeCount = 0}) {
    switch (metric) {
      case ChallengeMetric.completions:
        return completions;
      case ChallengeMetric.photoCompletions:
        return photoCompletions;
      case ChallengeMetric.xp:
        return challengeXp;
      case ChallengeMetric.longestStreak:
        return longestStreak;
      case ChallengeMetric.currentStreak:
        return currentStreak;
      case ChallengeMetric.badgeCount:
        return badgeCount;
    }
  }

  final unlockedBadgeTitles = <String>[];
  for (final badge in ChallengeAchievements.badges) {
    if (metricValue(badge.metric) >= badge.target) {
      unlockedBadgeTitles.add(badge.title);
    }
  }

  final badgeCount = unlockedBadgeTitles.length;
  final unlockedTrophyTitles = <String>[];
  for (final trophy in ChallengeAchievements.trophies) {
    if (metricValue(trophy.metric, badgeCount: badgeCount) >= trophy.target) {
      unlockedTrophyTitles.add(trophy.title);
    }
  }

  return ChallengeAchievementProgress(
    challengeXp: challengeXp,
    badgesUnlocked: badgeCount,
    trophiesUnlocked: unlockedTrophyTitles.length,
    unlockedBadgeTitles: unlockedBadgeTitles,
    unlockedTrophyTitles: unlockedTrophyTitles,
  );
}
