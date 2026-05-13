import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/notification_service.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/activity.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/completion_provider.dart';
import '../../providers/ui_state_provider.dart';
import 'progress_ring.dart';
import 'streak_badge.dart';
import '../../core/services/photo_service.dart';
import 'day_completion_toast.dart';
import 'note_sheet.dart';

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
    final color = Color(activity.colorValue);
    final icon = IconData(activity.iconCodePoint, fontFamily: 'MaterialIcons');

    final target = activity.dailyCheckInTarget;
    final checkInCount = ref.watch(todayCheckInCountProvider(activity.id));
    final isDoneToday = checkInCount >= target;
    final streak = ref.watch(streakProvider(activity.id));
    final weeklyRates = ref.watch(weeklyRatesProvider(activity.id));

    final weeklyRate =
        weeklyRates.fold(0.0, (a, b) => a + b) / weeklyRates.length;

    final typeLabel = switch (activity.type) {
      ActivityType.challenge => 'Challenge',
      ActivityType.task => 'Task',
      ActivityType.focus => 'Focus',
    };

    final difficultyLabel = switch (activity.difficulty) {
      ActivityDifficulty.easy => null,
      ActivityDifficulty.medium => null,
      ActivityDifficulty.hard => 'Hard',
      ActivityDifficulty.elite => 'Elite',
    };

    // Challenge time progress
    final isChallenge = activity.type == ActivityType.challenge;
    final today = PaceDateUtils.toDateOnly(DateTime.now());
    final challengeEnd = activity.endDate != null
        ? PaceDateUtils.toDateOnly(activity.endDate!)
        : null;
    final challengeStart = activity.startDate != null
        ? PaceDateUtils.toDateOnly(activity.startDate!)
        : null;
    double challengeTimeProgress = 0;
    if (isChallenge && challengeStart != null && challengeEnd != null) {
      final total = challengeEnd.difference(challengeStart).inDays;
      final elapsed = today.difference(challengeStart).inDays.clamp(0, total);
      challengeTimeProgress = total > 0 ? elapsed / total : 1.0;
    }

    // Contextual stat
    String? contextStat;
    if (isChallenge && challengeEnd != null) {
      final daysLeft = challengeEnd.difference(today).inDays;
      contextStat = daysLeft > 0 ? '${daysLeft}d left' : 'Complete';
    } else {
      if (streak.longest > 0) contextStat = 'best ${streak.longest}';
    }

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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: icon + name + type chips + ring ──────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: color.withOpacity(0.2), width: 1),
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
                                const SizedBox(height: 5),
                                // ── Type + difficulty + photo chips ──────────
                                Wrap(
                                  spacing: 5,
                                  runSpacing: 4,
                                  children: [
                                    _Chip(
                                      label: typeLabel.toUpperCase(),
                                      color: color,
                                    ),
                                    if (difficultyLabel != null)
                                      _Chip(
                                        label: difficultyLabel.toUpperCase(),
                                        color: difficultyLabel == 'Elite'
                                            ? const Color(0xFFAB47BC)
                                            : Colors.orange,
                                      ),
                                    if (activity.requiresPhoto)
                                      _Chip(
                                        label: '📷',
                                        color: color,
                                        isIcon: true,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (showCheckIn) ...[
                            const SizedBox(width: 8),
                            _CheckInButton(
                              activity: activity,
                              checkInCount: checkInCount,
                              color: color,
                              weeklyRate: weeklyRate,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Stats + week dots ──────────────────────────────────
                      Row(
                        children: [
                          // Streak
                          _StatPill(
                            icon: streak.current > 0 ? '🔥' : '○',
                            value: '${streak.current}',
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          // Total completions
                          _StatPill(
                            icon: '✓',
                            value: '${streak.totalCompletions}',
                            color: color,
                          ),
                          if (contextStat != null) ...[
                            const SizedBox(width: 8),
                            _StatPill(
                              value: contextStat,
                              color: color,
                            ),
                          ],
                          const Spacer(),
                          _WeekDots(weeklyRates: weeklyRates, color: color),
                        ],
                      ),

                      // ── Challenge time bar ────────────────────────────────
                      if (isChallenge && challengeStart != null &&
                          challengeEnd != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: challengeTimeProgress,
                            minHeight: 3,
                            backgroundColor: color.withOpacity(0.1),
                            valueColor:
                                AlwaysStoppedAnimation(color.withOpacity(0.6)),
                          ),
                        ),
                      ],
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
    required this.checkInCount,
    required this.color,
    required this.weeklyRate,
  });

  final Activity activity;
  final int checkInCount;
  final Color color;
  final double weeklyRate;

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(completionNotifierProvider.notifier);
    final dateKey = PaceDateUtils.todayKey();
    final target = activity.dailyCheckInTarget;

    // Photo prompt only on the very first check-in of the day
    if (activity.requiresPhoto && checkInCount == 0) {
      ref.read(createSheetOpenProvider.notifier).state = true;
      final source = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PhotoSourceSheet(color: color),
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

      final result = await notifier.checkIn(activity.id, dateKey, target, photoPath: savedPath);
      if (!context.mounted || result == null) return;
      NotificationService.instance.onActivityCompletedToday(
          activity.id, activity.name, activity.requiresPhoto, target);
      await showAndSaveNote(context, ref,
          activityId: activity.id, dateKey: dateKey, color: color);
      if (!context.mounted) return;
      await showDayCompletionToast(context, ref, result, activity: activity, dateKey: dateKey);
    } else {
      final result = await notifier.checkIn(activity.id, dateKey, target);
      if (!context.mounted || result == null) return;
      NotificationService.instance.onActivityCompletedToday(
          activity.id, activity.name, activity.requiresPhoto, target);
      await showDayCompletionToast(context, ref, result, activity: activity, dateKey: dateKey);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = activity.dailyCheckInTarget;
    final isDone = checkInCount >= target;
    final isPartial = !isDone && checkInCount > 0;

    final ringProgress = isDone
        ? 1.0
        : isPartial
            ? checkInCount / target
            : weeklyRate;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(context, ref),
      child: ScaleTransition(
        scale: AlwaysStoppedAnimation(isDone ? 1.05 : 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: ProgressRing(
            progress: ringProgress,
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
                    : isPartial
                        ? Text(
                            '$checkInCount/$target',
                            key: ValueKey('partial_$checkInCount'),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          )
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.isIcon = false});
  final String label;
  final Color color;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isIcon ? 6 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: color.withValues(alpha: 0.85),
          fontWeight: FontWeight.w800,
          letterSpacing: isIcon ? 0 : 0.4,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({this.icon, required this.value, required this.color});
  final String? icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
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
