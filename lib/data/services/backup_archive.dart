import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';

/// Name of the JSON payload inside a Pace backup zip.
const backupJsonEntry = 'pace_backup.json';

/// Writes a backup zip to [zipPath] on a background isolate.
///
/// Files are streamed from disk one at a time, so memory use stays flat no
/// matter how many photos exist. [photos] maps zip entry names to source file
/// paths. The zip is built as `<zipPath>.part` and only renamed into place once
/// its contents have been checked, so a finished file is never partial.
Future<void> writeBackupZip({
  required String zipPath,
  required String jsonPath,
  required Map<String, String> photos,
}) {
  return Isolate.run(() => _writeBackupZip(zipPath, jsonPath, photos));
}

/// Reads the JSON payload out of a backup zip.
Future<String> readBackupJson(String zipPath) {
  return Isolate.run(() => _readBackupJson(zipPath));
}

/// Extracts photos from a backup zip. [destinations] maps zip entry names to
/// output paths. Throws if an entry is missing or extracts to the wrong size.
Future<void> extractBackupPhotos({
  required String zipPath,
  required Map<String, String> destinations,
}) {
  return Isolate.run(() => _extractBackupPhotos(zipPath, destinations));
}

Future<void> _writeBackupZip(
  String zipPath,
  String jsonPath,
  Map<String, String> photos,
) async {
  final partPath = '$zipPath.part';
  try {
    final encoder = ZipFileEncoder();
    // Photos are already compressed, so storing them keeps export fast.
    encoder.create(partPath, level: ZipFileEncoder.store);
    await encoder.addFile(File(jsonPath), backupJsonEntry);
    for (final photo in photos.entries) {
      await encoder.addFile(File(photo.value), photo.key);
    }
    await encoder.close();

    _verifyBackupZip(partPath, {
      backupJsonEntry: jsonPath,
      ...photos,
    });
    await File(partPath).rename(zipPath);
  } catch (_) {
    final part = File(partPath);
    if (await part.exists()) await part.delete();
    rethrow;
  }
}

void _verifyBackupZip(String zipPath, Map<String, String> expected) {
  final input = InputFileStream(zipPath);
  try {
    final archive = ZipDecoder().decodeStream(input);
    if (archive.length != expected.length) {
      throw FileSystemException(
        'Backup has ${archive.length} entries, expected ${expected.length}',
        zipPath,
      );
    }
    for (final item in expected.entries) {
      final entry = archive.findFile(item.key);
      if (entry == null || entry.size != File(item.value).lengthSync()) {
        throw FileSystemException(
          'Backup entry is missing or incomplete: ${item.key}',
          zipPath,
        );
      }
    }
  } finally {
    input.closeSync();
  }
}

String _readBackupJson(String zipPath) {
  final input = InputFileStream(zipPath);
  try {
    final entry = ZipDecoder().decodeStream(input).findFile(backupJsonEntry);
    final bytes = entry?.readBytes();
    if (bytes == null) {
      throw const FormatException('Not a Pace backup: $backupJsonEntry missing');
    }
    return utf8.decode(bytes);
  } finally {
    input.closeSync();
  }
}

void _extractBackupPhotos(String zipPath, Map<String, String> destinations) {
  final input = InputFileStream(zipPath);
  try {
    final archive = ZipDecoder().decodeStream(input);
    for (final item in destinations.entries) {
      final entry = archive.findFile(item.key);
      if (entry == null) {
        throw FormatException('Backup is missing photo: ${item.key}');
      }

      final partPath = '${item.value}.part';
      final output = OutputFileStream(partPath);
      entry.writeContent(output);
      output.closeSync();

      final part = File(partPath);
      if (part.lengthSync() != entry.size) {
        part.deleteSync();
        throw FormatException('Backup photo is incomplete: ${item.key}');
      }
      part.renameSync(item.value);
    }
  } finally {
    input.closeSync();
  }
}
