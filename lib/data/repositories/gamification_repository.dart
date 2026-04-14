import 'package:isar/isar.dart';

import '../../core/constants/badge_catalog.dart';
import '../../core/constants/trophy_catalog.dart';
import '../models/badge_unlock.dart';
import '../models/gamification_profile.dart';
import '../models/trophy_unlock.dart';
import '../models/xp_event.dart';
import '../services/isar_service.dart';

class GamificationRepository {
  Isar get _db => IsarService.instance.db;

  IsarCollection<GamificationProfile> get _profiles => _db.gamificationProfiles;
  IsarCollection<BadgeUnlock> get _badges => _db.badgeUnlocks;
  IsarCollection<TrophyUnlock> get _trophies => _db.trophyUnlocks;
  IsarCollection<XpEvent> get _events => _db.xpEvents;

  Future<GamificationProfile> getOrCreateProfile() async {
    final existing = await _profiles.get(1);
    if (existing != null) return existing;

    final created = GamificationProfile()..id = 1;
    await _db.writeTxn(() => _profiles.put(created));
    return created;
  }

  Future<GamificationProfile?> getProfile() => _profiles.get(1);

  Stream<GamificationProfile?> watchProfile() =>
      _profiles.watchObject(1, fireImmediately: true);

  Future<XpEvent?> getEventByKey(String eventKey) =>
      _events.where().eventKeyEqualTo(eventKey).findFirst();

  Future<void> putProfileAndEvent(
    GamificationProfile profile,
    XpEvent event,
  ) async {
    await _db.writeTxn(() async {
      await _profiles.put(profile);
      await _events.put(event);
    });
  }

  Future<void> putGamificationUpdate({
    required GamificationProfile profile,
    required XpEvent event,
    required List<BadgeUnlock> badges,
    required List<TrophyUnlock> trophies,
  }) async {
    await _db.writeTxn(() async {
      await _profiles.put(profile);
      await _events.put(event);
      if (badges.isNotEmpty) {
        await _badges.putAllByBadgeKey(badges);
      }
      if (trophies.isNotEmpty) {
        await _trophies.putAllByTrophyKey(trophies);
      }
    });
  }

  Future<List<XpEvent>> getAllEvents() => _events.where().findAll();

  Stream<List<XpEvent>> watchAllEvents() =>
      _events.where().watch(fireImmediately: true);

  Future<List<BadgeUnlock>> getAllBadges() => _badges.where().findAll();

  Stream<List<BadgeUnlock>> watchBadges() =>
      _badges.where().watch(fireImmediately: true);

  /// Ensure all badges from the catalog exist in the database.
  Future<void> ensureAllBadgesExist() async {
    final existing = await getAllBadges();
    final existingKeys = {for (final b in existing) b.badgeKey};
    final toCreate = <BadgeUnlock>[];

    for (final def in BadgeCatalog.all) {
      if (!existingKeys.contains(def.key)) {
        toCreate.add(BadgeUnlock()
          ..badgeKey = def.key
          ..tier = def.tier
          ..target = def.target
          ..progress = 0);
      }
    }

    if (toCreate.isNotEmpty) {
      await _db.writeTxn(() => _badges.putAllByBadgeKey(toCreate));
    }
  }

  Future<List<TrophyUnlock>> getAllTrophies() => _trophies.where().findAll();

  Stream<List<TrophyUnlock>> watchTrophies() =>
      _trophies.where().watch(fireImmediately: true);

  /// Ensure all trophies from the catalog exist in the database.
  Future<void> ensureAllTrophiesExist() async {
    final existing = await getAllTrophies();
    final existingKeys = {for (final t in existing) t.trophyKey};
    final toCreate = <TrophyUnlock>[];

    // Get current state for progress calculation
    final allBadges = await getAllBadges();
    final unlockedBadgeCount = allBadges.where((b) => b.unlockedAt != null).length;
    final profile = await getOrCreateProfile();
    final totalXp = profile.totalXp;

    for (final def in TrophyCatalog.all) {
      if (!existingKeys.contains(def.key)) {
        // Calculate correct progress based on metric type
        final progress = switch (def.metric) {
          TrophyMetric.unlockedBadges => 
            unlockedBadgeCount > def.target ? def.target : unlockedBadgeCount,
          TrophyMetric.totalXp => 
            totalXp > def.target ? def.target : totalXp,
        };

        final unlockTime = progress >= def.target ? DateTime.now() : null;

        toCreate.add(TrophyUnlock()
          ..trophyKey = def.key
          ..target = def.target
          ..progress = progress
          ..unlockedAt = unlockTime);
      }
    }

    if (toCreate.isNotEmpty) {
      await _db.writeTxn(() => _trophies.putAllByTrophyKey(toCreate));
    }
  }

    Future<void> resetAll() async {
      await _db.writeTxn(() async {
        await _profiles.clear();
        await _badges.clear();
        await _trophies.clear();
        await _events.clear();
      });
    }

  Future<void> importSnapshot({
    GamificationProfile? profile,
    required List<BadgeUnlock> badges,
    required List<TrophyUnlock> trophies,
    required List<XpEvent> events,
  }) async {
    await _db.writeTxn(() async {
      if (profile != null) {
        await _profiles.put(profile);
      }
      if (badges.isNotEmpty) {
        await _badges.putAllByBadgeKey(badges);
      }
      if (trophies.isNotEmpty) {
        await _trophies.putAllByTrophyKey(trophies);
      }
      if (events.isNotEmpty) {
        await _events.putAllByEventKey(events);
      }
    });
  }
}
