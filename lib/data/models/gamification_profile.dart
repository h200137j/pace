import 'package:isar/isar.dart';

part 'gamification_profile.g.dart';

@Collection()
class GamificationProfile {
  Id id = 1;

  int totalXp = 0;
  int currentLevel = 1;
  int xpIntoCurrentLevel = 0;
  int xpForNextLevel = 100;

  int lifetimeCompletions = 0;
  int lifetimePhotoCompletions = 0;

  DateTime? lastAwardedAt;
  DateTime updatedAt = DateTime.now();
}
