import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import '../models/activity.dart';
import '../models/completion.dart';
import '../repositories/activity_repository.dart';
import '../repositories/completion_repository.dart';

class ExportService {
  ExportService({
    required ActivityRepository activityRepo,
    required CompletionRepository completionRepo,
  })  : _actRepo = activityRepo,
        _compRepo = completionRepo;

  final ActivityRepository _actRepo;
  final CompletionRepository _compRepo;

  // ── JSON Export ────────────────────────────────────────────────────────────

  Future<void> exportJson() async {
    final activities = await _actRepo.getAllIncludingArchived();
    final completions = await _compRepo.getAll();

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'activities': activities.map(_activityToMap).toList(),
      'completions': completions.map(_completionToMap).toList(),
    };

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

    final acts = (payload['activities'] as List)
        .map((e) => _activityFromMap(e as Map<String, dynamic>))
        .toList();

    for (final a in acts) {
      await _actRepo.update(a);
    }

    final comps = <Completion>[];
    for (final e in payload['completions'] as List) {
      final map = e as Map<String, dynamic>;
      final completion = _completionFromMap(map);
      final photoData = map['photoData'] as String?;
      final photoFileName = map['photoFileName'] as String?;
      if (photoData != null) {
        completion.photoPath = await _restorePhoto(
          photoData,
          completion.activityId,
          completion.dateKey,
          photoFileName: photoFileName,
        );
      }
      comps.add(completion);
    }

    await _compRepo.importBatch(comps);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<File> _writeTemp(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file;
  }

  Map<String, dynamic> _activityToMap(Activity a) => {
        'id': a.id,
        'name': a.name,
        'type': a.type.name,
        'colorValue': a.colorValue,
        'iconCodePoint': a.iconCodePoint,
        'targetDaysMask': a.targetDaysMask,
        'createdAt': a.createdAt.toIso8601String(),
        'archivedAt': a.archivedAt?.toIso8601String(),
      };

  Activity _activityFromMap(Map<String, dynamic> m) => Activity()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..type = ActivityType.values.byName(m['type'] as String)
    ..colorValue = m['colorValue'] as int
    ..iconCodePoint = m['iconCodePoint'] as int
    ..targetDaysMask = m['targetDaysMask'] as int
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
