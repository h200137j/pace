import 'package:shared_preferences/shared_preferences.dart';

import '../utils/date_utils.dart';
import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';

class ChallengeDateMigrationService {
  ChallengeDateMigrationService._();

  static const _migrationMarkerKey = 'challenge_end_date_migration_v1_done';

  static Future<void> ensureMigratedOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyDone = prefs.getBool(_migrationMarkerKey) ?? false;
    if (alreadyDone) return;

    final repo = ActivityRepository();
    final all = await repo.getAllIncludingArchived();
    final now = DateTime.now();
    final yearStart = PaceDateUtils.toDateOnly(DateTime.utc(now.year, 1, 1));
    final yearEnd = PaceDateUtils.toDateOnly(DateTime.utc(now.year, 12, 31));

    for (final activity in all) {
      if (activity.type != ActivityType.challenge) continue;
      if (activity.endDate != null) continue;

      activity
        ..startDate = yearStart
        ..endDate = yearEnd
        ..endDateUserSelected = false
        ..plannedDurationDays = yearEnd.difference(yearStart).inDays + 1;

      await repo.update(activity);
    }

    await prefs.setBool(_migrationMarkerKey, true);
  }
}
