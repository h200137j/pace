class BadgeDefinition {
  const BadgeDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.tier,
  });

  final String key;
  final String title;
  final String description;
  final BadgeMetric metric;
  final int target;
  final String tier;
}

enum BadgeMetric {
  lifetimeCompletions,
  lifetimePhotoCompletions,
  totalXp,
}

// XP scale reference (completionBaseXp=10):
//   easy   1.0×  →  10 XP/completion
//   medium 1.5×  →  15 XP/completion
//   hard   2.0×  →  20 XP/completion
//   elite  3.0×  →  30 XP/completion  (+challenge length bonus up to ×1.5)
//
// Typical daily use (2 medium activities): ~30 XP/day → ~11k/year
// Power user (elite challenges + photos): ~100 XP/day → ~36k/year
// Lifetime (10 years, typical): ~110k XP
// Lifetime (10 years, elite):   ~365k XP

class BadgeCatalog {
  const BadgeCatalog._();

  static const List<BadgeDefinition> all = [

    // ── Completion milestones ─────────────────────────────────────────────

    BadgeDefinition(
      key: 'first_step',
      title: 'First Step',
      description: 'Complete your first activity.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 1,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'momentum',
      title: 'Momentum',
      description: 'Reach 3 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 3,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'week_warrior',
      title: 'Week Warrior',
      description: 'Reach 7 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 7,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'builder',
      title: 'Builder',
      description: 'Reach 30 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 30,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'committed',
      title: 'Committed',
      description: 'Reach 100 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 100,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'relentless',
      title: 'Relentless',
      description: 'Reach 250 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 250,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'five_hundred',
      title: 'Five Hundred',
      description: 'Reach 500 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 500,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'thousand_rep',
      title: 'Thousand Rep',
      description: 'Reach 1,000 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 1000,
      tier: 'gold',
    ),
    BadgeDefinition(
      key: 'two_thousand',
      title: 'Two Thousand',
      description: 'Reach 2,000 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 2000,
      tier: 'gold',
    ),
    BadgeDefinition(
      key: 'five_thousand',
      title: 'Five Thousand',
      description: 'Reach 5,000 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 5000,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'ten_thousand',
      title: 'Ten Thousand',
      description: 'Reach 10,000 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 10000,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'twenty_thousand',
      title: 'Twenty Thousand',
      description: 'Reach 20,000 total completions.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 20000,
      tier: 'legendary',
    ),
    BadgeDefinition(
      key: 'fifty_thousand',
      title: 'Fifty Thousand',
      description: 'Reach 50,000 total completions. A true lifetime.',
      metric: BadgeMetric.lifetimeCompletions,
      target: 50000,
      tier: 'legendary',
    ),

    // ── Photo milestones ──────────────────────────────────────────────────

    BadgeDefinition(
      key: 'snapshot',
      title: 'Snapshot',
      description: 'Log your first photo completion.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 1,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'visual_starter',
      title: 'Visual Starter',
      description: 'Log 10 photo completions.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 10,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'photo_journal',
      title: 'Photo Journal',
      description: 'Log 30 photo completions.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 30,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'storyteller',
      title: 'Storyteller',
      description: 'Log 100 photo completions.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 100,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'archivist',
      title: 'Archivist',
      description: 'Log 365 photo completions — a year in pictures.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 365,
      tier: 'gold',
    ),
    BadgeDefinition(
      key: 'documentarian',
      title: 'Documentarian',
      description: 'Log 1,000 photo completions.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 1000,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'cinematic',
      title: 'Cinematic',
      description: 'Log 2,500 photo completions.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 2500,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'living_archive',
      title: 'Living Archive',
      description: 'Log 5,000 photo completions. A life documented.',
      metric: BadgeMetric.lifetimePhotoCompletions,
      target: 5000,
      tier: 'legendary',
    ),

    // ── XP milestones ─────────────────────────────────────────────────────

    BadgeDefinition(
      key: 'xp_spark',
      title: 'XP Spark',
      description: 'Earn 500 XP.',
      metric: BadgeMetric.totalXp,
      target: 500,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'xp_ignite',
      title: 'XP Ignite',
      description: 'Earn 2,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 2000,
      tier: 'bronze',
    ),
    BadgeDefinition(
      key: 'xp_builder',
      title: 'XP Builder',
      description: 'Earn 5,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 5000,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'xp_veteran',
      title: 'XP Veteran',
      description: 'Earn 15,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 15000,
      tier: 'silver',
    ),
    BadgeDefinition(
      key: 'xp_engine',
      title: 'XP Engine',
      description: 'Earn 35,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 35000,
      tier: 'gold',
    ),
    BadgeDefinition(
      key: 'xp_powerhouse',
      title: 'XP Powerhouse',
      description: 'Earn 75,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 75000,
      tier: 'gold',
    ),
    BadgeDefinition(
      key: 'xp_force',
      title: 'XP Force',
      description: 'Earn 150,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 150000,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'xp_titan',
      title: 'XP Titan',
      description: 'Earn 300,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 300000,
      tier: 'platinum',
    ),
    BadgeDefinition(
      key: 'xp_apex',
      title: 'XP Apex',
      description: 'Earn 600,000 XP.',
      metric: BadgeMetric.totalXp,
      target: 600000,
      tier: 'legendary',
    ),
    BadgeDefinition(
      key: 'xp_eternal',
      title: 'XP Eternal',
      description: 'Earn 1,000,000 XP. A lifetime of discipline.',
      metric: BadgeMetric.totalXp,
      target: 1000000,
      tier: 'legendary',
    ),
  ];
}
