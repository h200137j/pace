import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../providers/activity_provider.dart';
import '../../../core/services/update_service.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/update_sheet.dart';
import '../create/create_activity_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
  }

  Future<void> _checkForUpdates() async {
    final info = await UpdateService.checkForUpdates();
    if (info != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => UpdateSheet(updateInfo: info),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(activitiesProvider);
    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final dateLabel = DateFormat('EEEE, MMM d').format(now);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Large App Bar ────────────────────────────────────────────────
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 32,
                      width: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pace',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    dateLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────────────
          activitiesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (activities) {
              if (activities.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: 'Start your first streak',
                    message:
                        'Create a habit, challenge, or focus session\nand track it every day.',
                    action: () => _openCreate(context),
                    actionLabel: 'Create Activity',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i == 0) {
                        return _SectionHeader(
                          label: "Today's Activities",
                          icon: Icons.today_rounded,
                          count: activities.length,
                        );
                      }
                      final activity = activities[i - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActivityCard(
                          activity: activity,
                          onTap: () => context.push('/activity/${activity.id}'),
                        ),
                      );
                    },
                    childCount: activities.length + 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Activity'),
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateActivitySheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.count,
  });

  final String label;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
