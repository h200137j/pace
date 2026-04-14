import 'package:flutter_test/flutter_test.dart';
import 'package:pace/data/models/activity.dart';
import 'package:pace/data/models/badge_unlock.dart';
import 'package:pace/data/models/completion.dart';
import 'package:pace/data/models/gamification_profile.dart';
import 'package:pace/data/models/trophy_unlock.dart';
import 'package:pace/data/models/xp_event.dart';
import 'package:pace/data/repositories/activity_repository.dart';
import 'package:pace/data/repositories/completion_repository.dart';
import 'package:pace/data/repositories/gamification_repository.dart';
import 'package:pace/data/services/export_service.dart';

class _FakeActivityRepository extends ActivityRepository {
  _FakeActivityRepository([List<Activity>? initial]) {
    if (initial != null) {
      for (final activity in initial) {
        _activities[activity.id] = activity;
      }
    }
  }

  final Map<int, Activity> _activities = {};

  @override
  Future<List<Activity>> getAllIncludingArchived() async =>
      _activities.values.toList();

  @override
  Future<void> update(Activity activity) async {
    _activities[activity.id] = activity;
  }

  @override
  Future<Activity?> findById(int id) async => _activities[id];
}

class _FakeCompletionRepository extends CompletionRepository {
  _FakeCompletionRepository([List<Completion>? initial]) {
    if (initial != null) {
      for (final completion in initial) {
        _byKey[_key(completion.activityId, completion.dateKey)] = completion;
      }
    }
  }

  final Map<String, Completion> _byKey = {};

  String _key(int activityId, String dateKey) => '$activityId:$dateKey';

  @override
  Future<List<Completion>> getAll() async => _byKey.values.toList();

  @override
  Future<void> importBatch(List<Completion> completions) async {
    for (final completion in completions) {
      _byKey[_key(completion.activityId, completion.dateKey)] = completion;
    }
  }
}

class _FakeGamificationRepository extends GamificationRepository {
  _FakeGamificationRepository({
    this.profile,
    List<BadgeUnlock>? badges,
    List<TrophyUnlock>? trophies,
    List<XpEvent>? events,
  }) {
    if (badges != null) {
      for (final badge in badges) {
        _badges[badge.badgeKey] = badge;
      }
    }
    if (trophies != null) {
      for (final trophy in trophies) {
        _trophies[trophy.trophyKey] = trophy;
      }
    }
    if (events != null) {
      for (final event in events) {
        _events[event.eventKey] = event;
      }
    }
  }

  GamificationProfile? profile;

  final Map<String, BadgeUnlock> _badges = {};
  final Map<String, TrophyUnlock> _trophies = {};
  final Map<String, XpEvent> _events = {};

  @override
  Future<GamificationProfile?> getProfile() async => profile;

  @override
  Future<GamificationProfile> getOrCreateProfile() async {
    profile ??= GamificationProfile();
    return profile!;
  }

  @override
  Future<List<BadgeUnlock>> getAllBadges() async => _badges.values.toList();

  @override
  Future<List<TrophyUnlock>> getAllTrophies() async =>
      _trophies.values.toList();

  @override
  Future<List<XpEvent>> getAllEvents() async => _events.values.toList();

  @override
  Future<XpEvent?> getEventByKey(String eventKey) async => _events[eventKey];

  @override
  Future<void> importSnapshot({
    GamificationProfile? profile,
    required List<BadgeUnlock> badges,
    required List<TrophyUnlock> trophies,
    required List<XpEvent> events,
  }) async {
    if (profile != null) {
      this.profile = profile;
    }
    for (final badge in badges) {
      _badges[badge.badgeKey] = badge;
    }
    for (final trophy in trophies) {
      _trophies[trophy.trophyKey] = trophy;
    }
    for (final event in events) {
      _events[event.eventKey] = event;
    }
  }

  @override
  Future<void> resetAll() async {
    profile = null;
    _badges.clear();
    _trophies.clear();
    _events.clear();
  }

  @override
  Future<void> putGamificationUpdate({
    required GamificationProfile profile,
    required XpEvent event,
    required List<BadgeUnlock> badges,
    required List<TrophyUnlock> trophies,
  }) async {
    this.profile = profile;
    _events[event.eventKey] = event;
    for (final badge in badges) {
      _badges[badge.badgeKey] = badge;
    }
    for (final trophy in trophies) {
      _trophies[trophy.trophyKey] = trophy;
    }
  }
}

