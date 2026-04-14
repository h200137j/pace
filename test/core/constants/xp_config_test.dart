import 'package:flutter_test/flutter_test.dart';
import 'package:pace/core/constants/xp_config.dart';
import 'package:pace/data/models/activity.dart';

void main() {
  group('XpConfig multipliers', () {
    test('returns expected multiplier for each difficulty', () {
      expect(XpConfig.multiplierFor(ActivityDifficulty.easy), 1.0);
      expect(XpConfig.multiplierFor(ActivityDifficulty.medium), 1.5);
      expect(XpConfig.multiplierFor(ActivityDifficulty.hard), 2.0);
      expect(XpConfig.multiplierFor(ActivityDifficulty.elite), 3.0);
    });
  });
}
