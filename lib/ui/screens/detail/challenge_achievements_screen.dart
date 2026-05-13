import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/challenge_easter_egg_service.dart';
import '../../../core/services/challenge_reward_service.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_provider.dart';

class ChallengeAchievementsScreen extends ConsumerStatefulWidget {
  const ChallengeAchievementsScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<ChallengeAchievementsScreen> createState() =>
      _ChallengeAchievementsScreenState();
}

class _ChallengeAchievementsScreenState
    extends ConsumerState<ChallengeAchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityByIdProvider(widget.activityId));

    return activityAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (activity) {
        if (activity == null) {
          return const Scaffold(
              body: Center(child: Text('Challenge not found')));
        }
        if (activity.type != ActivityType.challenge) {
          return Scaffold(
            appBar: AppBar(title: const Text('Achievements')),
            body: const Center(
              child: Text('Only challenges have this screen.'),
            ),
          );
        }
        return _AchievementsBody(
          activity: activity,
          tabCtrl: _tabCtrl,
        );
      },
    );
  }
}

// ── Body (stateless after data resolved) ──────────────────────────────────

class _AchievementsBody extends ConsumerWidget {
  const _AchievementsBody({
    required this.activity,
    required this.tabCtrl,
  });

  final Activity activity;
  final TabController tabCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider(activity.id));
    final challengeXp = ref.watch(challengeXpProvider(activity.id));
    final completions =
        ref.watch(completionsForActivityProvider(activity.id)).valueOrNull ??
            const [];
    final completionDateKeys = completions.map((c) => c.dateKey).toSet();
    final photoCompletions =
        completions.where((c) => c.photoPath != null).length;

    final progress = ChallengeRewardService.evaluate(
      activity: activity,
      completionCount: streak.totalCompletions,
      photoCompletionCount: photoCompletions,
      currentStreak: streak.current,
      longestStreak: streak.longest,
      challengeXp: challengeXp,
      completionDateKeys: completionDateKeys,
    );

    final color = Color(activity.colorValue);

    final badgeRows = _buildRows(
      defs: progress.profile.badges,
      progress: progress,
      streak: streak,
      photoCompletions: photoCompletions,
      challengeXp: challengeXp,
    );
    final trophyRows = _buildRows(
      defs: progress.profile.trophies,
      progress: progress,
      streak: streak,
      photoCompletions: photoCompletions,
      challengeXp: challengeXp,
    );

    _sortRows(badgeRows);
    _sortRows(trophyRows);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              activity.name,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: tabCtrl,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                            'Badges  ${progress.badgesUnlocked}/${progress.profile.badges.length}'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                            'Trophies  ${progress.trophiesUnlocked}/${progress.profile.trophies.length}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overview + Easter Egg link in header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewCard(
                    color: color,
                    progress: progress,
                    activity: activity,
                  ),
                  if (progress.easterEggsTarget > 0) ...[
                    const SizedBox(height: 10),
                    _EasterEggTile(
                      color: color,
                      progress: progress,
                      activityId: activity.id,
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: tabCtrl,
          children: [
            _RewardList(rows: badgeRows, color: color, isBadge: true),
            _RewardList(rows: trophyRows, color: color, isBadge: false),
          ],
        ),
      ),
    );
  }

  List<_RowData> _buildRows({
    required List<ChallengeRewardDefinition> defs,
    required ChallengeRewardProgress progress,
    required dynamic streak,
    required int photoCompletions,
    required int challengeXp,
  }) {
    return defs.map((def) {
      final value = _metricValue(
        def,
        progress.profile,
        streak.totalCompletions,
        photoCompletions,
        streak.current,
        streak.longest,
        challengeXp,
        progress.badgesUnlocked,
      );
      return _RowData(def: def, value: value);
    }).toList();
  }
}

// ── Reward list tab ────────────────────────────────────────────────────────

class _RewardList extends StatelessWidget {
  const _RewardList({
    required this.rows,
    required this.color,
    required this.isBadge,
  });

  final List<_RowData> rows;
  final Color color;
  final bool isBadge;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(child: Text('No items.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      itemCount: rows.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _RewardCard(
          data: rows[i],
          color: color,
          isBadge: isBadge,
        ),
      ),
    );
  }
}