void main() {
  group('ExportService payload roundtrip', () {
    test('roundtrip preserves v2 gamification and activity difficulty', () async {
      final activity = Activity()
        ..id = 1
        ..name = 'Run'
        ..type = ActivityType.task
        ..difficulty = ActivityDifficulty.hard
        ..colorValue = 1
        ..iconCodePoint = 2
        ..targetDaysMask = 127
        ..createdAt = DateTime.parse('2026-04-01T00:00:00.000');

      final completion = Completion()
        ..id = 11
        ..activityId = 1
        ..dateKey = '2026-04-10'
        ..completedAt = DateTime.parse('2026-04-10T08:00:00.000');

      final profile = GamificationProfile()
        ..id = 1
        ..totalXp = 120
        ..currentLevel = 2
        ..xpIntoCurrentLevel = 20
        ..xpForNextLevel = 125
        ..lifetimeCompletions = 10
        ..lifetimePhotoCompletions = 3;

      final badge = BadgeUnlock()
        ..badgeKey = 'first_step'
        ..target = 1
        ..progress = 1
        ..tier = 'bronze'
        ..unlockedAt = DateTime.parse('2026-04-01T00:00:00.000');

      final trophy = TrophyUnlock()
        ..trophyKey = 'trailblazer'
        ..target = 3
        ..progress = 1;

      final event = XpEvent()
        ..eventKey = 'completion:1:2026-04-10'
        ..sourceType = 'completion'
        ..sourceId = '1:2026-04-10'
        ..baseXp = 10
        ..bonusXp = 0
        ..multiplier = 2.0
        ..totalAwardedXp = 20
        ..awardedAt = DateTime.parse('2026-04-10T08:00:00.000');

      final sourceActivityRepo = _FakeActivityRepository([activity]);
      final sourceCompletionRepo = _FakeCompletionRepository([completion]);
      final sourceGamificationRepo = _FakeGamificationRepository(
        profile: profile,
        badges: [badge],
        trophies: [trophy],
        events: [event],
      );

      final exportService = ExportService(
        activityRepo: sourceActivityRepo,
        completionRepo: sourceCompletionRepo,
        gamificationRepo: sourceGamificationRepo,
      );

      final payload = await exportService.buildExportPayload();

      final targetActivityRepo = _FakeActivityRepository();
      final targetCompletionRepo = _FakeCompletionRepository();
      final targetGamificationRepo = _FakeGamificationRepository();

      final importService = ExportService(
        activityRepo: targetActivityRepo,
        completionRepo: targetCompletionRepo,
        gamificationRepo: targetGamificationRepo,
      );

      await importService.importFromPayload(payload);

      final importedActivity = await targetActivityRepo.findById(1);
      final importedCompletions = await targetCompletionRepo.getAll();
      final importedProfile = await targetGamificationRepo.getProfile();
      final importedEvents = await targetGamificationRepo.getAllEvents();

      expect(importedActivity, isNotNull);
      expect(importedActivity!.difficulty, ActivityDifficulty.hard);
      expect(importedCompletions.length, 1);
      expect(importedProfile, isNotNull);
      expect(importedProfile!.totalXp, 120);
      expect(importedEvents.length, 1);
    });

    test('seeded v1 payload rebuilds gamification and stays idempotent', () async {
      final activityRepo = _FakeActivityRepository();
      final completionRepo = _FakeCompletionRepository();
      final gamificationRepo = _FakeGamificationRepository();

      final service = ExportService(
        activityRepo: activityRepo,
        completionRepo: completionRepo,
        gamificationRepo: gamificationRepo,
      );

      final v1Payload = <String, dynamic>{
        'version': 1,
        'exportedAt': '2026-04-14T00:00:00.000Z',
        'activities': [
          {
            'id': 2,
            'name': 'Read',
            'type': 'task',
            'colorValue': 1,
            'iconCodePoint': 2,
            'targetDaysMask': 127,
            'createdAt': '2026-04-01T00:00:00.000',
            'archivedAt': null,
            'completedDays': ['2026-04-10', '2026-04-11']
          }
        ],
        'completions': [],
      };

      await service.importFromPayload(v1Payload);
      await service.importFromPayload(v1Payload);

      final profile = await gamificationRepo.getProfile();
      final events = await gamificationRepo.getAllEvents();
      final badges = await gamificationRepo.getAllBadges();

      expect(profile, isNotNull);
      expect(profile!.lifetimeCompletions, 2);
      expect(events.length, 2);
      expect(badges.any((b) => b.badgeKey == 'first_step' && b.unlockedAt != null),
          isTrue);
    });
  });
}
