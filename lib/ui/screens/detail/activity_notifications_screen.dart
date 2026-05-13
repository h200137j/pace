import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/activity_notification_store.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/activity.dart';
import '../../../providers/activity_provider.dart';
import '../../widgets/app_snackbar.dart';

class ActivityNotificationsScreen extends ConsumerWidget {
  const ActivityNotificationsScreen({super.key, required this.activityId});
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
          return const Scaffold(
              body: Center(child: Text('Activity not found')));
        }
        return _NotifBody(activity: activity);
      },
    );
  }
}

class _NotifBody extends StatefulWidget {
  const _NotifBody({required this.activity});
  final Activity activity;

  @override
  State<_NotifBody> createState() => _NotifBodyState();
}

class _NotifBodyState extends State<_NotifBody> {
  List<TimeOfDay> _slots = [];
  bool _loading = true;

  Activity get activity => widget.activity;
  Color get color => Color(activity.colorValue);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final slots = await ActivityNotificationStore.loadSlots(activity.id);
    if (mounted) setState(() { _slots = slots; _loading = false; });
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _persist() async {
    await ActivityNotificationStore.saveSlots(activity.id, _slots);
    if (_slots.isEmpty) {
      await NotificationService.instance.cancelActivitySlots(activity.id);
    } else {
      await NotificationService.instance.scheduleActivitySlots(
        activity.id, activity.name, activity.requiresPhoto, _slots);
    }
  }

  Future<void> _addSlot() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: color,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    if (_slots.any((s) => s.hour == picked.hour && s.minute == picked.minute)) {
      if (mounted) showAppSnackBar(context, 'That time is already added.');
      return;
    }

    setState(() {
      _slots = [..._slots, picked]
        ..sort((a, b) => a.hour != b.hour
            ? a.hour.compareTo(b.hour)
            : a.minute.compareTo(b.minute));
    });

    await _persist();
    if (mounted) {
      showAppSnackBar(context, '🔔 Reminder set for ${_formatTime(picked)}');
    }
  }

  Future<void> _removeSlot(int index) async {
    setState(() {
      final updated = List<TimeOfDay>.from(_slots);
      updated.removeAt(index);
      _slots = updated;
    });
    await _persist();
    if (mounted) showAppSnackBar(context, 'Reminder removed.');
  }

  Future<void> _clearAll() async {
    setState(() => _slots = []);
    await _persist();
    if (mounted) showAppSnackBar(context, 'All reminders cleared.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverAppBar.medium(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconData(activity.iconCodePoint,
                        fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Reminders',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // ── Info card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _InfoCard(color: color, activity: activity),
              ),
            ),

            // ── Slots list ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    Text(
                      'SCHEDULED TIMES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (_slots.isNotEmpty)
                      TextButton(
                        onPressed: _clearAll,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Clear all'),
                      ),
                  ],
                ),
              ),
            ),

            if (_slots.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _EmptySlots(color: color),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: _SlotCard(
                      time: _slots[i],
                      color: color,
                      index: i,
                      onDelete: () => _removeSlot(i),
                    ),
                  ),
                  childCount: _slots.length,
                ),
              ),

            // ── Add button ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _AddButton(color: color, onTap: _addSlot),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  'Notifications only fire if the activity hasn\'t been completed for that day.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.3),
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.color, required this.activity});
  final Color color;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: color.withValues(alpha: 0.18), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Daily reminders — skipped when already completed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.time,
    required this.color,
    required this.index,
    required this.onDelete,
  });
  final TimeOfDay time;
  final Color color;
  final int index;
  final VoidCallback onDelete;

  String _format(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.08), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.alarm_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _format(time),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.3), size: 22),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlots extends StatelessWidget {
  const _EmptySlots({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                color: Colors.white.withValues(alpha: 0.2), size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'No reminders set',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a time below to get daily nudges',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_alarm_rounded, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Reminder Time',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
