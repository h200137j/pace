import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/badge_catalog.dart';
import '../../../data/models/badge_unlock.dart';
import '../../../providers/gamification_provider.dart';

class BadgesScreen extends ConsumerStatefulWidget {
  const BadgesScreen({super.key});

  @override
  ConsumerState<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends ConsumerState<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    _ensureBadgesInitialized();
  }

  Future<void> _ensureBadgesInitialized() async {
    final repo = ref.read(gamificationRepositoryProvider);
    await repo.ensureAllBadgesExist();
  }

  @override
  Widget build(BuildContext context) {
    final badgesAsync = ref.watch(badgeUnlocksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievement Badges')),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load badges: $e')),
        data: (badges) {
          // Create a map of badgeKey -> badgeDefinition for quick lookup
          final catalogMap = {
            for (final def in BadgeCatalog.all) def.key: def
          };

          // Separate unlocked and locked badges
          final unlocked = <BadgeUnlock>[];
          final locked = <BadgeUnlock>[];

          for (final badge in badges) {
            if (badge.unlockedAt != null) {
              unlocked.add(badge);
            } else {
              locked.add(badge);
            }
          }

          // Sort unlocked by unlock date (earliest first)
          unlocked.sort((a, b) {
            final dateA = a.unlockedAt ?? DateTime.now();
            final dateB = b.unlockedAt ?? DateTime.now();
            return dateA.compareTo(dateB);
          });

          // Sort locked by progress percentage (descending - closest to unlock first)
          locked.sort((a, b) {
            final progressA = a.target > 0 ? (a.progress / a.target) : 0.0;
            final progressB = b.target > 0 ? (b.progress / b.target) : 0.0;
            return progressB.compareTo(progressA); // Descending
          });

          // Combine unlocked first, then locked
          final sortedBadges = [...unlocked, ...locked];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: sortedBadges.length,
            itemBuilder: (context, index) {
              final badge = sortedBadges[index];
              final def = catalogMap[badge.badgeKey];
              final unlocked = badge.unlockedAt != null;
              final progressPercent = badge.target > 0 
                  ? (badge.progress / badge.target * 100).clamp(0, 100).toInt()
                  : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: unlocked
                      ? Colors.amber.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: unlocked
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              unlocked
                                  ? Icons.verified_rounded
                                  : Icons.lock_outline_rounded,
                              color: unlocked
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    def?.title ?? badge.badgeKey,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (def != null)
                                    Text(
                                      def.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            if (!unlocked)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '$progressPercent%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        if (!unlocked) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                Colors.blue.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progress: ${badge.progress}/${badge.target}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Unlocked on ${badge.unlockedAt!.toLocal().toString().split('.')[0]}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
