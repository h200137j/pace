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
import 'backup_archive.dart';

/// Outcome of writing a backup zip.
class BackupResult {
  const BackupResult({
    required this.path,
    required this.photoCount,
    required this.missingPhotoCount,
  });

  final String path;
  final int photoCount;

  /// Completions whose photo file was no longer on disk.
  final int missingPhotoCount;
}

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
      'version': 3,
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

  static String _exportFileName(String extension) {
    final now = DateTime.now();
    final stamp = '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}';
    return 'pace_$stamp.$extension';
  }

  /// Share backup zip via system share sheet.
  Future<BackupResult> shareBackup() async {
    final dir = await getTemporaryDirectory();
    await _deleteOldBackups(dir);
    final result = await createBackupZip(dir.path);
    await Share.shareXFiles([XFile(result.path)], text: 'Pace backup');
    return result;
  }

  /// Save backup zip to app-specific external storage.
  ///
  /// Android removes this folder when the app is uninstalled, so the zip must
  /// be moved off the device first.
  Future<BackupResult> saveBackupToDevice() async {
    final external = await getExternalStorageDirectory();
    if (external == null) {
      throw const FileSystemException('External storage is unavailable');
    }
    final dir = Directory(path.join(external.path, 'backups'));
    await dir.create(recursive: true);
    return createBackupZip(dir.path);
  }

  /// Writes the JSON payload and photo files to a zip in [outputDirPath].
  Future<BackupResult> createBackupZip(String outputDirPath) async {
    final payload = await buildExportPayload();
    final photos = <String, String>{};
    var missingPhotoCount = 0;
    final completions = (payload['completions'] as List)
        .cast<Map<String, dynamic>>();
    for (final completion in completions) {
      final photoPath = completion['photoPath'] as String?;
      final entry = completion['photoEntry'] as String?;
      if (entry != null) {
        photos[entry] = photoPath!;
      } else if (photoPath != null) {
        missingPhotoCount++;
      }
    }

    final zipPath = path.join(outputDirPath, _exportFileName('zip'));
    final jsonFile = File('$zipPath.json');
    try {
      await jsonFile.writeAsString(jsonEncode(payload));
      await writeBackupZip(
        zipPath: zipPath,
        jsonPath: jsonFile.path,
        photos: photos,
      );
    } finally {
      if (await jsonFile.exists()) await jsonFile.delete();
    }

    return BackupResult(
      path: zipPath,
      photoCount: photos.length,
      missingPhotoCount: missingPhotoCount,
    );
  }

  /// Restores from a user-picked backup zip or legacy JSON file.
  Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );
    final picked = result?.files.single.path;
    if (picked == null) return false;

    if (path.extension(picked).toLowerCase() == '.zip') {
      await importZip(picked);
    } else {
      final raw = await File(picked).readAsString();
      await importFromPayload(jsonDecode(raw) as Map<String, dynamic>);
    }
    return true;
  }

  /// Restores from a backup zip. Photos are extracted and checked before any
  /// database record is written. [photosDirPath] defaults to app storage.
  Future<void> importZip(String zipPath, {String? photosDirPath}) async {
    final payload =
        jsonDecode(await readBackupJson(zipPath)) as Map<String, dynamic>;
    final photosDir = photosDirPath ?? (await _photosDirectory()).path;

    final destinations = <String, String>{};
    final completions = (payload['completions'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    for (final completion in completions) {
      final entry = completion['photoEntry'] as String?;
      if (entry == null) continue;
      destinations[entry] = path.join(
        photosDir,
        _photoFileName(
          completion['activityId'] as int,
          completion['dateKey'] as String,
          completion['photoFileName'] as String?,
        ),
      );
    }

    await extractBackupPhotos(zipPath: zipPath, destinations: destinations);
    await importFromPayload(payload, extractedPhotos: destinations);
  }

  Future<void> importFromPayload(
    Map<String, dynamic> payload, {
    Map<String, String> extractedPhotos = const {},
  }) async {
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
      comps.add(await _completionFromImportMap(map, extractedPhotos));
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

  /// Clears earlier shared backups so they do not pile up in the cache.
  Future<void> _deleteOldBackups(Directory dir) async {
    await for (final item in dir.list()) {
      final name = path.basename(item.path);
      if (item is File && name.startsWith('pace_') && name.endsWith('.zip')) {
        await item.delete();
      }
    }
  }

  Future<Directory> _photosDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(directory.path, 'activity_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  static String _photoFileName(
    int activityId,
    String dateKey,
    String? sourceName,
  ) {
    final extension = sourceName != null && path.extension(sourceName).isNotEmpty
        ? path.extension(sourceName)
        : '.jpg';
    return path.basename('${activityId}_$dateKey$extension');
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
        'requiresPhoto': a.requiresPhoto,
        'dailyCheckInTarget': a.dailyCheckInTarget,
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
    ..requiresPhoto = m['requiresPhoto'] as bool? ?? false
    ..dailyCheckInTarget = (m['dailyCheckInTarget'] as num?)?.toInt() ?? 1
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
        'checkInCount': c.checkInCount,
        'completedAt': c.completedAt.toIso8601String(),
        'photoPath': c.photoPath,
        'photoFileName': c.photoPath != null ? path.basename(c.photoPath!) : null,
        'photoEntry': _photoEntryName(c),
        'note': c.note,
      };

  /// Zip entry for a completion's photo, or null if there is no file on disk.
  /// The id prefix keeps entry names unique.
  String? _photoEntryName(Completion c) {
    final photoPath = c.photoPath;
    if (photoPath == null || !File(photoPath).existsSync()) return null;
    return 'photos/${c.id}_${path.basename(photoPath)}';
  }

  Completion _completionFromMap(Map<String, dynamic> m) => Completion()
    ..id = m['id'] as int
    ..activityId = m['activityId'] as int
    ..dateKey = m['dateKey'] as String
    ..checkInCount = (m['checkInCount'] as num?)?.toInt() ?? 1
    ..completedAt = DateTime.parse(m['completedAt'] as String)
    ..photoPath = m['photoPath'] as String?
    ..note = m['note'] as String?;

  Future<Completion> _completionFromImportMap(
    Map<String, dynamic> m,
    Map<String, String> extractedPhotos,
  ) async {
    final completion = _completionFromMap(m);
    final extractedPath = extractedPhotos[m['photoEntry']];
    if (extractedPath != null) {
      completion.photoPath = extractedPath;
      return completion;
    }

    // Backups before version 3 embed photos as base64.
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

  Future<String> _restorePhoto(
    String photoData,
    int activityId,
    String dateKey, {
    String? photoFileName,
  }) async {
    final photosDir = await _photosDirectory();
    final bytes = base64Decode(photoData);
    final fileName = _photoFileName(activityId, dateKey, photoFileName);
    final file = File(path.join(photosDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
