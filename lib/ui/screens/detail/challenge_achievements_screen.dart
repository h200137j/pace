import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/challenge_easter_egg_service.dart';
import '../../../core/services/challenge_reward_service.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_provider.dart';

class ChallengeAchievementsScreen extends ConsumerWidget {
  const ChallengeAchievementsScreen({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityByIdProvider(activityId));

    return activityAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (activity) {
        if (activity == null) {
          return const Scaffold(body: Center(child: Text('Challenge not found')));
        }
        if (activity.type != ActivityType.challenge) {
          return Scaffold(
            appBar: AppBar(title: const Text('Challenge Achievements')),
            body: const Center(
              child: Text('This activity does not have challenge achievements.'),
            ),
          );
        }

        final streak = ref.watch(streakProvider(activity.id));
        final challengeXp = ref.watch(challengeXpProvider(activity.id));
        final completions =
            ref.watch(completionsForActivityProvider(activity.id)).valueOrNull ??
                const [];
        final completionDateKeys = completions.map((c) => c.dateKey).toSet();
        final photoCompletions =
            completions.where((completion) => completion.photoPath != null).length;

        final rewardProgress = ChallengeRewardService.evaluate(
          activity: activity,
          completionCount: streak.totalCompletions,
          photoCompletionCount: photoCompletions,
          currentStreak: streak.current,
          longestStreak: streak.longest,
          challengeXp: challengeXp,
          completionDateKeys: completionDateKeys,
        );

        final badgeRows = rewardProgress.profile.badges
            .map(
              (def) => _RewardRowData(
                definition: def,
                value: _metricValueForDefinition(
                  definition: def,
                  profile: rewardProgress.profile,
                  completionCount: streak.totalCompletions,
                  photoCompletionCount: photoCompletions,
                  currentStreak: streak.current,
                  longestStreak: streak.longest,
                  challengeXp: challengeXp,
                  unlockedBadgeCount: rewardProgress.badgesUnlocked,
                ),
              ),
            )
            .toList();

        final trophyRows = rewardProgress.profile.trophies
            .map(
              (def) => _RewardRowData(
                definition: def,
                value: _metricValueForDefinition(
                  definition: def,
                  profile: rewardProgress.profile,
                  completionCount: streak.totalCompletions,
                  photoCompletionCount: photoCompletions,
                  currentStreak: streak.current,
                  longestStreak: streak.longest,
                  challengeXp: challengeXp,
                  unlockedBadgeCount: rewardProgress.badgesUnlocked,
                ),
              ),
            )
            .toList();

        _sortRewards(badgeRows);
        _sortRewards(trophyRows);

        final color = Color(activity.colorValue);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text('${activity.name} Achievements'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _OverviewCard(
                color: color,
                badgesUnlocked: rewardProgress.badgesUnlocked,
                totalBadges: rewardProgress.profile.badges.length,
                trophiesUnlocked: rewardProgress.trophiesUnlocked,
                totalTrophies: rewardProgress.profile.trophies.length,
                easterEggsUnlocked: rewardProgress.easterEggsUnlocked,
                totalEasterEggs: rewardProgress.easterEggsTarget,
              ),
              if (rewardProgress.easterEggsTarget > 0)
                _SettingsLikeAction(
                  icon: Icons.egg_alt_rounded,
                  title: 'Easter Egg Gallery',
                  subtitle: rewardProgress.easterEggMetaTrophyUnlocked
                      ? 'Meta trophy unlocked: ${EliteChallengeEasterEggService.metaTrophyTitle}'
                      : 'Track all 12 monthly secret eggs',
                  onTap: () => context.push('/activity/${activity.id}/easter-eggs'),
                ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Challenge Badges',
                subtitle:
                    '${rewardProgress.badgesUnlocked}/${rewardProgress.profile.badges.length} unlocked',
              ),
              const SizedBox(height: 8),
              for (final row in badgeRows)
                _RewardCard(
                  data: row,
                  unlockedColor: Colors.amber,
                  lockedColor: color,
                  icon: Icons.military_tech_rounded,
                ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Challenge Trophies',
                subtitle:
                    '${rewardProgress.trophiesUnlocked}/${rewardProgress.profile.trophies.length} unlocked',
              ),
              const SizedBox(height: 8),
              for (final row in trophyRows)
                _RewardCard(
                  data: row,
                  unlockedColor: Colors.deepOrange,
                  lockedColor: color,
                  icon: Icons.emoji_events_rounded,
                ),
            ],
          ),
        );
      },
    );
  }
}

