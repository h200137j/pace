import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import 'gamification_service.dart';

class GamificationMigrationService {
  GamificationMigrationService._();

  static const _migrationMarkerKey = 'gm_migration_rebuild_v1_done';

  // Bump this key whenever BadgeCatalog or TrophyCatalog changes structurally.
  static const _badgeCatalogMigrationKey = 'badge_catalog_v2_evaluated';

  /// Re-evaluates all badges/trophies against the current catalog.
  /// Runs once per catalog version so new catalog entries get backfilled.
  static Future<void> ensureBadgesEvaluated() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_badgeCatalogMigrationKey) ?? false) return;

    final gamificationRepo = GamificationRepository();
    final profile = await gamificationRepo.getProfile();
    if (profile == null) {
      // No profile yet — normal first-run, nothing to backfill.
      await prefs.setBool(_badgeCatalogMigrationKey, true);
      return;
    }

    try {
      final service = GamificationService(
        activityRepository: ActivityRepository(),
        gamificationRepository: gamificationRepo,
      );
      final badges = await gamificationRepo.getAllBadges();
      final trophies = await gamificationRepo.getAllTrophies();
      // Re-evaluate badge/trophy state against the new catalog without
      // changing XP or resetting the profile.
      service.evaluateBadgesAndTrophies(profile, badges, trophies);
      await gamificationRepo.saveBadgesAndTrophies(
        badges: badges,
        trophies: trophies,
      );
      await prefs.setBool(_badgeCatalogMigrationKey, true);
    } catch (e, st) {
      developer.log(
        'Badge catalog migration failed: $e',
        name: 'pace.gamification.migration',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> ensureRebuiltOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDone = prefs.getBool(_migrationMarkerKey) ?? false;
    if (alreadyDone) return;

    final gamificationRepo = GamificationRepository();
    final existingProfile = await gamificationRepo.getProfile();
    final existingEvents = await gamificationRepo.getAllEvents();
    if (existingProfile != null || existingEvents.isNotEmpty) {
      await prefs.setBool(_migrationMarkerKey, true);
      return;
    }

    final completionRepo = CompletionRepository();
    final completions = await completionRepo.getAll();
    if (completions.isEmpty) {
      await prefs.setBool(_migrationMarkerKey, true);
      return;
    }

    final service = GamificationService(
      activityRepository: ActivityRepository(),
      gamificationRepository: gamificationRepo,
    );

    try {
      await gamificationRepo.resetAll();
      final sortedCompletions = [...completions]
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

      for (final completion in sortedCompletions) {
        await service.awardCompletionXp(
          activityId: completion.activityId,
          dateKey: completion.dateKey,
          hasPhoto: completion.photoPath != null,
        );
      }

      await prefs.setBool(_migrationMarkerKey, true);
    } catch (e, st) {
      developer.log(
        'Gamification migration rebuild failed: $e',
        name: 'pace.gamification.migration',
        error: e,
        stackTrace: st,
      );
    }
  }
}
