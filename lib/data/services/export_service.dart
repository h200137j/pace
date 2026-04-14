import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import '../../core/services/gamification_service.dart';
import '../models/activity.dart';
import '../models/badge_unlock.dart';
import '../models/completion.dart';
import '../models/gamification_profile.dart';
import '../models/trophy_unlock.dart';
import '../models/xp_event.dart';
import '../repositories/activity_repository.dart';
import '../repositories/completion_repository.dart';
import '../repositories/gamification_repository.dart';

class ExportService {
  ExportService({
    required ActivityRepository activityRepo,
    required CompletionRepository completionRepo,
      required GamificationRepository gamificationRepo,
  })  : _actRepo = activityRepo,
      _compRepo = completionRepo,
      _gamificationRepo = gamificationRepo;

  final ActivityRepository _actRepo;
  final CompletionRepository _compRepo;
    final GamificationRepository _gamificationRepo;

  // ── JSON Export ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> buildExportPayload() async {
    final activities = await _actRepo.getAllIncludingArchived();
    final completions = await _compRepo.getAll();
    final profile = await _gamificationRepo.getProfile();
    final badges = await _gamificationRepo.getAllBadges();
    final trophies = await _gamificationRepo.getAllTrophies();
    final xpEvents = await _gamificationRepo.getAllEvents();
    final completionsByActivity = <int, List<Completion>>{};

