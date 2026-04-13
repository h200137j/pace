import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/activity.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/completion_provider.dart';
import '../../providers/ui_state_provider.dart';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: color.withOpacity(isDoneToday ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (isDoneToday)
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Glowing left border
                Positioned(
                  left: 0,
                  top: 20,
                  bottom: 20,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon circle with glass effect
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon, color: color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.95),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    typeLabel.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: color.withOpacity(0.8),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showCheckIn)
                            _CheckInButton(
                              activity: activity,
                              isDone: isDoneToday,
                              color: color,
                              weeklyRate: weeklyRate,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
              ],
            ),
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
      ref.read(createSheetOpenProvider.notifier).state = true;
      final source = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PhotoSourceSheet(color: color),
      );
      ref.read(createSheetOpenProvider.notifier).state = false;

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
      child: ScaleTransition(
        scale: AlwaysStoppedAnimation(isDone ? 1.05 : 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: ProgressRing(
            progress: isDone ? 1.0 : weeklyRate,
            color: color,
            size: 52,
            strokeWidth: 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? color.withOpacity(0.2) : Colors.transparent,
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: isDone
                    ? Icon(Icons.check_rounded,
                        key: const ValueKey('done'), color: color, size: 24)
                    : Icon(Icons.add_rounded,
                        key: const ValueKey('undone'),
                        color: color.withOpacity(0.6),
                        size: 20),
              ),
            ),
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : color.withOpacity(0.12),
                  boxShadow: done
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                  border: Border.all(
                    color: done ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                days[i],
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: done ? FontWeight.w800 : FontWeight.w500,
                  color: done ? color : Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
