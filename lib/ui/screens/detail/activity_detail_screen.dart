import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/challenge_easter_egg_service.dart';
import '../../../core/services/motivational_quote_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/services/challenge_reward_service.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_provider.dart';
import '../../../providers/gamification_settings_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../core/services/photo_service.dart';
import '../../widgets/contribution_grid.dart';
import '../../widgets/day_completion_toast.dart';
import '../create/create_activity_sheet.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

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
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        return _DetailBody(activity: activity);
      },
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.activity});

  final Activity activity;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  String? _summaryMarker;
  String? _eggCelebrationMarker;

  Activity get activity => widget.activity;

  Future<void> _maybeShowChallengeSummary(
    BuildContext context,
    ChallengeRewardProgress progress,
  ) async {
    if (activity.type != ActivityType.challenge) return;

    final today = PaceDateUtils.toDateOnly(DateTime.now());
    final endDate = progress.profile.endDate;
    final finishedByDate = !today.isBefore(endDate);
    final finishedByProgress = progress.profile.completionRatePercent >= 100;

    if (!finishedByDate && !finishedByProgress) return;

    final marker = '${activity.id}:${PaceDateUtils.toDateKey(endDate)}';
    if (_summaryMarker == marker) return;
    _summaryMarker = marker;

    final prefs = await SharedPreferences.getInstance();
    final prefKey = 'challenge_summary_shown_$marker';
    if (prefs.getBool(prefKey) ?? false) return;
    await prefs.setBool(prefKey, true);

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final rank = _challengeRank(progress);
        final badgePreview = progress.unlockedBadgeTitles.take(5).join(' • ');
        final trophyPreview = progress.unlockedTrophyTitles.take(4).join(' • ');

        return AlertDialog(
          title: const Text('Challenge Complete'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryStatRow(
                  label: 'Window',
                  value:
                      '${DateFormat('MMM d, yyyy').format(progress.profile.startDate)} → ${DateFormat('MMM d, yyyy').format(progress.profile.endDate)}',
                ),
                _SummaryStatRow(
                  label: 'Duration',
                  value: '${progress.profile.durationDays} days',
                ),
                _SummaryStatRow(
                  label: 'Completion',
                  value: '${progress.profile.completionRatePercent}% of required days',
                ),
                _SummaryStatRow(
                  label: 'XP Earned',
                  value: '${progress.challengeXp} XP',
                ),
                _SummaryStatRow(
                  label: 'Length Bonus',
                  value: 'x${progress.profile.lengthMultiplier.toStringAsFixed(2)}',
                ),
                _SummaryStatRow(
                  label: 'Badges',
                  value: '${progress.badgesUnlocked}/${progress.profile.badges.length}',
                ),
                _SummaryStatRow(
                  label: 'Trophies',
                  value: '${progress.trophiesUnlocked}/${progress.profile.trophies.length}',
                ),
                if (progress.easterEggsTarget > 0)
                  _SummaryStatRow(
                    label: 'Easter Eggs',
                    value: '${progress.easterEggsUnlocked}/${progress.easterEggsTarget}',
                  ),
                const SizedBox(height: 12),
                Text(
                  badgePreview.isEmpty
                      ? 'No challenge badges unlocked.'
                      : 'Badges: $badgePreview',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  trophyPreview.isEmpty
                      ? 'No challenge trophies unlocked.'
                      : 'Trophies: $trophyPreview',
                  style: theme.textTheme.bodySmall,
                ),
                if (progress.easterEggsTarget > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    progress.unlockedEasterEggTitles.isEmpty
                        ? 'No easter eggs found yet.'
                        : 'Easter Eggs: ${progress.unlockedEasterEggTitles.take(4).join(' • ')}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _maybeShowEasterEggMetaCelebration(
    BuildContext context,
    ChallengeRewardProgress progress,
  ) async {
    if (!progress.easterEggMetaTrophyUnlocked) return;

    final marker =
        '${activity.id}:${progress.easterEggsUnlocked}:${progress.easterEggsTarget}';
    if (_eggCelebrationMarker == marker) return;
    _eggCelebrationMarker = marker;

    final prefs = await SharedPreferences.getInstance();
    final prefKey = 'challenge_egg_meta_shown_${activity.id}';
    if (prefs.getBool(prefKey) ?? false) return;
    await prefs.setBool(prefKey, true);

    final quote = await MotivationalQuoteService.getCelebrationQuote();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final accent = Color(activity.colorValue);

        return AlertDialog(
          title: const Text('Meta Trophy Unlocked'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.75, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: accent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                EliteChallengeEasterEggService.metaTrophyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All 12 monthly easter eggs discovered.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                quote,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Legendary'),
            ),
          ],
        );
      },
    );
  }

  String _challengeRank(ChallengeRewardProgress progress) {
    final duration = progress.profile.durationDays;
    final completion = progress.profile.completionRatePercent;

    if (completion >= 100) {
      if (duration >= 365) return 'Legendary Marathon';
      if (duration >= 180) return 'Endurance Champion';
      if (duration >= 90) return 'Season Complete';
      if (duration >= 30) return 'Challenge Complete';
      return 'Sprint Complete';
    }

    if (completion >= 95) return 'Near Perfect Finish';
    if (completion >= 85) return 'Strong Finish';
    if (completion >= 70) return 'Steady Finish';
    if (completion >= 50) return 'Solid Run';
    return 'Challenge in Progress';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(activity.colorValue);
    final icon = IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons');

    final ref = this.ref;
    final streak = ref.watch(streakProvider(activity.id));
    final challengeXp = ref.watch(challengeXpProvider(activity.id));
    // For heatmap & calendar
    final completionsAsync =
        ref.watch(completionsForActivityProvider(activity.id));
    final completions = completionsAsync.valueOrNull ?? const [];
    final dateKeys = completionsAsync.valueOrNull
        ?.map((c) => c.dateKey)
        .toSet() ??
      {};
    final photoCompletions =
      completions.where((completion) => completion.photoPath != null).length;

    final challengeProgress = ChallengeRewardService.evaluate(
      activity: activity,
      completionCount: streak.totalCompletions,
      photoCompletionCount: photoCompletions,
      currentStreak: streak.current,
      longestStreak: streak.longest,
      challengeXp: challengeXp,
      completionDateKeys: dateKeys,
    );
    final gmSettings = ref.watch(gamificationSettingsProvider);
    final eggHint = gmSettings.showEasterEggHints
        ? EliteChallengeEasterEggService.monthlyHint(
            activity: activity,
            completionDateKeys: dateKeys,
          )
        : null;

    if (activity.type == ActivityType.challenge) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _maybeShowChallengeSummary(context, challengeProgress);
        _maybeShowEasterEggMetaCelebration(context, challengeProgress);
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar.medium(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEditSheet(context, ref),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: theme.colorScheme.error),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    activity.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Stats Row ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _StatCard(
                    label: 'Current',
                    value: '${streak.current}',
                    icon: '🔥',
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Longest',
                    value: '${streak.longest}',
                    icon: '🏆',
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Total',
                    value: '${streak.totalCompletions}',
                    icon: '✅',
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Rate',
                    value: dateKeys.isEmpty
                        ? '–'
                        : '${(StreakCalculator.completionRate(dateKeys, activity.createdAt, DateTime.now()) * 100).toStringAsFixed(0)}%',
                    icon: '📈',
                    color: color,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _ChallengeProgressCard(
                color: color,
                progress: challengeProgress,
                radarHint: eggHint?.eggAlreadyFound == false ? eggHint?.message : null,
                onViewAchievements: activity.type == ActivityType.challenge
                    ? () => context.push('/activity/${activity.id}/achievements')
                    : null,
                onViewEasterEggs: challengeProgress.easterEggsTarget > 0
                    ? () => context.push('/activity/${activity.id}/easter-eggs')
                    : null,
              ),
            ),
          ),

          // ── Montage & Check-in ──────────────────────────────────────────
          if (activity.requiresPhoto)
            _PhotoCheckIn(activity: activity),

          if (activity.requiresPhoto)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _MontageCard(activity: activity),
              ),
            ),

          // ── Contribution Grid ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('52-Week Overview'),
                  const SizedBox(height: 12),
                  ContributionGrid(
                    dateKeys: dateKeys,
                    color: color,
                    startDate: DateTime(DateTime.now().year, 1, 1),
                    endDate: DateTime(DateTime.now().year, 12, 31),
                  ),
                ],
              ),
            ),
          ),

          // ── Advanced Performance Charts ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Performance Signals'),
                  const SizedBox(height: 12),
                  _MomentumChart30Days(activityId: activity.id, color: color),
                  const SizedBox(height: 16),
                  _WeekdayPatternChart(activityId: activity.id, color: color),
                ],
              ),
            ),
          ),

          // ── Yearly Calendar ────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _SectionTitle('Activity Calendar'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final monthDate = DateTime(DateTime.now().year, index + 1, 1);

                if (index >= 12) return null;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(monthDate),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MonthCalendar(
                        activity: activity,
                        color: color,
                        month: monthDate,
                      ),
                    ],
                  ),
                );
              },
              childCount: 12,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Activity?'),
        content: const Text(
          'This will hide the activity from your dashboard. All completion data is preserved.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ref
          .read(activityNotifierProvider.notifier)
          .archive(activity.id);
      if (context.mounted) context.pop();
    }
  }

  void _openEditSheet(BuildContext context, WidgetRef ref) {
    ref.read(createSheetOpenProvider.notifier).state = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateActivitySheet(existing: activity),
    ).whenComplete(() {
      ref.read(createSheetOpenProvider.notifier).state = false;
    });
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _PhotoCheckIn extends ConsumerWidget {
  const _PhotoCheckIn({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = PaceDateUtils.todayKey();
    
    // Check if we already have a completion with a photo
    final completionsMap = ref.watch(completionMapProvider(activity.id));
    final todayCompletion = completionsMap[today];
    final isDoneToday = todayCompletion != null;
    
    final color = Color(activity.colorValue);

    if (isDoneToday) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
            ),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.camera_alt_rounded, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                'Today\'s Challenge',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a photo to complete for today',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _triggerPicker(context, ref),
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('Capture Progress'),
                  style: FilledButton.styleFrom(backgroundColor: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerPicker(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(completionNotifierProvider.notifier);
    final dateKey = PaceDateUtils.todayKey();

    ref.read(createSheetOpenProvider.notifier).state = true;
    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceSheet(color: Color(activity.colorValue)),
    );
    ref.read(createSheetOpenProvider.notifier).state = false;

    if (source == null) return;

    final file = await PhotoService.instance.pickImage(fromCamera: source);
    if (file == null) return;

    final savedPath = await PhotoService.instance.saveImageToAppStorage(
      file,
      dateKey,
      activity.id,
    );

    final result =
        await notifier.toggle(activity.id, dateKey, photoPath: savedPath);
    if (!context.mounted || result == null) return;
    await showDayCompletionToast(
      context,
      ref,
      result,
      activity: activity,
      dateKey: dateKey,
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text('Choose Photo Source', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.camera_alt_rounded, color: color),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            leading: Icon(Icons.photo_library_rounded, color: color),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeProgressCard extends StatelessWidget {
  const _ChallengeProgressCard({
    required this.color,
    required this.progress,
    this.radarHint,
    this.onViewAchievements,
    this.onViewEasterEggs,
  });

  final Color color;
  final ChallengeRewardProgress progress;
  final String? radarHint;
  final VoidCallback? onViewAchievements;
  final VoidCallback? onViewEasterEggs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final badgePreview = progress.unlockedBadgeTitles.take(4).join(' • ');
    final trophyPreview = progress.unlockedTrophyTitles.take(3).join(' • ');
    final eggPreview = progress.unlockedEasterEggTitles.take(3).join(' • ');
    final profile = progress.profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenge Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${DateFormat('MMM d, yyyy').format(profile.startDate)} → ${DateFormat('MMM d, yyyy').format(profile.endDate)} • ${profile.durationDays} days • x${profile.lengthMultiplier.toStringAsFixed(2)} length bonus',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                label: 'Days',
                value: '${profile.durationDays}',
                color: color,
              ),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'Challenge XP',
                value: '${progress.challengeXp}',
                color: color,
              ),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'Badges',
                value: '${progress.badgesUnlocked}/${profile.badges.length}',
                color: color,
              ),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'Trophies',
                value: '${progress.trophiesUnlocked}/${profile.trophies.length}',
                color: color,
              ),
              if (progress.easterEggsTarget > 0) ...[
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Eggs',
                  value: '${progress.easterEggsUnlocked}/${progress.easterEggsTarget}',
                  color: color,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badgePreview.isEmpty
                ? 'No challenge badges yet.'
                : 'Recent badges: $badgePreview',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            trophyPreview.isEmpty
                ? 'No challenge trophies yet.'
                : 'Recent trophies: $trophyPreview',
            style: theme.textTheme.bodySmall,
          ),
          if (progress.easterEggsTarget > 0) ...[
            const SizedBox(height: 6),
            Text(
              eggPreview.isEmpty
                  ? 'Easter Eggs: Find each month\'s secret completion day.'
                  : 'Recent eggs: $eggPreview',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (radarHint != null) ...[
            const SizedBox(height: 6),
            Text(
              radarHint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.tealAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (onViewAchievements != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewAchievements,
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('View Challenge Achievements'),
              ),
            ),
          ],
          if (onViewEasterEggs != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewEasterEggs,
                icon: const Icon(Icons.egg_alt_rounded),
                label: const Text('View Easter Egg Gallery'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatRow extends StatelessWidget {
  const _SummaryStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MontageCard extends StatelessWidget {
  const _MontageCard({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(activity.colorValue);

    return InkWell(
      onTap: () => context.push('/activity/${activity.id}/montage'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.movie_creation_rounded, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visual Montage',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'View your progress through photos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MomentumChart30Days extends ConsumerWidget {
  const _MomentumChart30Days({required this.activityId, required this.color});

  final int activityId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(recentDailyProvider(
      (activityId: activityId, days: 30),
    ));

    final values = data.values.toList();
    if (values.isEmpty) {
      return const SizedBox(height: 170);
    }

    final today = PaceDateUtils.toDateOnly(DateTime.now());
    final startDate = today.subtract(Duration(days: values.length - 1));

    final rolling = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      final start = i - 6 < 0 ? 0 : i - 6;
      final segment = values.sublist(start, i + 1);
      final avg = segment.where((v) => v).length / segment.length;
      rolling.add(FlSpot(i.toDouble(), avg));
    }

    final monthRate = values.where((v) => v).length / values.length;

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 0.25,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                getTitlesWidget: (v, _) {
                  final dayIndex = v.toInt();
                  if (dayIndex < 0 || dayIndex >= values.length) {
                    return const SizedBox.shrink();
                  }
                  final date = startDate.add(Duration(days: dayIndex));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((touched) {
                  final idx = touched.x.toInt().clamp(0, values.length - 1);
                  final date = startDate.add(Duration(days: idx));
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}\n${(touched.y * 100).toStringAsFixed(0)}% 7d avg',
                    const TextStyle(fontWeight: FontWeight.w700),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: rolling,
              isCurved: true,
              curveSmoothness: 0.22,
              barWidth: 3,
              color: color,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => spot.x % 7 == 0 || spot.x == rolling.last.x,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 2.8,
                  color: color,
                  strokeColor: Theme.of(context).colorScheme.surface,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.24),
                    color.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: monthRate,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                strokeWidth: 1.2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  labelResolver: (_) =>
                      '30d ${(monthRate * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayPatternChart extends ConsumerWidget {
  const _WeekdayPatternChart({required this.activityId, required this.color});

  final int activityId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completions =
        ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
    final keys = completions.map((c) => c.dateKey).toSet();
    final today = PaceDateUtils.toDateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 83));
    final range = PaceDateUtils.dateRange(start, today);

    final totalByWeekday = List<int>.filled(7, 0);
    final doneByWeekday = List<int>.filled(7, 0);

    for (final date in range) {
      final weekdayIdx = date.weekday - 1;
      totalByWeekday[weekdayIdx] += 1;
      if (keys.contains(PaceDateUtils.toDateKey(date))) {
        doneByWeekday[weekdayIdx] += 1;
      }
    }

    final rates = List<double>.generate(
      7,
      (i) => totalByWeekday[i] == 0 ? 0.0 : doneByWeekday[i] / totalByWeekday[i],
    );

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: 1,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 0.25,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[v.toInt()],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                return BarTooltipItem(
                  '${labels[group.x]} ${(rod.toY * 100).toStringAsFixed(0)}%',
                  const TextStyle(fontWeight: FontWeight.w700),
                );
              },
            ),
          ),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: rates[i],
                  width: 16,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      color.withValues(alpha: 0.6),
                      color,
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _MonthCalendar extends ConsumerWidget {
  const _MonthCalendar({
    required this.activity,
    required this.color,
    required this.month,
  });

  final Activity activity;
  final Color color;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final firstDay = DateTime.utc(month.year, month.month, 1);
    final daysInMonth = PaceDateUtils.daysInMonth(month);
    final startOffset = firstDay.weekday - 1; // Mon = 0
    final today = PaceDateUtils.toDateOnly(DateTime.now());

    final completionsMap = ref.watch(completionMapProvider(activity.id));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: startOffset + daysInMonth,
      itemBuilder: (ctx, i) {
        if (i < startOffset) return const SizedBox.shrink();
        final day = i - startOffset + 1;
        final date = DateTime.utc(month.year, month.month, day);
        final key = PaceDateUtils.toDateKey(date);
        
        final completion = completionsMap[key];
        final done = completion != null;
        final hasPhoto = completion?.photoPath != null;
        final isToday = date == today;

        return InkWell(
          onTap: () async {
            if (date.isAfter(today)) return; // Can't mark future
            
            final notifier = ref.read(completionNotifierProvider.notifier);
            
            if (!done) {
              if (activity.requiresPhoto) {
                // Trigger photo picker for strict requirement
                await _triggerPicker(ctx, ref, date);
              } else {
                final result = await notifier.toggle(activity.id, key);
                if (!ctx.mounted || result == null) return;
                await showDayCompletionToast(
                  ctx,
                  ref,
                  result,
                  activity: activity,
                  dateKey: key,
                );
              }
            } else {
              await notifier.toggle(activity.id, key);
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done && !hasPhoto
                  ? color
                  : isToday && !done
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
              border: isToday && !done
                  ? Border.all(color: color, width: 1.5)
                  : null,
              image: hasPhoto
                  ? DecorationImage(
                      image: FileImage(File(completion!.photoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: done || isToday ? FontWeight.w700 : FontWeight.w400,
                  color: (done && !hasPhoto)
                      ? Colors.white
                      : isToday
                          ? color
                          : hasPhoto 
                             ? Colors.white // White text on photo thumbnail
                             : theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  shadows: hasPhoto ? [
                    const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54)
                  ] : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _triggerPicker(BuildContext context, WidgetRef ref, DateTime date) async {
    final notifier = ref.read(completionNotifierProvider.notifier);
    final dateKey = PaceDateUtils.toDateKey(date);

    ref.read(createSheetOpenProvider.notifier).state = true;
    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceSheet(color: Color(activity.colorValue)),
    );
    ref.read(createSheetOpenProvider.notifier).state = false;

    if (source == null) return;

    final file = await PhotoService.instance.pickImage(fromCamera: source);
    if (file == null) return;

    final savedPath = await PhotoService.instance.saveImageToAppStorage(
      file,
      dateKey,
      activity.id,
    );

    final result =
        await notifier.toggle(activity.id, dateKey, photoPath: savedPath);
    if (!context.mounted || result == null) return;
    await showDayCompletionToast(
      context,
      ref,
      result,
      activity: activity,
      dateKey: dateKey,
    );
  }
}
