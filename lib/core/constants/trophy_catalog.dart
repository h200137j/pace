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

// Trophy targets are designed for 5–10+ year use.
// Badge-count trophies scale to BadgeCatalog.all.length (30 badges).
// XP trophies mirror the badge XP milestones at a higher resolution.

class TrophyCatalog {
  const TrophyCatalog._();

  static const List<TrophyDefinition> all = [

    // ── Badge-count trophies ──────────────────────────────────────────────

    TrophyDefinition(
      key: 'trailblazer',
      title: 'Trailblazer',
      description: 'Unlock 3 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 3,
    ),
    TrophyDefinition(
      key: 'collector',
      title: 'Collector',
      description: 'Unlock 6 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 6,
    ),
    TrophyDefinition(
      key: 'champion',
      title: 'Champion',
      description: 'Unlock 10 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 10,
    ),
    TrophyDefinition(
      key: 'decorated',
      title: 'Decorated',
      description: 'Unlock 15 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 15,
    ),
    TrophyDefinition(
      key: 'elite_collector',
      title: 'Elite Collector',
      description: 'Unlock 20 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 20,
    ),
    TrophyDefinition(
      key: 'master_of_pace',
      title: 'Master of Pace',
      description: 'Unlock 25 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 25,
    ),
    TrophyDefinition(
      key: 'grand_collector',
      title: 'Grand Collector',
      description: 'Unlock all 30 badges.',
      metric: TrophyMetric.unlockedBadges,
      target: 30,
    ),

    // ── XP trophies ───────────────────────────────────────────────────────

    TrophyDefinition(
      key: 'xp_adept',
      title: 'XP Adept',
      description: 'Earn 1,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 1000,
    ),
    TrophyDefinition(
      key: 'xp_vanguard',
      title: 'XP Vanguard',
      description: 'Earn 5,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 5000,
    ),
    TrophyDefinition(
      key: 'xp_forge',
      title: 'XP Forge',
      description: 'Earn 15,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 15000,
    ),
    TrophyDefinition(
      key: 'xp_crest',
      title: 'XP Crest',
      description: 'Earn 35,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 35000,
    ),
    TrophyDefinition(
      key: 'xp_crown',
      title: 'XP Crown',
      description: 'Earn 75,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 75000,
    ),
    TrophyDefinition(
      key: 'xp_throne',
      title: 'XP Throne',
      description: 'Earn 150,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 150000,
    ),
    TrophyDefinition(
      key: 'xp_ascendant',
      title: 'XP Ascendant',
      description: 'Earn 300,000 XP.',
      metric: TrophyMetric.totalXp,
      target: 300000,
    ),
    TrophyDefinition(
      key: 'xp_eternal',
      title: 'XP Eternal',
      description: 'Earn 600,000 XP. Discipline without end.',
      metric: TrophyMetric.totalXp,
      target: 600000,
    ),
    TrophyDefinition(
      key: 'xp_transcendent',
      title: 'XP Transcendent',
      description: 'Earn 1,000,000 XP. A lifetime of mastery.',
      metric: TrophyMetric.totalXp,
      target: 1000000,
    ),
  ];
}
