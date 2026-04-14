import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/activity.dart';
import '../models/badge_unlock.dart';
import '../models/completion.dart';
import '../models/gamification_profile.dart';
import '../models/trophy_unlock.dart';
import '../models/xp_event.dart';

/// Singleton that holds the open Isar database instance.
class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get db {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError('IsarService not initialised. Call init() first.');
    }
    return _isar!;
  }

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        ActivitySchema,
        CompletionSchema,
        GamificationProfileSchema,
        BadgeUnlockSchema,
        TrophyUnlockSchema,
        XpEventSchema,
      ],
      directory: dir.path,
      name: 'pace_db',
    );
  }

  Future<void> close() async => _isar?.close();
}
