import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../widgets/contribution_grid.dart';

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
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar.medium(
            title: Text(
              'Analytics',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
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
        ],
        body: activitiesAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
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

// ── Week Tab ───────────────────────────────────────────────────────────────

class _WeekTab extends ConsumerWidget {
  const _WeekTab({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Last 7 Days',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: _WeekBarChart(activities: activities, ref: ref),
        ),
        const SizedBox(height: 24),
        ...activities.map((a) => _ActivityWeekRow(activity: a)),
      ],
    );
  }
}

class _WeekBarChart extends ConsumerWidget {
  const _WeekBarChart({required this.activities, required this.ref});

  final List<Activity> activities;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Collect weekly data per activity
    final allData = <int, List<double>>{};
    for (final a in activities) {
      allData[a.id] = r.watch(weeklyRatesProvider(a.id));
    }

    if (allData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return BarChart(
      BarChartData(
        maxY: 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(dayLabels[v.toInt()],
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
        ),
        barGroups: List.generate(7, (day) {
          return BarChartGroupData(
            x: day,
            barRods: activities.asMap().entries.map((e) {
              final data = allData[e.value.id];
              final val = data != null && data.length > day ? data[day] : 0.0;
              return BarChartRodData(
                toY: val,
                color: Color(e.value.colorValue),
                width: 6,
                borderRadius: BorderRadius.circular(4),
              );
            }).toList(),
            barsSpace: 3,
          );
        }),
      ),
    );
  }
}

class _ActivityWeekRow extends ConsumerWidget {
  const _ActivityWeekRow({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(activity.colorValue);
    final rates = ref.watch(weeklyRatesProvider(activity.id));
    final done = rates.where((r) => r > 0).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(
              IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: done / 7,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$done/7',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Month Tab ──────────────────────────────────────────────────────────────

class _MonthTab extends ConsumerWidget {
  const _MonthTab({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Last 30 Days',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: _Month30Chart(activities: activities),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: activities.map((a) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(a.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(a.name, style: theme.textTheme.labelSmall),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Month30Chart extends ConsumerWidget {
  const _Month30Chart({required this.activities});
  final List<Activity> activities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bars = <LineChartBarData>[];

    for (final a in activities) {
      final data = ref.watch(recentDailyProvider((activityId: a.id, days: 30)));

      final spots = data.values.toList().asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value ? 1.0 : 0.0);
      }).toList();

      final color = Color(a.colorValue);
      bars.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.07),
        ),
      ));
    }

    if (bars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: bars,
      ),
    );
  }
}

// ── Year Tab ───────────────────────────────────────────────────────────────

class _YearTab extends ConsumerStatefulWidget {
  const _YearTab({required this.activities});
  final List<Activity> activities;

  @override
  ConsumerState<_YearTab> createState() => _YearTabState();
}

class _YearTabState extends ConsumerState<_YearTab> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.activities.isEmpty) {
      return const Center(child: Text('No activities yet.'));
    }

    final selected = widget.activities[_selectedIndex];
    final color = Color(selected.colorValue);

    final completionsAsync =
        ref.watch(completionsForActivityProvider(selected.id));
    final dateKeys = completionsAsync.valueOrNull
            ?.map((c) => c.dateKey)
            .toSet() ??
        {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Activity selector chips
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
        const SizedBox(height: 20),
        Text('52-Week Heatmap',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ContributionGrid(
          dateKeys: dateKeys,
          color: color,
          startDate: DateTime(DateTime.now().year, 1, 1),
          endDate: DateTime(DateTime.now().year, 12, 31),
        ),
        const SizedBox(height: 24),
        // Monthly bar chart for the year
        Text('Monthly Completions',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child:
              _YearlyBarChart(activityId: selected.id, color: color),
        ),
      ],
    );
  }
}

class _YearlyBarChart extends ConsumerWidget {
  const _YearlyBarChart({required this.activityId, required this.color});

  final int activityId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionsAsync =
        ref.watch(completionsForActivityProvider(activityId));
    final completions = completionsAsync.valueOrNull ?? [];

    final now = DateTime.now();
    final monthlyCounts = List.filled(12, 0);
    for (final c in completions) {
      final date = DateTime.parse(c.dateKey);
      if (date.year == now.year) {
        monthlyCounts[date.month - 1]++;
      }
    }

    return BarChart(
      BarChartData(
        maxY: (monthlyCounts.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const months = [
                  'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(months[v.toInt()],
                      style: Theme.of(context).textTheme.labelSmall),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: monthlyCounts[i].toDouble(),
                color: i < now.month ? color : color.withValues(alpha: 0.25),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