int _metricValueForDefinition({
  required ChallengeRewardDefinition definition,
  required ChallengeRewardProfile profile,
  required int completionCount,
  required int photoCompletionCount,
  required int currentStreak,
  required int longestStreak,
  required int challengeXp,
  required int unlockedBadgeCount,
}) {
  switch (definition.metric) {
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
      return unlockedBadgeCount;
    case ChallengeRewardMetric.durationDays:
      return profile.durationDays;
    case ChallengeRewardMetric.completionRate:
      return profile.completionRatePercent;
  }
}

void _sortRewards(List<_RewardRowData> rows) {
  final unlocked = <_RewardRowData>[];
  final locked = <_RewardRowData>[];

  for (final row in rows) {
    if (row.isUnlocked) {
      unlocked.add(row);
    } else {
      locked.add(row);
    }
  }

  unlocked.sort((a, b) => a.definition.target.compareTo(b.definition.target));

  locked.sort((a, b) {
    final progressA = a.ratio;
    final progressB = b.ratio;
    final ratioCompare = progressB.compareTo(progressA);
    if (ratioCompare != 0) {
      return ratioCompare;
    }
    return a.definition.target.compareTo(b.definition.target);
  });

  rows
    ..clear()
    ..addAll(unlocked)
    ..addAll(locked);
}

class _RewardRowData {
  const _RewardRowData({
    required this.definition,
    required this.value,
  });

  final ChallengeRewardDefinition definition;
  final int value;

  bool get isUnlocked => value >= definition.target;

  int get clampedValue => value > definition.target ? definition.target : value;

  double get ratio {
    if (definition.target <= 0) {
      return 0;
    }
    return (clampedValue / definition.target).clamp(0.0, 1.0);
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.color,
    required this.badgesUnlocked,
    required this.totalBadges,
    required this.trophiesUnlocked,
    required this.totalTrophies,
    required this.easterEggsUnlocked,
    required this.totalEasterEggs,
  });

  final Color color;
  final int badgesUnlocked;
  final int totalBadges;
  final int trophiesUnlocked;
  final int totalTrophies;
  final int easterEggsUnlocked;
  final int totalEasterEggs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewStat(
              label: 'Badges',
              value: '$badgesUnlocked/$totalBadges',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OverviewStat(
              label: 'Trophies',
              value: '$trophiesUnlocked/$totalTrophies',
            ),
          ),
          if (totalEasterEggs > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewStat(
                label: 'Eggs',
                value: '$easterEggsUnlocked/$totalEasterEggs',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsLikeAction extends StatelessWidget {
  const _SettingsLikeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.data,
    required this.unlockedColor,
    required this.lockedColor,
    required this.icon,
  });

  final _RewardRowData data;
  final Color unlockedColor;
  final Color lockedColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = data.isUnlocked;
    final percent = (data.ratio * 100).round();
    final color = unlocked ? unlockedColor : lockedColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: unlocked
            ? unlockedColor.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: unlocked
                ? unlockedColor.withValues(alpha: 0.28)
                : Colors.grey.withValues(alpha: 0.22),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.definition.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.definition.description,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      unlocked ? 'Unlocked' : '$percent%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Progress: ${data.clampedValue}/${data.definition.target}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: data.ratio,
                  minHeight: 8,
                  backgroundColor: Colors.black.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
