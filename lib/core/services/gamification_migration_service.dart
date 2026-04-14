import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import 'gamification_service.dart';

class GamificationMigrationService {
  GamificationMigrationService._();

  static const _migrationMarkerKey = 'gm_migration_rebuild_v1_done';

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
