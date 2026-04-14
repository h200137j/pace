class TrophyDefinition {
  const TrophyDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String key;
  final String title;
  final String description;
  final TrophyMetric metric;
  final int target;
}

enum TrophyMetric {
  unlockedBadges,
  totalXp,
}

class TrophyCatalog {
  const TrophyCatalog._();

  static const List<TrophyDefinition> all = [
    TrophyDefinition(
      key: 'trailblazer',
      title: 'Trailblazer',
      description: 'Unlock 3 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 3,
    ),
    TrophyDefinition(
      key: 'champion',
      title: 'Champion',
      description: 'Unlock 6 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 6,
    ),
    TrophyDefinition(
      key: 'xp_master',
      title: 'XP Master',
      description: 'Earn 2500 XP.',
      metric: TrophyMetric.totalXp,
      target: 2500,
    ),
    TrophyDefinition(
      key: 'badge_duo',
      title: 'Badge Duo',
      description: 'Unlock 2 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 2,
    ),
    TrophyDefinition(
      key: 'badge_quartet',
      title: 'Badge Quartet',
      description: 'Unlock 4 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 4,
    ),
    TrophyDefinition(
      key: 'badge_8',
      title: 'Octane',
      description: 'Unlock 8 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 8,
    ),
    TrophyDefinition(
      key: 'badge_10',
      title: 'Top Ten',
      description: 'Unlock 10 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 10,
    ),
    TrophyDefinition(
      key: 'badge_12',
      title: 'Collector I',
      description: 'Unlock 12 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 12,
    ),
    TrophyDefinition(
      key: 'badge_14',
      title: 'Collector II',
      description: 'Unlock 14 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 14,
    ),
    TrophyDefinition(
      key: 'badge_16',
      title: 'Collector III',
      description: 'Unlock 16 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 16,
    ),
    TrophyDefinition(
      key: 'badge_18',
      title: 'Collector IV',
      description: 'Unlock 18 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 18,
    ),
    TrophyDefinition(
      key: 'badge_20',
      title: 'Collector V',
      description: 'Unlock 20 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 20,
    ),
    TrophyDefinition(
      key: 'badge_22',
      title: 'Collector VI',
      description: 'Unlock 22 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 22,
    ),
    TrophyDefinition(
      key: 'badge_24',
      title: 'Collector VII',
      description: 'Unlock 24 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 24,
    ),
    TrophyDefinition(
      key: 'badge_25',
      title: 'Master of Pace',
      description: 'Unlock 25 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 25,
    ),
    TrophyDefinition(
      key: 'xp_500',
      title: 'XP Adept',
      description: 'Earn 500 XP.',
      metric: TrophyMetric.totalXp,
      target: 500,
    ),
    TrophyDefinition(
      key: 'xp_1000',
      title: 'XP Vanguard',
      description: 'Earn 1000 XP.',
      metric: TrophyMetric.totalXp,
      target: 1000,
    ),
    TrophyDefinition(
      key: 'xp_1500',
      title: 'XP Forge',
      description: 'Earn 1500 XP.',
      metric: TrophyMetric.totalXp,
      target: 1500,
    ),
    TrophyDefinition(
      key: 'xp_2000',
      title: 'XP Crest',
      description: 'Earn 2000 XP.',
      metric: TrophyMetric.totalXp,
      target: 2000,
    ),
    TrophyDefinition(
      key: 'xp_3000',
      title: 'XP Crown',
      description: 'Earn 3000 XP.',
      metric: TrophyMetric.totalXp,
      target: 3000,
    ),
    TrophyDefinition(
      key: 'xp_4000',
      title: 'XP Throne',
      description: 'Earn 4000 XP.',
      metric: TrophyMetric.totalXp,
      target: 4000,
    ),
    TrophyDefinition(
      key: 'xp_5000',
      title: 'XP Apex',
      description: 'Earn 5000 XP.',
      metric: TrophyMetric.totalXp,
      target: 5000,
    ),
    TrophyDefinition(
      key: 'xp_6500',
      title: 'XP Prime',
      description: 'Earn 6500 XP.',
      metric: TrophyMetric.totalXp,
      target: 6500,
    ),
    TrophyDefinition(
      key: 'xp_8000',
      title: 'XP Omnistar',
      description: 'Earn 8000 XP.',
      metric: TrophyMetric.totalXp,
      target: 8000,
    ),
  ];
}