// ── Card ────────────────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.data,
    required this.color,
    required this.isBadge,
  });

  final _RowData data;
  final Color color;
  final bool isBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = data.isUnlocked;
    final accent = unlocked ? color : color.withValues(alpha: 0.4);
    final percent = (data.ratio * 100).round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.1)
            : const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? color.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.04),
                ),
                child: Icon(
                  unlocked
                      ? (isBadge
                          ? Icons.military_tech_rounded
                          : Icons.emoji_events_rounded)
                      : Icons.lock_outline_rounded,
                  color: unlocked
                      ? color
                      : Colors.white.withValues(alpha: 0.2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.def.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: unlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.def.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white
                            .withValues(alpha: unlocked ? 0.5 : 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  unlocked ? 'Done' : '$percent%',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.ratio,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor:
                        AlwaysStoppedAnimation(accent.withValues(alpha: 0.8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_fmt(data.clampedValue)} / ${_fmt(data.def.target)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Overview card ──────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.color,
    required this.progress,
    required this.activity,
  });

  final Color color;
  final ChallengeRewardProgress progress;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = progress.profile;
    final start = DateFormat('MMM d, y').format(p.startDate);
    final end = DateFormat('MMM d, y').format(p.endDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration row
          Text(
            '$start → $end  ·  ${p.durationDays} days  ·  ×${p.lengthMultiplier.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _StatTile(
                label: 'Badges',
                value: '${progress.badgesUnlocked}/${p.badges.length}',
                color: color,
              ),
              const SizedBox(width: 10),
              _StatTile(
                label: 'Trophies',
                value: '${progress.trophiesUnlocked}/${p.trophies.length}',
                color: color,
              ),
              const SizedBox(width: 10),
              _StatTile(
                label: 'Rate',
                value: '${p.completionRatePercent}%',
                color: color,
              ),
              if (progress.easterEggsTarget > 0) ...[
                const SizedBox(width: 10),
                _StatTile(
                  label: 'Eggs',
                  value:
                      '${progress.easterEggsUnlocked}/${progress.easterEggsTarget}',
                  color: color,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Easter egg tile ────────────────────────────────────────────────────────

class _EasterEggTile extends StatelessWidget {
  const _EasterEggTile({
    required this.color,
    required this.progress,
    required this.activityId,
  });

  final Color color;
  final ChallengeRewardProgress progress;
  final int activityId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metaUnlocked = progress.easterEggMetaTrophyUnlocked;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Icon(Icons.egg_alt_rounded, color: color, size: 20),
      ),
      title: Text(
        'Easter Egg Gallery',
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        metaUnlocked
            ? 'Meta trophy unlocked: ${EliteChallengeEasterEggService.metaTrophyTitle}'
            : '${progress.easterEggsUnlocked}/${progress.easterEggsTarget} monthly eggs found',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/activity/$activityId/easter-eggs'),
    );
  }
}

// ── Data & helpers ─────────────────────────────────────────────────────────

class _RowData {
  const _RowData({required this.def, required this.value});

  final ChallengeRewardDefinition def;
  final int value;

  bool get isUnlocked => value >= def.target;
  int get clampedValue => value > def.target ? def.target : value;
  double get ratio =>
      def.target <= 0 ? 0 : (clampedValue / def.target).clamp(0.0, 1.0);
}

void _sortRows(List<_RowData> rows) {
  final unlocked = rows.where((r) => r.isUnlocked).toList()
    ..sort((a, b) => a.def.target.compareTo(b.def.target));
  final locked = rows.where((r) => !r.isUnlocked).toList()
    ..sort((a, b) {
      final cmp = b.ratio.compareTo(a.ratio);
      return cmp != 0 ? cmp : a.def.target.compareTo(b.def.target);
    });
  rows
    ..clear()
    ..addAll(unlocked)
    ..addAll(locked);
}

int _metricValue(
  ChallengeRewardDefinition def,
  ChallengeRewardProfile profile,
  int completions,
  int photoCompletions,
  int currentStreak,
  int longestStreak,
  int challengeXp,
  int unlockedBadges,
) {
  return switch (def.metric) {
    ChallengeRewardMetric.completions => completions,
    ChallengeRewardMetric.photoCompletions => photoCompletions,
    ChallengeRewardMetric.xp => challengeXp,
    ChallengeRewardMetric.currentStreak => currentStreak,
    ChallengeRewardMetric.longestStreak => longestStreak,
    ChallengeRewardMetric.badgeCount => unlockedBadges,
    ChallengeRewardMetric.durationDays => profile.durationDays,
    ChallengeRewardMetric.completionRate => profile.completionRatePercent,
  };
}

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
  return '$n';
}