    for (final completion in completions) {
      completionsByActivity
          .putIfAbsent(completion.activityId, () => <Completion>[])
          .add(completion);
    }

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'activities': activities
          .map((activity) => _activityToMap(
                activity,
                completionsByActivity[activity.id] ?? const [],
              ))
          .toList(),
      'completions': completions.map(_completionToMap).toList(),
      'gamificationProfile': profile == null ? null : _profileToMap(profile),
      'badgeUnlocks': badges.map(_badgeToMap).toList(),
      'trophyUnlocks': trophies.map(_trophyToMap).toList(),
      'xpEvents': xpEvents.map(_xpEventToMap).toList(),
    };
  }

  Future<void> exportJson() async {
    final payload = await buildExportPayload();

    final json = const JsonEncoder.withIndent('  ').convert(payload);
    final file = await _writeTemp('pace_backup.json', json);
    await Share.shareXFiles([XFile(file.path)], text: 'Pace backup');
  }

  Future<void> importJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final raw = await File(result.files.single.path!).readAsString();
    final payload = jsonDecode(raw) as Map<String, dynamic>;
    await importFromPayload(payload);
  }

  Future<void> importFromPayload(Map<String, dynamic> payload) async {
    final version = (payload['version'] as num?)?.toInt() ?? 1;
    final activityMaps = (payload['activities'] as List)
      .cast<Map<String, dynamic>>();

    final acts = activityMaps
      .map(_activityFromMap)
        .toList();

    for (final a in acts) {
      await _actRepo.update(a);
    }

    final comps = <Completion>[];
    final completionEntries =
        (payload['completions'] as List?)?.cast<dynamic>() ?? const [];
    for (final e in completionEntries) {
      final map = e as Map<String, dynamic>;
      comps.add(await _completionFromImportMap(map));
    }

    if (comps.isEmpty) {
      for (final activityMap in activityMaps) {
        final activityId = activityMap['id'] as int;
        final completedDays = (activityMap['completedDays'] as List?)
                ?.cast<String>() ??
            const [];

        for (final dateKey in completedDays) {
          comps.add(Completion()
            ..activityId = activityId
            ..dateKey = dateKey
            ..completedAt = DateTime.parse('${dateKey}T00:00:00.000')
            );
        }
      }
    }

    await _compRepo.importBatch(comps);

    if (version >= 2) {
      final profileMap = payload['gamificationProfile'] as Map<String, dynamic>?;
      final badgeMaps = (payload['badgeUnlocks'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      final trophyMaps = (payload['trophyUnlocks'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      final eventMaps = (payload['xpEvents'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];

      await _gamificationRepo.importSnapshot(
        profile: profileMap == null ? null : _profileFromMap(profileMap),
        badges: badgeMaps.map(_badgeFromMap).toList(),
        trophies: trophyMaps.map(_trophyFromMap).toList(),
        events: eventMaps.map(_xpEventFromMap).toList(),
      );
    } else {
      await _gamificationRepo.resetAll();
      final service = GamificationService(
        activityRepository: _actRepo,
        gamificationRepository: _gamificationRepo,
      );

      final sortedCompletions = [...comps]
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

      for (final completion in sortedCompletions) {
        await service.awardCompletionXp(
          activityId: completion.activityId,
          dateKey: completion.dateKey,
          hasPhoto: completion.photoPath != null,
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<File> _writeTemp(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file;
  }

  Map<String, dynamic> _activityToMap(
    Activity a,
    List<Completion> completions,
  ) => {
        'id': a.id,
        'name': a.name,
        'type': a.type.name,
        'difficulty': a.difficulty.name,
        'colorValue': a.colorValue,
        'iconCodePoint': a.iconCodePoint,
        'targetDaysMask': a.targetDaysMask,
        'startDate': a.startDate?.toIso8601String(),
        'endDate': a.endDate?.toIso8601String(),
        'endDateUserSelected': a.endDateUserSelected,
        'plannedDurationDays': a.plannedDurationDays,
        'createdAt': a.createdAt.toIso8601String(),
        'archivedAt': a.archivedAt?.toIso8601String(),
        'completedDays': completions.map((c) => c.dateKey).toList(),
      };

  Activity _activityFromMap(Map<String, dynamic> m) => Activity()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..type = ActivityType.values.byName(m['type'] as String)
    ..difficulty = m['difficulty'] == null
      ? ActivityDifficulty.medium
      : ActivityDifficulty.values.byName(m['difficulty'] as String)
    ..colorValue = m['colorValue'] as int
    ..iconCodePoint = m['iconCodePoint'] as int
    ..targetDaysMask = m['targetDaysMask'] as int
    ..startDate = m['startDate'] == null
      ? null
      : DateTime.parse(m['startDate'] as String)
    ..endDate = m['endDate'] == null
      ? null
      : DateTime.parse(m['endDate'] as String)
    ..endDateUserSelected = m['endDateUserSelected'] as bool? ?? false
    ..plannedDurationDays = (m['plannedDurationDays'] as num?)?.toInt() ?? 0
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..archivedAt = m['archivedAt'] != null
        ? DateTime.parse(m['archivedAt'] as String)
        : null;

  Map<String, dynamic> _completionToMap(Completion c) => {
        'id': c.id,
        'activityId': c.activityId,
        'dateKey': c.dateKey,
        'completedAt': c.completedAt.toIso8601String(),
        'photoPath': c.photoPath,
        'photoFileName': c.photoPath != null ? path.basename(c.photoPath!) : null,
        'photoData': _encodePhoto(c.photoPath),
        'note': c.note,
      };

  Completion _completionFromMap(Map<String, dynamic> m) => Completion()
    ..id = m['id'] as int
    ..activityId = m['activityId'] as int
    ..dateKey = m['dateKey'] as String
    ..completedAt = DateTime.parse(m['completedAt'] as String)
    ..photoPath = m['photoPath'] as String?
    ..note = m['note'] as String?;

  Future<Completion> _completionFromImportMap(Map<String, dynamic> m) async {
    final completion = _completionFromMap(m);
    final photoData = m['photoData'] as String?;
    final photoFileName = m['photoFileName'] as String?;
    if (photoData != null) {
      completion.photoPath = await _restorePhoto(
        photoData,
        completion.activityId,
        completion.dateKey,
        photoFileName: photoFileName,
      );
    }
    return completion;
  }

  Map<String, dynamic> _profileToMap(GamificationProfile p) => {
        'id': p.id,
        'totalXp': p.totalXp,
        'currentLevel': p.currentLevel,
        'xpIntoCurrentLevel': p.xpIntoCurrentLevel,
        'xpForNextLevel': p.xpForNextLevel,
        'lifetimeCompletions': p.lifetimeCompletions,
        'lifetimePhotoCompletions': p.lifetimePhotoCompletions,
        'lastAwardedAt': p.lastAwardedAt?.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
      };

  GamificationProfile _profileFromMap(Map<String, dynamic> m) =>
      GamificationProfile()
        ..id = (m['id'] as num?)?.toInt() ?? 1
        ..totalXp = (m['totalXp'] as num?)?.toInt() ?? 0
        ..currentLevel = (m['currentLevel'] as num?)?.toInt() ?? 1
        ..xpIntoCurrentLevel = (m['xpIntoCurrentLevel'] as num?)?.toInt() ?? 0
        ..xpForNextLevel = (m['xpForNextLevel'] as num?)?.toInt() ?? 100
        ..lifetimeCompletions = (m['lifetimeCompletions'] as num?)?.toInt() ?? 0
        ..lifetimePhotoCompletions =
            (m['lifetimePhotoCompletions'] as num?)?.toInt() ?? 0
        ..lastAwardedAt = m['lastAwardedAt'] == null
            ? null
            : DateTime.parse(m['lastAwardedAt'] as String)
        ..updatedAt = m['updatedAt'] == null
            ? DateTime.now()
            : DateTime.parse(m['updatedAt'] as String);

  Map<String, dynamic> _badgeToMap(BadgeUnlock b) => {
        'badgeKey': b.badgeKey,
        'unlockedAt': b.unlockedAt?.toIso8601String(),
        'progress': b.progress,
        'target': b.target,
        'tier': b.tier,
        'metadataJson': b.metadataJson,
      };

  BadgeUnlock _badgeFromMap(Map<String, dynamic> m) => BadgeUnlock()
    ..badgeKey = m['badgeKey'] as String
    ..unlockedAt = m['unlockedAt'] == null
        ? null
        : DateTime.parse(m['unlockedAt'] as String)
    ..progress = (m['progress'] as num?)?.toInt() ?? 0
    ..target = (m['target'] as num?)?.toInt() ?? 1
    ..tier = (m['tier'] as String?) ?? 'bronze'
    ..metadataJson = m['metadataJson'] as String?;

  Map<String, dynamic> _trophyToMap(TrophyUnlock t) => {
        'trophyKey': t.trophyKey,
        'unlockedAt': t.unlockedAt?.toIso8601String(),
        'progress': t.progress,
        'target': t.target,
        'metadataJson': t.metadataJson,
      };

  TrophyUnlock _trophyFromMap(Map<String, dynamic> m) => TrophyUnlock()
    ..trophyKey = m['trophyKey'] as String
    ..unlockedAt = m['unlockedAt'] == null
        ? null
        : DateTime.parse(m['unlockedAt'] as String)
    ..progress = (m['progress'] as num?)?.toInt() ?? 0
    ..target = (m['target'] as num?)?.toInt() ?? 1
    ..metadataJson = m['metadataJson'] as String?;

  Map<String, dynamic> _xpEventToMap(XpEvent e) => {
        'eventKey': e.eventKey,
        'sourceType': e.sourceType,
        'sourceId': e.sourceId,
        'baseXp': e.baseXp,
        'bonusXp': e.bonusXp,
        'multiplier': e.multiplier,
        'totalAwardedXp': e.totalAwardedXp,
        'awardedAt': e.awardedAt.toIso8601String(),
        'note': e.note,
      };

  XpEvent _xpEventFromMap(Map<String, dynamic> m) => XpEvent()
    ..eventKey = m['eventKey'] as String
    ..sourceType = m['sourceType'] as String
    ..sourceId = m['sourceId'] as String
    ..baseXp = (m['baseXp'] as num?)?.toInt() ?? 0
    ..bonusXp = (m['bonusXp'] as num?)?.toInt() ?? 0
    ..multiplier = (m['multiplier'] as num?)?.toDouble() ?? 1.0
    ..totalAwardedXp = (m['totalAwardedXp'] as num?)?.toInt() ?? 0
    ..awardedAt = m['awardedAt'] == null
        ? DateTime.now()
        : DateTime.parse(m['awardedAt'] as String)
    ..note = m['note'] as String?;

  String? _encodePhoto(String? photoPath) {
    if (photoPath == null) return null;
    final file = File(photoPath);
    if (!file.existsSync()) return null;
    return base64Encode(file.readAsBytesSync());
  }

  Future<String> _restorePhoto(
    String photoData,
    int activityId,
    String dateKey, {
    String? photoFileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(directory.path, 'activity_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final bytes = base64Decode(photoData);
    final extension = photoFileName != null && path.extension(photoFileName).isNotEmpty
        ? path.extension(photoFileName)
        : '.jpg';
    final fileName = '${activityId}_$dateKey$extension';
    final file = File(path.join(photosDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
