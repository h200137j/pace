import '../../data/models/activity.dart';

class XpConfig {
  const XpConfig._();

  static const int completionBaseXp = 10;
  static const int photoBonusXp = 5;

  static double multiplierFor(ActivityDifficulty difficulty) {
    switch (difficulty) {
      case ActivityDifficulty.easy:
        return 1.0;
      case ActivityDifficulty.medium:
        return 1.5;
      case ActivityDifficulty.hard:
        return 2.0;
      case ActivityDifficulty.elite:
        return 3.0;
    }
  }
}
