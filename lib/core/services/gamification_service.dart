import 'dart:developer' as developer;

import '../constants/badge_catalog.dart';
import '../constants/trophy_catalog.dart';
import 'challenge_reward_service.dart';
import '../../data/models/activity.dart';
import '../../data/models/gamification_profile.dart';
import '../../data/models/badge_unlock.dart';
import '../../data/models/trophy_unlock.dart';
import '../../data/models/xp_event.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../constants/xp_config.dart';
import '../utils/level_curve.dart';

class XpAwardOutcome {
  const XpAwardOutcome({
    required this.awardedXp,
    this.unlockedBadgeKeys = const [],
    this.unlockedTrophyKeys = const [],
  });

  final int awardedXp;
  final List<String> unlockedBadgeKeys;
  final List<String> unlockedTrophyKeys;

  bool get hasUnlocks =>
      unlockedBadgeKeys.isNotEmpty || unlockedTrophyKeys.isNotEmpty;
}

class GamificationService {
  GamificationService({
    required ActivityRepository activityRepository,
    required GamificationRepository gamificationRepository,
  })  : _activityRepository = activityRepository,
        _gamificationRepository = gamificationRepository;

  final ActivityRepository _activityRepository;
  final GamificationRepository _gamificationRepository;

  Future<XpAwardOutcome> awardCompletionXp({
    required int activityId,
    required String dateKey,
    required bool hasPhoto,
  }) async {
    final eventKey = 'completion:$activityId:$dateKey';
    final existingEvent = await _gamificationRepository.getEventByKey(eventKey);
    if (existingEvent != null) {
      return const XpAwardOutcome(awardedXp: 0);
    }

    final activity = await _activityRepository.findById(activityId);
    if (activity == null) {
      return const XpAwardOutcome(awardedXp: 0);
    }

    const baseXp = XpConfig.completionBaseXp;
    final bonusXp = hasPhoto ? XpConfig.photoBonusXp : 0;
    final multiplier = XpConfig.multiplierFor(activity.difficulty);
    final challengeMultiplier = activity.type == ActivityType.challenge
      ? ChallengeRewardService.challengeLengthMultiplier(
        activity.plannedDurationDays > 0
          ? activity.plannedDurationDays
          : ChallengeRewardService.buildProfile(
            activity: activity,
            completionCount: 0,
            photoCompletionCount: 0,
            currentStreak: 0,
            longestStreak: 0,
            challengeXp: 0,
            ).durationDays,
        )
      : 1.0;
    final totalAwardedXp =
      ((baseXp + bonusXp) * multiplier * challengeMultiplier).round();

    final profile = await _gamificationRepository.getOrCreateProfile();
    final badges = await _gamificationRepository.getAllBadges();
    final trophies = await _gamificationRepository.getAllTrophies();

    final unlockedBadgesBefore = badges
      .where((b) => b.unlockedAt != null)
      .map((b) => b.badgeKey)
      .toSet();
    final unlockedTrophiesBefore = trophies
      .where((t) => t.unlockedAt != null)
      .map((t) => t.trophyKey)
      .toSet();

    _updateProfile(profile, totalAwardedXp, hasPhoto: hasPhoto);
    _evaluateBadges(profile, badges);
    _evaluateTrophies(profile, badges, trophies);

    final xpEvent = XpEvent()
      ..eventKey = eventKey
      ..sourceType = 'completion'
      ..sourceId = '$activityId:$dateKey'
      ..baseXp = baseXp
      ..bonusXp = bonusXp
      ..multiplier = multiplier
      ..totalAwardedXp = totalAwardedXp
      ..awardedAt = DateTime.now();

    await _gamificationRepository.putGamificationUpdate(
      profile: profile,
      event: xpEvent,
      badges: badges,
      trophies: trophies,
    );

    final unlockedBadgesAfter = badges
        .where((b) => b.unlockedAt != null)
        .map((b) => b.badgeKey)
        .toSet();
    final unlockedTrophiesAfter = trophies
        .where((t) => t.unlockedAt != null)
        .map((t) => t.trophyKey)
        .toSet();

    final outcome = XpAwardOutcome(
      awardedXp: totalAwardedXp,
      unlockedBadgeKeys:
          (unlockedBadgesAfter.difference(unlockedBadgesBefore)).toList(),
      unlockedTrophyKeys:
          (unlockedTrophiesAfter.difference(unlockedTrophiesBefore)).toList(),
    );

    developer.log(
      'Awarded XP: ${outcome.awardedXp}, badges: ${outcome.unlockedBadgeKeys.length}, '
      'trophies: ${outcome.unlockedTrophyKeys.length}',
      name: 'pace.gamification',
    );

    return outcome;
  }

  void _updateProfile(
    GamificationProfile profile,
    int gainedXp, {
    required bool hasPhoto,
  }) {
    profile.totalXp += gainedXp;
    profile.lifetimeCompletions += 1;
    if (hasPhoto) {
      profile.lifetimePhotoCompletions += 1;
    }

    final resolved = LevelCurve.resolveLevelFromXp(profile.totalXp);
    profile.currentLevel = resolved.level;
    profile.xpIntoCurrentLevel = resolved.xpIntoCurrentLevel;
    profile.xpForNextLevel = resolved.xpForNextLevel;
    profile.lastAwardedAt = DateTime.now();
    profile.updatedAt = DateTime.now();
  }

  void _evaluateBadges(
    GamificationProfile profile,
    List<BadgeUnlock> existing,
  ) {
    final byKey = {for (final b in existing) b.badgeKey: b};
    final now = DateTime.now();

    for (final def in BadgeCatalog.all) {
      final badge = byKey[def.key] ??
          (BadgeUnlock()
            ..badgeKey = def.key
            ..tier = def.tier
            ..target = def.target);

      final value = _badgeMetricValue(profile, def.metric);
      badge.progress = value > def.target ? def.target : value;
      badge.tier = def.tier;
      badge.target = def.target;

      if (badge.progress >= badge.target && badge.unlockedAt == null) {
        badge.unlockedAt = now;
      }

      if (!byKey.containsKey(def.key)) {
        existing.add(badge);
        byKey[def.key] = badge;
      }
    }
  }

  int _badgeMetricValue(GamificationProfile profile, BadgeMetric metric) {
    switch (metric) {
      case BadgeMetric.lifetimeCompletions:
        return profile.lifetimeCompletions;
      case BadgeMetric.lifetimePhotoCompletions:
        return profile.lifetimePhotoCompletions;
      case BadgeMetric.totalXp:
        return profile.totalXp;
    }
  }

  void _evaluateTrophies(
    GamificationProfile profile,
    List<BadgeUnlock> badges,
    List<TrophyUnlock> existing,
  ) {
    final byKey = {for (final t in existing) t.trophyKey: t};
    final unlockedBadges = badges.where((b) => b.unlockedAt != null).length;
    final now = DateTime.now();

    for (final def in TrophyCatalog.all) {
      final trophy = byKey[def.key] ??
          (TrophyUnlock()
            ..trophyKey = def.key
            ..target = def.target);

      final value = switch (def.metric) {
        TrophyMetric.unlockedBadges => unlockedBadges,
        TrophyMetric.totalXp => profile.totalXp,
      };

      trophy.progress = value > def.target ? def.target : value;
      trophy.target = def.target;

      if (trophy.progress >= trophy.target && trophy.unlockedAt == null) {
        trophy.unlockedAt = now;
      }

      if (!byKey.containsKey(def.key)) {
        existing.add(trophy);
        byKey[def.key] = trophy;
      }
    }
  }
}
