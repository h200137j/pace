import 'package:flutter_test/flutter_test.dart';
import 'package:pace/core/services/gamification_service.dart';
import 'package:pace/data/models/activity.dart';
import 'package:pace/data/models/badge_unlock.dart';
import 'package:pace/data/models/gamification_profile.dart';
import 'package:pace/data/models/trophy_unlock.dart';
import 'package:pace/data/models/xp_event.dart';
import 'package:pace/data/repositories/activity_repository.dart';
import 'package:pace/data/repositories/gamification_repository.dart';

class _FakeActivityRepository extends ActivityRepository {
  _FakeActivityRepository(this._activity);

  final Activity _activity;

  @override
  Future<Activity?> findById(int id) async => id == _activity.id ? _activity : null;
}

class _FakeGamificationRepository extends GamificationRepository {
  final Map<String, XpEvent> _eventsByKey = {};
  GamificationProfile profile = GamificationProfile();
  final List<BadgeUnlock> badges = [];
  final List<TrophyUnlock> trophies = [];

  @override
  Future<XpEvent?> getEventByKey(String eventKey) async => _eventsByKey[eventKey];

  @override
  Future<GamificationProfile> getOrCreateProfile() async => profile;

  @override
  Future<List<BadgeUnlock>> getAllBadges() async => List<BadgeUnlock>.from(badges);

  @override
  Future<List<TrophyUnlock>> getAllTrophies() async => List<TrophyUnlock>.from(trophies);

  @override
  Future<void> putGamificationUpdate({
    required GamificationProfile profile,
    required XpEvent event,
    required List<BadgeUnlock> badges,
    required List<TrophyUnlock> trophies,
  }) async {
    this.profile = profile;
    _eventsByKey[event.eventKey] = event;
    this.badges
      ..clear()
      ..addAll(badges);
    this.trophies
      ..clear()
      ..addAll(trophies);
  }
}

void main() {
  group('GamificationService', () {
    test('awards XP using difficulty and photo bonus', () async {
      final activity = Activity()
        ..id = 7
        ..name = 'Run'
        ..type = ActivityType.task
        ..difficulty = ActivityDifficulty.hard
        ..colorValue = 0
        ..iconCodePoint = 0
        ..targetDaysMask = 127
        ..createdAt = DateTime.now();

      final fakeRepo = _FakeGamificationRepository();
      final service = GamificationService(
        activityRepository: _FakeActivityRepository(activity),
        gamificationRepository: fakeRepo,
      );

      final awarded = await service.awardCompletionXp(
        activityId: 7,
        dateKey: '2026-04-14',
        hasPhoto: true,
      );

      expect(awarded.awardedXp, 30); // (10 + 5) * 2.0
      expect(fakeRepo.badges.any((b) => b.badgeKey == 'first_step' && b.unlockedAt != null), isTrue);
    });

    test('is idempotent for same completion event key', () async {
      final activity = Activity()
        ..id = 8
        ..name = 'Read'
        ..type = ActivityType.task
        ..difficulty = ActivityDifficulty.medium
        ..colorValue = 0
        ..iconCodePoint = 0
        ..targetDaysMask = 127
        ..createdAt = DateTime.now();

      final fakeRepo = _FakeGamificationRepository();
      final service = GamificationService(
        activityRepository: _FakeActivityRepository(activity),
        gamificationRepository: fakeRepo,
      );

      final firstAward = await service.awardCompletionXp(
        activityId: 8,
        dateKey: '2026-04-14',
        hasPhoto: false,
      );
      final secondAward = await service.awardCompletionXp(
        activityId: 8,
        dateKey: '2026-04-14',
        hasPhoto: false,
      );

      expect(firstAward.awardedXp, 15); // 10 * 1.5
      expect(secondAward.awardedXp, 0);
      expect(fakeRepo.profile.totalXp, 15);
      expect(fakeRepo.profile.lifetimeCompletions, 1);
    });

    test('unlocks milestone badges and trailblazer trophy over time', () async {
      final activity = Activity()
        ..id = 9
        ..name = 'Practice'
        ..type = ActivityType.task
        ..difficulty = ActivityDifficulty.easy
        ..colorValue = 0
        ..iconCodePoint = 0
        ..targetDaysMask = 127
        ..createdAt = DateTime.now();

      final fakeRepo = _FakeGamificationRepository();
      final service = GamificationService(
        activityRepository: _FakeActivityRepository(activity),
        gamificationRepository: fakeRepo,
      );

      for (var i = 1; i <= 30; i++) {
        final day = i.toString().padLeft(2, '0');
        await service.awardCompletionXp(
          activityId: 9,
          dateKey: '2026-05-$day',
          hasPhoto: false,
        );
      }

      final steadyBuilder = fakeRepo.badges.firstWhere(
        (b) => b.badgeKey == 'steady_builder',
      );
      final trailblazer = fakeRepo.trophies.firstWhere(
        (t) => t.trophyKey == 'trailblazer',
      );

      expect(steadyBuilder.unlockedAt, isNotNull);
      expect(trailblazer.unlockedAt, isNotNull);
      expect(fakeRepo.profile.lifetimeCompletions, 30);
    });

    test('unlocks photo and XP badge families', () async {
      final activity = Activity()
        ..id = 10
        ..name = 'Workout'
        ..type = ActivityType.task
        ..difficulty = ActivityDifficulty.elite
        ..colorValue = 0
        ..iconCodePoint = 0
        ..targetDaysMask = 127
        ..createdAt = DateTime.now();

      final fakeRepo = _FakeGamificationRepository();
      final service = GamificationService(
        activityRepository: _FakeActivityRepository(activity),
        gamificationRepository: fakeRepo,
      );

      for (var i = 1; i <= 10; i++) {
        final day = i.toString().padLeft(2, '0');
        await service.awardCompletionXp(
          activityId: 10,
          dateKey: '2026-06-$day',
          hasPhoto: true,
        );
      }

      final photoBadge = fakeRepo.badges.firstWhere(
        (b) => b.badgeKey == 'photo_journaler',
      );
      final xpBadge = fakeRepo.badges.firstWhere(
        (b) => b.badgeKey == 'xp_novice',
      );

      expect(photoBadge.unlockedAt, isNotNull);
      expect(xpBadge.unlockedAt, isNotNull);
      expect(fakeRepo.profile.totalXp, greaterThanOrEqualTo(250));
    });

    test('applies a duration multiplier for long challenge completions', () async {
      final activity = Activity()
        ..id = 11
        ..name = 'Year Challenge'
        ..type = ActivityType.challenge
        ..difficulty = ActivityDifficulty.medium
        ..colorValue = 0
        ..iconCodePoint = 0
        ..targetDaysMask = 127
        ..startDate = DateTime.utc(2026, 1, 1)
        ..endDate = DateTime.utc(2026, 12, 31)
        ..plannedDurationDays = 365
        ..createdAt = DateTime.utc(2026, 1, 1);

      final fakeRepo = _FakeGamificationRepository();
      final service = GamificationService(
        activityRepository: _FakeActivityRepository(activity),
        gamificationRepository: fakeRepo,
      );

      final awarded = await service.awardCompletionXp(
        activityId: 11,
        dateKey: '2026-01-01',
        hasPhoto: false,
      );

      expect(awarded.awardedXp, 23);
    });
  });
}
