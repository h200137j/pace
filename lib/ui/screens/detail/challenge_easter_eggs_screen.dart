import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/challenge_easter_egg_service.dart';
import '../../../providers/activity_provider.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/gamification_settings_provider.dart';

class ChallengeEasterEggsScreen extends ConsumerStatefulWidget {
  const ChallengeEasterEggsScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<ChallengeEasterEggsScreen> createState() =>
      _ChallengeEasterEggsScreenState();
}

class _ChallengeEasterEggsScreenState
    extends ConsumerState<ChallengeEasterEggsScreen> {
  final Set<int> _knownUnlocked = <int>{};
  final Set<int> _freshUnlocked = <int>{};

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityByIdProvider(widget.activityId));

    return activityAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (activity) {
        if (activity == null) {
          return const Scaffold(body: Center(child: Text('Challenge not found')));
        }

        if (!EliteChallengeEasterEggService.isEligible(activity)) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
              title: const Text('Easter Eggs'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Easter eggs are available for elite year-long challenges only.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final completions =
            ref.watch(completionsForActivityProvider(activity.id)).valueOrNull ??
                const [];
        final dateKeys = completions.map((c) => c.dateKey).toSet();
        final progress = EliteChallengeEasterEggService.evaluate(
          activity: activity,
          completionDateKeys: dateKeys,
        );
        final currentUnlocked = progress.months
            .where((m) => m.unlocked)
            .map((m) => m.monthIndex)
            .toSet();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          if (_knownUnlocked.isEmpty) {
            _knownUnlocked.addAll(currentUnlocked);
            return;
          }

          final newlyUnlocked = currentUnlocked.difference(_knownUnlocked);
          if (newlyUnlocked.isEmpty) return;

          setState(() {
            _knownUnlocked.addAll(newlyUnlocked);
            _freshUnlocked.addAll(newlyUnlocked);
          });

          for (final monthIndex in newlyUnlocked) {
            Future.delayed(const Duration(milliseconds: 1700), () {
              if (!mounted) return;
              if (!_freshUnlocked.contains(monthIndex)) return;
              setState(() {
                _freshUnlocked.remove(monthIndex);
              });
            });
          }
        });

        final hintEnabled = ref.watch(gamificationSettingsProvider).showEasterEggHints;
        final currentHint = hintEnabled
            ? EliteChallengeEasterEggService.monthlyHint(
                activity: activity,
                completionDateKeys: dateKeys,
              )
            : null;

        final color = Color(activity.colorValue);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text('${activity.name} Easter Eggs'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _EggOverviewCard(
                color: color,
                unlocked: progress.unlockedCount,
                target: progress.targetCount,
                metaUnlocked: progress.metaTrophyUnlocked,
              ),
              if (currentHint != null && !currentHint.eggAlreadyFound) ...[
                const SizedBox(height: 12),
                _HintCard(color: color, message: currentHint.message),
              ],
              const SizedBox(height: 16),
              for (final month in progress.months)
                _MonthEggCard(
                  month: month,
                  revealDay: month.unlocked,
                  hintEnabled: hintEnabled,
                  animateReveal: _freshUnlocked.contains(month.monthIndex),
                  isNewlyUnlocked: _freshUnlocked.contains(month.monthIndex),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EggOverviewCard extends StatelessWidget {
  const _EggOverviewCard({
    required this.color,
    required this.unlocked,
    required this.target,
    required this.metaUnlocked,
  });

  final Color color;
  final int unlocked;
  final int target;
  final bool metaUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$unlocked/$target eggs found',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            metaUnlocked
                ? 'Meta Trophy Unlocked: Celestial Vault'
                : 'Find all 12 monthly eggs to unlock Celestial Vault.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.color, required this.message});

  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.teal.withValues(alpha: 0.12),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          const Icon(Icons.radar_rounded, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthEggCard extends StatelessWidget {
  const _MonthEggCard({
    required this.month,
    required this.revealDay,
    required this.hintEnabled,
    required this.animateReveal,
    required this.isNewlyUnlocked,
  });

  final EasterEggMonthUnlock month;
  final bool revealDay;
  final bool hintEnabled;
  final bool animateReveal;
  final bool isNewlyUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = month.unlocked;
    final artwork = _eggArtworkByMonth[month.monthIndex % _eggArtworkByMonth.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: unlocked
              ? artwork.accent.withValues(alpha: 0.45)
              : Colors.grey.withValues(alpha: 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EggArtworkTile(
                  artwork: artwork,
                  unlocked: unlocked,
                  animateReveal: animateReveal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        month.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artwork.flavor,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: artwork.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isNewlyUnlocked) ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: artwork.accent.withValues(alpha: 0.22),
                            border: Border.all(
                              color: artwork.accent.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Text(
                            'NEW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: artwork.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      unlocked ? 'Found' : 'Locked',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            unlocked ? artwork.accent : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                      size: 16,
                      color:
                          unlocked ? artwork.accent : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              revealDay
                  ? 'Secret day: ${month.eggDate.year}-${month.eggDate.month.toString().padLeft(2, '0')}-${month.eggDate.day.toString().padLeft(2, '0')}'
                  : hintEnabled
                      ? 'Hint: Keep completing this month. Radar hints appear after day 20.'
                      : 'Complete the hidden day to reveal this egg.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EggArtwork {
  const _EggArtwork({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.icon,
    required this.flavor,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final IconData icon;
  final String flavor;
}

const List<_EggArtwork> _eggArtworkByMonth = [
  _EggArtwork(
    primary: Color(0xFF5B86E5),
    secondary: Color(0xFF36D1DC),
    accent: Color(0xFFBFE8FF),
    icon: Icons.ac_unit_rounded,
    flavor: 'WINTER GLACIER',
  ),
  _EggArtwork(
    primary: Color(0xFFFC4A1A),
    secondary: Color(0xFFF7B733),
    accent: Color(0xFFFFD58E),
    icon: Icons.wb_sunny_rounded,
    flavor: 'SUNRISE EMBER',
  ),
  _EggArtwork(
    primary: Color(0xFF11998E),
    secondary: Color(0xFF38EF7D),
    accent: Color(0xFFB9FFD6),
    icon: Icons.eco_rounded,
    flavor: 'VERDANT GLOW',
  ),
  _EggArtwork(
    primary: Color(0xFF396AFD),
    secondary: Color(0xFF2948FF),
    accent: Color(0xFFA9B8FF),
    icon: Icons.water_drop_rounded,
    flavor: 'RAIN SIGNAL',
  ),
  _EggArtwork(
    primary: Color(0xFFDD5E89),
    secondary: Color(0xFFF7BB97),
    accent: Color(0xFFFFD3E2),
    icon: Icons.local_florist_rounded,
    flavor: 'BLOSSOM ARC',
  ),
  _EggArtwork(
    primary: Color(0xFFf46b45),
    secondary: Color(0xFFeea849),
    accent: Color(0xFFFFD7A5),
    icon: Icons.waves_rounded,
    flavor: 'SUMMER SURGE',
  ),
  _EggArtwork(
    primary: Color(0xFF7F00FF),
    secondary: Color(0xFFE100FF),
    accent: Color(0xFFEFC3FF),
    icon: Icons.auto_awesome_rounded,
    flavor: 'MIDSKY AURA',
  ),
  _EggArtwork(
    primary: Color(0xFFc79081),
    secondary: Color(0xFFdfa579),
    accent: Color(0xFFFFE0C3),
    icon: Icons.grass_rounded,
    flavor: 'HARVEST DUST',
  ),
  _EggArtwork(
    primary: Color(0xFF00B4DB),
    secondary: Color(0xFF0083B0),
    accent: Color(0xFF9EE8FF),
    icon: Icons.change_history_rounded,
    flavor: 'EQUINOX SPIRE',
  ),
  _EggArtwork(
    primary: Color(0xFFED6A5A),
    secondary: Color(0xFFF4F1BB),
    accent: Color(0xFFFFE6A5),
    icon: Icons.bolt_rounded,
    flavor: 'AMBER CIRCUIT',
  ),
  _EggArtwork(
    primary: Color(0xFF232526),
    secondary: Color(0xFF414345),
    accent: Color(0xFFC1C5C7),
    icon: Icons.nightlight_round,
    flavor: 'NIGHT GLASS',
  ),
  _EggArtwork(
    primary: Color(0xFF1A2A6C),
    secondary: Color(0xFFB21F1F),
    accent: Color(0xFFFFB6B6),
    icon: Icons.rocket_launch_rounded,
    flavor: 'AURORA CORE',
  ),
];

class _EggArtworkTile extends StatelessWidget {
  const _EggArtworkTile({
    required this.artwork,
    required this.unlocked,
    required this.animateReveal,
  });

  final _EggArtwork artwork;
  final bool unlocked;
  final bool animateReveal;

  @override
  Widget build(BuildContext context) {
    final fg = unlocked ? artwork.accent : Colors.white.withValues(alpha: 0.55);

    final baseTile = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [artwork.primary, artwork.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: artwork.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              unlocked ? artwork.icon : Icons.egg_alt_rounded,
              color: fg,
              size: 28,
            ),
          ),
        ],
      ),
    );

    final animatedTile = unlocked && animateReveal
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            child: baseTile,
            builder: (context, value, child) {
              final scale = 0.88 + (0.12 * value);
              final glow = 0.22 + (0.28 * (1.0 - value));

              return Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: artwork.accent.withValues(alpha: glow),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
          )
        : baseTile;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: unlocked ? 1.0 : 0.45,
      child: animatedTile,
    );
  }
}
