import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../core/services/photo_service.dart';
import '../../widgets/contribution_grid.dart';
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

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(activity.colorValue);
    final icon = IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons');

    final streak = ref.watch(streakProvider(activity.id));
    // For heatmap & calendar
    final completionsAsync =
        ref.watch(completionsForActivityProvider(activity.id));
    final dateKeys = completionsAsync.valueOrNull
            ?.map((c) => c.dateKey)
            .toSet() ??
        {};

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
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CreateActivitySheet(existing: activity),
                ),
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
                    color: color.withOpacity(0.15),
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
                  _SectionTitle('52-Week Overview'),
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

          // ── 30-Day Line Chart ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Last 30 Days'),
                  const SizedBox(height: 12),
                  _LineChart30Days(activityId: activity.id, color: color),
                ],
              ),
            ),
          ),

          // ── Yearly Calendar ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _SectionTitle('Activity Calendar'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Generate months backwards from today
                final monthDate = DateTime(
                  DateTime.now().year,
                  DateTime.now().month - index,
                  1,
                );
                
                // Limit to 12 months for "the year"
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
              onPressed: () => ctx.pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => ctx.pop(true),
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
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            border: Border.all(color: color.withOpacity(0.3)),
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

    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceSheet(color: Color(activity.colorValue)),
    );

    if (source == null) return;

    final file = await PhotoService.instance.pickImage(fromCamera: source);
    if (file == null) return;

    final savedPath = await PhotoService.instance.saveImageToAppStorage(
      file,
      dateKey,
      activity.id,
    );

    await notifier.toggle(activity.id, dateKey, photoPath: savedPath);
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withOpacity(0.2)),
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

class _LineChart30Days extends ConsumerWidget {
  const _LineChart30Days({required this.activityId, required this.color});

  final int activityId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(recentDailyProvider(
      (activityId: activityId, days: 30),
    ));

    final spots = data.values.toList().asMap().entries.map((MapEntry<int, bool> e) {
      return FlSpot(e.key.toDouble(), e.value ? 1.0 : 0.0);
    }).toList();

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        s.y == 1 ? '✓' : '✗',
                        TextStyle(
                            color: color, fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: spot.y == 1 ? color : Colors.transparent,
                  strokeColor: color,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
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
                 await notifier.toggle(activity.id, key);
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

    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PhotoSourceSheet(color: Color(activity.colorValue)),
    );

    if (source == null) return;

    final file = await PhotoService.instance.pickImage(fromCamera: source);
    if (file == null) return;

    final savedPath = await PhotoService.instance.saveImageToAppStorage(
      file,
      dateKey,
      activity.id,
    );

    await notifier.toggle(activity.id, dateKey, photoPath: savedPath);
  }
}
