import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/trophy_catalog.dart';
import '../../../data/models/trophy_unlock.dart';
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
    _ensureTrophiesInitialized();
  }

  Future<void> _ensureTrophiesInitialized() async {
    final repo = ref.read(gamificationRepositoryProvider);
    await repo.ensureAllTrophiesExist();
  }

  @override
  Widget build(BuildContext context) {
    final trophiesAsync = ref.watch(trophyUnlocksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trophies')),
      body: trophiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load trophies: $e')),
        data: (trophies) {
          // Create a map of trophyKey -> trophyDefinition for quick lookup
          final catalogMap = {
            for (final def in TrophyCatalog.all) def.key: def
          };

          // Separate unlocked and locked trophies
          final unlocked = <TrophyUnlock>[];
          final locked = <TrophyUnlock>[];

          for (final trophy in trophies) {
            if (trophy.unlockedAt != null) {
              unlocked.add(trophy);
            } else {
              locked.add(trophy);
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
          final sortedTrophies = [...unlocked, ...locked];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: sortedTrophies.length,
            itemBuilder: (context, index) {
              final trophy = sortedTrophies[index];
              final def = catalogMap[trophy.trophyKey];
              final unlocked = trophy.unlockedAt != null;
              final progressPercent = trophy.target > 0
                  ? (trophy.progress / trophy.target * 100).clamp(0, 100).toInt()
                  : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: unlocked
                      ? Colors.purple.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: unlocked
                          ? Colors.purple.withOpacity(0.3)
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
                                  ? Icons.emoji_events_rounded
                                  : Icons.emoji_events_outlined,
                              color: unlocked
                                  ? Colors.purple
                                  : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    def?.title ?? trophy.trophyKey,
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
                                  color: Colors.orange.withOpacity(0.15),
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
                                        color: Colors.orange,
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
                                Colors.orange.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progress: ${trophy.progress}/${trophy.target}',
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
                              'Unlocked on ${trophy.unlockedAt!.toLocal().toString().split('.')[0]}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.purple[700],
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
