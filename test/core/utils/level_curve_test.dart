import 'package:flutter_test/flutter_test.dart';
import 'package:pace/core/utils/level_curve.dart';

void main() {
  group('LevelCurve', () {
    test('returns expected xp thresholds', () {
      expect(LevelCurve.xpToNextLevel(1), 100);
      expect(LevelCurve.xpToNextLevel(2), 125);
      expect(LevelCurve.xpToNextLevel(3), 150);
    });

    test('resolves level and progress from total XP', () {
      final result = LevelCurve.resolveLevelFromXp(240);
      expect(result.level, 3);
      expect(result.xpIntoCurrentLevel, 15);
      expect(result.xpForNextLevel, 150);
    });
  });
}
