import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/trophy_catalog.dart';
import '../../../providers/gamification_provider.dart';

class TrophiesScreen extends ConsumerStatefulWidget {
  const TrophiesScreen({super.key});

  @override
  ConsumerState<TrophiesScreen> createState() => _TrophiesScreenState();
}

class _TrophiesScreenState extends ConsumerState<TrophiesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(gamificationRepositoryProvider).ensureAllTrophiesExist();
  }

  @override
  Widget build(BuildContext context) {
    final trophiesAsync = ref.watch(trophyUnlocksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Trophies',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          trophiesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (unlockRecords) {
              final byKey = {
                for (final t in unlockRecords) t.trophyKey: t,
              };

              // Build from catalog order — orphaned old keys are excluded.
              final entries = TrophyCatalog.all.map((def) {
                final record = byKey[def.key];
                final isUnlocked = record?.unlockedAt != null;
                final progress = record?.progress ?? 0;
                return (def: def, isUnlocked: isUnlocked, progress: progress,
                    unlockedAt: record?.unlockedAt);
              }).toList()
                ..sort((a, b) {
                  if (a.isUnlocked != b.isUnlocked) {
                    return a.isUnlocked ? -1 : 1;
                  }
                  if (a.isUnlocked && b.isUnlocked) {
                    return (a.unlockedAt ?? DateTime(0))
                        .compareTo(b.unlockedAt ?? DateTime(0));
                  }
                  final pA = a.def.target > 0 ? a.progress / a.def.target : 0.0;
                  final pB = b.def.target > 0 ? b.progress / b.def.target : 0.0;
                  return pB.compareTo(pA);
                });

              final unlockedCount =
                  entries.where((e) => e.isUnlocked).length;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            '$unlockedCount / ${entries.length} unlocked',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        );
                      }
                      final e = entries[i - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TrophyCard(
                          def: e.def,
                          isUnlocked: e.isUnlocked,
                          progress: e.progress,
                          unlockedAt: e.unlockedAt,
                        ),
                      );
                    },
                    childCount: entries.length + 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrophyCard extends StatelessWidget {
  const _TrophyCard({
    required this.def,
    required this.isUnlocked,
    required this.progress,
    required this.unlockedAt,
  });

  final TrophyDefinition def;
  final bool isUnlocked;
  final int progress;
  final DateTime? unlockedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _metricColor(def.metric, def.target);
    final rate =
        def.target > 0 ? (progress / def.target).clamp(0.0, 1.0) : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? accentColor.withValues(alpha: 0.1)
            : const Color(0xFF13131E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? accentColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ────────────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? accentColor.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
            ),
            child: Icon(
              isUnlocked
                  ? Icons.emoji_events_rounded
                  : Icons.emoji_events_outlined,
              color: isUnlocked
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.2),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        def.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isUnlocked
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    // Metric chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _metricLabel(def.metric),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  def.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white
                        .withValues(alpha: isUnlocked ? 0.55 : 0.3),
                  ),
                ),
                const SizedBox(height: 10),

                if (isUnlocked && unlockedAt != null)
                  Text(
                    'Unlocked ${DateFormat('MMM d, yyyy').format(unlockedAt!.toLocal())}',
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation(
                          accentColor.withValues(alpha: 0.7)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_fmt(progress)} / ${_fmt(def.target)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

/// Color for a trophy based on its metric type.
Color _metricColor(TrophyMetric metric, int target) {
  if (metric == TrophyMetric.totalXp) {
    // Scale from amber → purple as target grows
    if (target >= 300000) return const Color(0xFFAB47BC);
    if (target >= 75000) return const Color(0xFF78D5F5);
    if (target >= 15000) return const Color(0xFFFFD700);
    return const Color(0xFFFFB300);
  }
  // Badge-count trophies: cyan
  return const Color(0xFF00F2FF);
}

String _metricLabel(TrophyMetric metric) => switch (metric) {
      TrophyMetric.totalXp => 'XP',
      TrophyMetric.unlockedBadges => 'BADGES',
    };

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
  return '$n';
}
