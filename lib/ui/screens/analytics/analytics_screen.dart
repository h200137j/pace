import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_provider.dart';
import '../../widgets/contribution_grid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar.medium(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Analytics',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Week'),
                Tab(text: 'Month'),
                Tab(text: 'Year'),
              ],
            ),
          ),
          // Enhancement 1 — Lifetime Stats Row
          const SliverToBoxAdapter(child: _LifetimeStatsSliver()),
        ],
        body: activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (activities) => TabBarView(
            controller: _tabCtrl,
            children: [
              _WeekTab(activities: activities),
              _MonthTab(activities: activities),
              _YearTab(activities: activities),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhancement 1 — Lifetime Stats Sliver
// ─────────────────────────────────────────────────────────────────────────────

class _LifetimeStatsSliver extends ConsumerWidget implements PreferredSizeWidget {
  const _LifetimeStatsSliver();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(gamificationProfileProvider).valueOrNull;
    final badges = ref.watch(badgeUnlocksProvider).valueOrNull ?? [];
    final trophies = ref.watch(trophyUnlocksProvider).valueOrNull ?? [];

    final badgeCount = badges.where((b) => b.unlockedAt != null).length;
    final trophyCount = trophies.where((t) => t.unlockedAt != null).length;

    final photoCount = profile?.lifetimePhotoCompletions ?? 0;

    final chips = [
      _StatChipData(label: 'Level', value: '${profile?.currentLevel ?? 0}'),
      _StatChipData(label: 'Total XP', value: _formatNumber(profile?.totalXp ?? 0)),
      _StatChipData(label: 'Completions', value: _formatNumber(profile?.lifetimeCompletions ?? 0)),
      if (photoCount > 0)
        _StatChipData(label: '📷 Photos', value: '$photoCount'),
      if (badgeCount > 0)
        _StatChipData(label: 'Badges', value: '$badgeCount'),
      if (trophyCount > 0)
        _StatChipData(label: 'Trophies', value: '$trophyCount'),
    ];

    return SizedBox(
      height: preferredSize.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _StatChip(data: chips[i]),
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatChipData {
  const _StatChipData({required this.label, required this.value});
  final String label;
  final String value;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.data});
  final _StatChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            data.value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00F2FF),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week tab
// ─────────────────────────────────────────────────────────────────────────────

class _WeekTab extends ConsumerWidget {
  const _WeekTab({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    final daySeries = _buildCompletionCountSeries(ref, activities, 7);
    final totalDone = daySeries.fold<int>(0, (sum, v) => sum + v);
    final maxPossible = activities.length * 7;
    final weeklyRate = maxPossible == 0 ? 0.0 : totalDone / maxPossible;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        // Enhancement 2 — Today's Progress card (first item)
        _TodayCard(activities: activities),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Weekly Completion Load',
          subtitle:
              '${(weeklyRate * 100).toStringAsFixed(0)}% overall completion • $totalDone/${maxPossible == 0 ? 1 : maxPossible} check-ins',
          child: SizedBox(
            height: 230,
            child: _WeeklyLoadChart(
              completedPerDay: daySeries,
              activityCount: activities.length,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Momentum By Activity',
          subtitle: 'Last 7 days compared with previous 7 days',
          child: _MomentumRanking(activities: activities),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhancement 2 — Today's Progress card
// ─────────────────────────────────────────────────────────────────────────────

class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = PaceDateUtils.todayKey();

    final doneFlags = [
      for (final a in activities)
        (ref.watch(completionsForActivityProvider(a.id)).valueOrNull ?? [])
            .any((c) => c.dateKey == today),
    ];

    final doneCount = doneFlags.where((d) => d).length;
    final total = activities.length;
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's Progress",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '$doneCount / $total done',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF00F2FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(
                  Colors.orange.shade400,
                  Colors.green.shade400,
                  progress,
                )!,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < activities.length; i++)
                _ActivityDotChip(
                  activity: activities[i],
                  done: doneFlags[i],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityDotChip extends StatelessWidget {
  const _ActivityDotChip({required this.activity, required this.done});
  final Activity activity;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = Color(activity.colorValue);
    final effectiveColor = done ? color : color.withValues(alpha: 0.3);

    return Tooltip(
      message: activity.name,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: done ? 0.18 : 0.07),
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveColor,
            width: done ? 2 : 1,
          ),
        ),
        child: Icon(
          IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons'),
          color: effectiveColor,
          size: 15,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month tab
// ─────────────────────────────────────────────────────────────────────────────

class _MonthTab extends ConsumerWidget {
  const _MonthTab({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    final monthRate = _buildDailyCompletionRateSeries(ref, activities, 30);
    final weekdayRate = _buildWeekdayRates(ref, activities, 30);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        _InsightCard(
          title: '30-Day Consistency Curve',
          subtitle: 'Daily completion rate with 7-day moving average',
          child: SizedBox(
            height: 240,
            child: _RateTrendChart(rates: monthRate),
          ),
        ),
        const SizedBox(height: 16),
        // Enhancement 3 — Photo Insights card (after consistency curve)
        _PhotoInsightCard(activities: activities),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Activity Comparison',
          subtitle: 'Completion percentage in the last 30 days',
          child: SizedBox(
            height: math.max(220, activities.length * 44).toDouble(),
            child: _ActivityRateBars(activities: activities),
          ),
        ),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Best Days To Schedule Work',
          subtitle: 'Average completion by weekday over the last 30 days',
          child: SizedBox(
            height: 220,
            child: _WeekdayRateChart(weekdayRates: weekdayRate),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhancement 3 — Photo Insights card
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoInsightCard extends ConsumerWidget {
  const _PhotoInsightCard({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = PaceDateUtils.toDateOnly(DateTime.now());
    final cutoff = now.subtract(const Duration(days: 29));

    // Aggregate completions across all activities for the last 30 days
    int totalCompletions = 0;
    int photoCompletions = 0;
    int noteCompletions = 0;

    // Map dateKey -> bool (had a photo that day)
    final photoByDay = <String, bool>{};

    for (final a in activities) {
      final completions =
          ref.watch(completionsForActivityProvider(a.id)).valueOrNull ?? [];
      for (final c in completions) {
        final date = DateTime.tryParse(c.dateKey);
        if (date == null) continue;
        final d = DateTime.utc(date.year, date.month, date.day);
        if (d.isBefore(cutoff)) continue;

        totalCompletions++;
        if (c.photoPath != null) {
          photoCompletions++;
          photoByDay[c.dateKey] = true;
        }
        if (c.note != null && c.note!.trim().isNotEmpty) {
          noteCompletions++;
        }
      }
    }

    // No photo data at all — card irrelevant, hide it.
    if (photoCompletions == 0) return const SizedBox.shrink();

    final photoRate = totalCompletions == 0
        ? 0.0
        : photoCompletions / totalCompletions;

    final photoStreak = _longestPhotoStreak(photoByDay, cutoff, now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Insights',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 30 days across all activities',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PhotoStatTile(
                  icon: Icons.photo_camera_outlined,
                  label: 'Photo rate',
                  value: '${(photoRate * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFF00F2FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoStatTile(
                  icon: Icons.notes_outlined,
                  label: 'Notes written',
                  value: '$noteCompletions',
                  color: Colors.amber.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PhotoStatTile(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Photo streak',
                  value: '${photoStreak}d',
                  color: Colors.deepOrange.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _longestPhotoStreak(
    Map<String, bool> photoByDay,
    DateTime cutoff,
    DateTime now,
  ) {
    final range = PaceDateUtils.dateRange(cutoff, now);
    int longest = 0;
    int current = 0;
    for (final d in range) {
      final key = PaceDateUtils.toDateKey(d);
      if (photoByDay.containsKey(key)) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }
}

class _PhotoStatTile extends StatelessWidget {
  const _PhotoStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
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
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Year tab
// ─────────────────────────────────────────────────────────────────────────────

class _YearTab extends ConsumerStatefulWidget {
  const _YearTab({required this.activities});
  final List<Activity> activities;

  @override
  ConsumerState<_YearTab> createState() => _YearTabState();
}

class _YearTabState extends ConsumerState<_YearTab> {
  int _selectedIndex = 0;
  // Enhancement 5 — Photo vs All toggle
  bool _showPhotosOnly = false;

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    final selected = widget.activities[_selectedIndex];
    final color = Color(selected.colorValue);

    final completionsAsync =
        ref.watch(completionsForActivityProvider(selected.id));
    final allCompletions = completionsAsync.valueOrNull ?? [];

    // Enhancement 5 — filter dateKeys based on toggle
    final dateKeys = _showPhotosOnly
        ? allCompletions
            .where((c) => c.photoPath != null)
            .map((c) => c.dateKey)
            .toSet()
        : allCompletions.map((c) => c.dateKey).toSet();

    final monthlyRate = _buildMonthlyRateForSingleActivity(
      allCompletions.map((c) => c.dateKey).toSet(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.activities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final a = widget.activities[i];
              final isSelected = i == _selectedIndex;
              return FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(a.name),
                onSelected: (_) => setState(() => _selectedIndex = i),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Enhancement 5 — Photo toggle only shown when activity has photos
        if (allCompletions.any((c) => c.photoPath != null))
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedButton<bool>(
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: Theme.of(context).textTheme.labelSmall,
            ),
            segments: const [
              ButtonSegment(value: false, label: Text('All')),
              ButtonSegment(value: true, label: Text('Photos')),
            ],
            selected: {_showPhotosOnly},
            onSelectionChanged: (s) =>
                setState(() => _showPhotosOnly = s.first),
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 8),
        _InsightCard(
          title: '52-Week Heatmap',
          subtitle: _showPhotosOnly
              ? 'Photo completion footprint for ${selected.name}'
              : 'Daily completion footprint for ${selected.name}',
          child: ContributionGrid(
            dateKeys: dateKeys,
            color: color,
            startDate: DateTime(DateTime.now().year, 1, 1),
            endDate: DateTime(DateTime.now().year, 12, 31),
          ),
        ),
        const SizedBox(height: 16),
        // Enhancement 4 — Monthly XP chart
        _MonthlyXpChart(color: color),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Monthly Consistency',
          subtitle: 'Completion percentage each month (this year)',
          child: SizedBox(
            height: 220,
            child: _MonthlyRateChart(rates: monthlyRate, color: color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Enhancement 4 — Monthly XP chart
// ─────────────────────────────────────────────────────────────────────────────

class _MonthlyXpChart extends ConsumerWidget {
  const _MonthlyXpChart({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final events = ref.watch(xpEventsProvider).valueOrNull ?? [];
    final now = DateTime.now();

    // Group totalAwardedXp by month for the current year
    final monthlyXp = List<int>.filled(12, 0);
    for (final e in events) {
      if (e.awardedAt.year == now.year) {
        final monthIdx = e.awardedAt.month - 1;
        monthlyXp[monthIdx] += e.totalAwardedXp;
      }
    }

    final maxXp = monthlyXp.reduce(math.max);

    return _InsightCard(
      title: 'Monthly XP Earned',
      subtitle: 'XP awarded per month (this year)',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: (maxXp == 0 ? 100 : maxXp * 1.2).toDouble(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval:
                  (maxXp == 0 ? 100 : maxXp * 1.2 / 4).toDouble(),
              getDrawingHorizontalLine: (_) => FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: (v, _) {
                    if (v == 0) return const SizedBox.shrink();
                    final label = v >= 1000
                        ? '${(v / 1000).toStringAsFixed(1)}k'
                        : v.toInt().toString();
                    return Text(label,
                        style: theme.textTheme.labelSmall);
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const months = [
                      'J', 'F', 'M', 'A', 'M', 'J',
                      'J', 'A', 'S', 'O', 'N', 'D'
                    ];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(months[value.toInt()],
                          style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, __) {
                  const months = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  return BarTooltipItem(
                    '${months[group.x.toInt()]}\n${rod.toY.toInt()} XP',
                    const TextStyle(fontWeight: FontWeight.w700),
                  );
                },
              ),
            ),
            barGroups: List.generate(12, (i) {
              final isFuture = i >= now.month;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: monthlyXp[i].toDouble(),
                    width: 16,
                    borderRadius: BorderRadius.circular(8),
                    color: isFuture
                        ? color.withValues(alpha: 0.25)
                        : color,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card shell
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing chart widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyLoadChart extends StatelessWidget {
  const _WeeklyLoadChart({required this.completedPerDay, required this.activityCount});

  final List<int> completedPerDay;
  final int activityCount;

  @override
  Widget build(BuildContext context) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxY = math.max(1, completedPerDay.reduce(math.max)).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY + 1,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.14),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[value.toInt()], style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final dayLabel = labels[group.x.toInt()];
              return BarTooltipItem(
                '$dayLabel\n${rod.toY.toInt()} completed',
                const TextStyle(fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        barGroups: List.generate(completedPerDay.length, (i) {
          final value = completedPerDay[i].toDouble();
          final strength = activityCount == 0 ? 0.0 : (value / activityCount).clamp(0.0, 1.0);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 24,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.lerp(Colors.orange.shade300, Colors.green.shade400, strength)!,
                    Color.lerp(Colors.orange.shade700, Colors.teal.shade500, strength)!,
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MomentumRanking extends ConsumerWidget {
  const _MomentumRanking({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranked = activities.map((a) {
      final data = _boolSeriesForActivity(ref, a.id, 14);
      final previous = data.take(7).where((v) => v).length;
      final recent = data.skip(7).where((v) => v).length;
      final delta = recent - previous;
      return _MomentumItem(activity: a, recent: recent, previous: previous, delta: delta, series: data);
    }).toList()
      ..sort((a, b) => b.recent.compareTo(a.recent));

    return Column(
      children: ranked.map((item) => _MomentumRow(item: item)).toList(),
    );
  }
}

class _MomentumItem {
  const _MomentumItem({
    required this.activity,
    required this.recent,
    required this.previous,
    required this.delta,
    required this.series,
  });

  final Activity activity;
  final int recent;
  final int previous;
  final int delta;
  final List<bool> series;
}

class _MomentumRow extends StatelessWidget {
  const _MomentumRow({required this.item});

  final _MomentumItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(item.activity.colorValue);
    final deltaColor = item.delta >= 0 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(item.activity.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.activity.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  '${item.recent}/7 this week • ${item.previous}/7 previous',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          SizedBox(width: 70, height: 26, child: _MiniSparkline(color: color, series: item.series)),
          const SizedBox(width: 10),
          Text(
            item.delta == 0 ? '0' : (item.delta > 0 ? '+${item.delta}' : '${item.delta}'),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: deltaColor),
          ),
        ],
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.color, required this.series});

  final Color color;
  final List<bool> series;

  @override
  Widget build(BuildContext context) {
    final spots = series.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value ? 1 : 0))
        .toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: color,
            barWidth: 1.8,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _RateTrendChart extends StatelessWidget {
  const _RateTrendChart({required this.rates});

  final List<double> rates;

  @override
  Widget build(BuildContext context) {
    if (rates.isEmpty) return const SizedBox.shrink();

    final moving = _movingAverage(rates, 7);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 0.25,
              getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('-${(29 - v.toInt()).clamp(0, 29)}d', style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${(s.y * 100).toStringAsFixed(0)}%',
                      const TextStyle(fontWeight: FontWeight.w700),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: rates.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            curveSmoothness: 0.25,
            color: Colors.blue.shade500,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.12),
            ),
          ),
          LineChartBarData(
            spots: moving.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            curveSmoothness: 0.2,
            color: Colors.orange.shade500,
            barWidth: 2.6,
            dotData: const FlDotData(show: false),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0.8,
              color: Colors.green.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRateBars extends ConsumerWidget {
  const _ActivityRateBars({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = activities.map((a) {
      final done = _boolSeriesForActivity(ref, a.id, 30).where((v) => v).length;
      final rate = done / 30;
      return (activity: a, rate: rate);
    }).toList()
      ..sort((a, b) => b.rate.compareTo(a.rate));

    return BarChart(
      BarChartData(
        maxY: 1,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 0.25,
              getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= rows.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      rows[index].activity.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final label = rows[group.x].activity.name;
              return BarTooltipItem(
                '$label\n${(rod.toY * 100).toStringAsFixed(0)}%',
                const TextStyle(fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        barGroups: List.generate(rows.length, (i) {
          final entry = rows[i];
          final color = Color(entry.activity.colorValue);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entry.rate,
                color: color,
                width: 18,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _WeekdayRateChart extends StatelessWidget {
  const _WeekdayRateChart({required this.weekdayRates});

  final List<double> weekdayRates;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return BarChart(
      BarChartData(
        maxY: 1,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 0.25,
              getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[value.toInt()], style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        barGroups: List.generate(7, (i) {
          final value = weekdayRates[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 20,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.cyan.shade400,
                    Color.lerp(Colors.cyan.shade700, Colors.green.shade400, value)!,
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MonthlyRateChart extends StatelessWidget {
  const _MonthlyRateChart({required this.rates, required this.color});

  final List<double> rates;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final now = DateTime.now();

    return BarChart(
      BarChartData(
        maxY: 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 0.25,
              getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(months[value.toInt()], style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: rates[i],
                width: 16,
                color: i < now.month ? color : color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

List<bool> _boolSeriesForActivity(WidgetRef ref, int activityId, int days) {
  final map = ref.watch(completionsForActivityProvider(activityId)).valueOrNull ?? [];
  final keys = map.map((c) => c.dateKey).toSet();
  final end = PaceDateUtils.toDateOnly(DateTime.now());
  final start = end.subtract(Duration(days: days - 1));
  return PaceDateUtils.dateRange(start, end)
      .map((d) => keys.contains(PaceDateUtils.toDateKey(d)))
      .toList();
}

List<int> _buildCompletionCountSeries(WidgetRef ref, List<Activity> activities, int days) {
  final seriesByActivity = <List<bool>>[];
  for (final activity in activities) {
    seriesByActivity.add(_boolSeriesForActivity(ref, activity.id, days));
  }

  return List.generate(days, (dayIndex) {
    var count = 0;
    for (final s in seriesByActivity) {
      if (dayIndex < s.length && s[dayIndex]) count++;
    }
    return count;
  });
}

List<double> _buildDailyCompletionRateSeries(WidgetRef ref, List<Activity> activities, int days) {
  if (activities.isEmpty) return List.filled(days, 0.0);
  final counts = _buildCompletionCountSeries(ref, activities, days);
  return counts.map((c) => c / activities.length).toList();
}

List<double> _buildWeekdayRates(WidgetRef ref, List<Activity> activities, int days) {
  if (activities.isEmpty) return List.filled(7, 0.0);

  final end = PaceDateUtils.toDateOnly(DateTime.now());
  final start = end.subtract(Duration(days: days - 1));
  final range = PaceDateUtils.dateRange(start, end);

  final byActivity = {
    for (final a in activities) a.id: _boolSeriesForActivity(ref, a.id, days),
  };

  final totals = List<int>.filled(7, 0);
  final done = List<int>.filled(7, 0);

  for (var i = 0; i < range.length; i++) {
    final weekdayIndex = range[i].weekday - 1;
    totals[weekdayIndex] += activities.length;
    for (final a in activities) {
      final series = byActivity[a.id]!;
      if (series[i]) done[weekdayIndex]++;
    }
  }

  return List.generate(7, (i) => totals[i] == 0 ? 0.0 : done[i] / totals[i]);
}

List<double> _buildMonthlyRateForSingleActivity(Set<String> dateKeys) {
  final now = DateTime.now();
  return List.generate(12, (monthIdx) {
    final month = monthIdx + 1;
    final daysInMonth = PaceDateUtils.daysInMonth(DateTime(now.year, month, 1));
    final count = dateKeys.where((k) {
      final d = DateTime.parse(k);
      return d.year == now.year && d.month == month;
    }).length;
    return count / daysInMonth;
  });
}

List<double> _movingAverage(List<double> values, int window) {
  if (values.isEmpty || window <= 1) return values;
  final result = <double>[];
  for (var i = 0; i < values.length; i++) {
    final start = math.max(0, i - window + 1);
    final slice = values.sublist(start, i + 1);
    result.add(slice.reduce((a, b) => a + b) / slice.length);
  }
  return result;
}
