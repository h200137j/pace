import 'package:flutter_test/flutter_test.dart';
import 'package:pace/core/services/challenge_reward_service.dart';
import 'package:pace/data/models/activity.dart';

Activity _challenge({
  required DateTime startDate,
  required DateTime endDate,
  int targetDaysMask = 127,
}) {
  return Activity()
    ..id = 1
    ..name = 'Challenge'
    ..type = ActivityType.challenge
    ..difficulty = ActivityDifficulty.medium
    ..colorValue = 0
    ..iconCodePoint = 0
    ..targetDaysMask = targetDaysMask
    ..startDate = startDate
    ..endDate = endDate
    ..endDateUserSelected = true
    ..plannedDurationDays = endDate.difference(startDate).inDays + 1
    ..createdAt = startDate;
}

void main() {
  group('ChallengeRewardService', () {
    test('builds a longer profile for year-long challenges than 7-day ones', () {
      final shortChallenge = _challenge(
        startDate: DateTime.utc(2026, 4, 1),
        endDate: DateTime.utc(2026, 4, 7),
      );
      final yearChallenge = _challenge(
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2026, 12, 31),
      );

      final shortProfile = ChallengeRewardService.buildProfile(
        activity: shortChallenge,
        completionCount: 0,
        photoCompletionCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        challengeXp: 0,
      );
      final yearProfile = ChallengeRewardService.buildProfile(
        activity: yearChallenge,
        completionCount: 0,
        photoCompletionCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        challengeXp: 0,
      );

      expect(shortProfile.durationDays, 7);
      expect(shortProfile.lengthMultiplier, closeTo(1.0, 0.001));
      expect(shortProfile.badges.length, 25);
      expect(shortProfile.trophies.length, 25);

      expect(yearProfile.durationDays, 365);
      expect(yearProfile.lengthMultiplier, closeTo(1.5, 0.001));
      expect(yearProfile.projectedChallengeXp, greaterThan(shortProfile.projectedChallengeXp));
    });

    test('evaluates dynamic badge and trophy counts from challenge progress', () {
      final challenge = _challenge(
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2026, 12, 31),
      );

      final progress = ChallengeRewardService.evaluate(
        activity: challenge,
        completionCount: 200,
        photoCompletionCount: 25,
        currentStreak: 30,
        longestStreak: 45,
        challengeXp: 5000,
      );

      expect(progress.badgesUnlocked, greaterThan(0));
      expect(progress.trophiesUnlocked, greaterThan(0));
      expect(progress.profile.badges.length, 25);
      expect(progress.profile.trophies.length, 25);
      expect(progress.unlockedBadgeTitles, isNotEmpty);
      expect(progress.unlockedTrophyTitles, isNotEmpty);
    });
  });
}
