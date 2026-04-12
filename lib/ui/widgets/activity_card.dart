import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/streak_calculator.dart';
import '../../data/models/activity.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/completion_provider.dart';
import 'progress_ring.dart';
import 'streak_badge.dart';
import '../../core/services/photo_service.dart';

class ActivityCard extends ConsumerWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    this.showCheckIn = true,
  });

  final Activity activity;
  final VoidCallback onTap;
  final bool showCheckIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(activity.colorValue);
    final icon = IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons');

    final isDoneToday = ref.watch(todayDoneProvider(activity.id));
    final streak = ref.watch(streakProvider(activity.id));
    final weeklyRates = ref.watch(weeklyRatesProvider(activity.id));

    final weeklyRate =
        weeklyRates.fold(0.0, (a, b) => a + b) / weeklyRates.length;

    final typeLabel = switch (activity.type) {
      ActivityType.challenge => 'Challenge',
      ActivityType.task => 'Task',
      ActivityType.focus => 'Focus',
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isDoneToday ? 0.22 : 0.10),
              color.withOpacity(isDoneToday ? 0.10 : 0.04),
            ],
          ),
          border: Border.all(
          color: isDoneToday ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.15),
          width: 1.5,
        ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            typeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress ring + check button
                  if (showCheckIn)
                    _CheckInButton(
                      activity: activity,
                      isDone: isDoneToday,
                      color: color,
                      weeklyRate: weeklyRate,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Streak badge + mini week dots
              Row(
                children: [
                  StreakBadge(result: streak, compact: true),
                  const Spacer(),
                  _WeekDots(weeklyRates: weeklyRates, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInButton extends ConsumerWidget {
  const _CheckInButton({
    required this.activity,
    required this.isDone,
    required this.color,
    required this.weeklyRate,
  });

  final Activity activity;
  final bool isDone;
  final Color color;
  final double weeklyRate;

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(completionNotifierProvider.notifier);
    final dateKey = PaceDateUtils.todayKey();

    if (isDone) {
      // Toggle off
      await notifier.toggle(activity.id, dateKey);
      return;
    }

    if (activity.requiresPhoto) {
      // Show picking options
      final source = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PhotoSourceSheet(color: color),
      );

      if (source == null) return; // User cancelled

      final file = await PhotoService.instance.pickImage(fromCamera: source);
      if (file == null) return;

      final savedPath = await PhotoService.instance.saveImageToAppStorage(
        file,
        dateKey,
        activity.id,
      );

      await notifier.toggle(activity.id, dateKey, photoPath: savedPath);
    } else {
      await notifier.toggle(activity.id, dateKey);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(context, ref),
      child: ProgressRing(
        progress: isDone ? 1.0 : weeklyRate,
        color: color,
        size: 48,
        strokeWidth: 4,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isDone
              ? Icon(Icons.check_rounded,
                  key: const ValueKey('done'), color: color, size: 20)
              : Icon(Icons.radio_button_unchecked_rounded,
                  key: const ValueKey('undone'),
                  color: color.withOpacity(0.5),
                  size: 18),
        ),
      ),
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
          Text('Complete with Photo', style: theme.textTheme.titleMedium),
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

class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.weeklyRates, required this.color});

  final List<double> weeklyRates;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: List.generate(7, (i) {
        final done = weeklyRates.length > i && weeklyRates[i] > 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : color.withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                days[i],
                style: TextStyle(
                    fontSize: 7,
                    color: done ? color : color.withOpacity(0.3)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
