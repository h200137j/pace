import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/gamification_service.dart';
import '../data/models/badge_unlock.dart';
import '../data/models/gamification_profile.dart';
import '../data/models/trophy_unlock.dart';
import '../data/models/xp_event.dart';
import '../data/repositories/activity_repository.dart';
import '../data/repositories/gamification_repository.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepository(),
);

final gamificationServiceProvider = Provider<GamificationService>(
  (ref) => GamificationService(
    activityRepository: ActivityRepository(),
    gamificationRepository: ref.watch(gamificationRepositoryProvider),
  ),
);

final gamificationProfileProvider = StreamProvider<GamificationProfile?>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchProfile(),
);

final badgeUnlocksProvider = StreamProvider<List<BadgeUnlock>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchBadges(),
);

final trophyUnlocksProvider = StreamProvider<List<TrophyUnlock>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchTrophies(),
);

final xpEventsProvider = StreamProvider<List<XpEvent>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchAllEvents(),
);

final challengeXpProvider = Provider.family<int, int>((ref, activityId) {
  final events = ref.watch(xpEventsProvider).valueOrNull ?? const <XpEvent>[];
  final prefix = '$activityId:';
  return events
      .where((e) => e.sourceType == 'completion' && e.sourceId.startsWith(prefix))
      .fold<int>(0, (sum, e) => sum + e.totalAwardedXp);
});
