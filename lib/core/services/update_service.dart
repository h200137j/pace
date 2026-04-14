import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String changelog;
  final String downloadUrl;

  AppUpdateInfo({
    required this.latestVersion,
    required this.changelog,
    required this.downloadUrl,
  });
}

class UpdateService {
  static const String _repoOwner = 'h200137j';
  static const String _repoName = 'pace';
  static const String _apiBase = 'https://api.github.com/repos/$_repoOwner/$_repoName';

  /// Checks if a new version is available on GitHub.
  /// Returns [AppUpdateInfo] if an update exists, null otherwise.
  static Future<AppUpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse('$_apiBase/releases/latest'));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final String latestTag = data['tag_name'];
      final String changelog = await _resolveReleaseNotes(data);
      
      // Find the APK in assets
      final List assets = data['assets'];
      final apkAsset = assets.firstWhere(
        (a) => a['name'].toString().endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset == null) return null;
      final String downloadUrl = apkAsset['browser_download_url'];

      // Compare versions
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Strip 'v' prefix if exists
      final latestVersion = latestTag.startsWith('v') ? latestTag.substring(1) : latestTag;

      if (_isNewer(latestVersion, currentVersion)) {
        return AppUpdateInfo(
          latestVersion: latestVersion,
          changelog: changelog,
          downloadUrl: downloadUrl,
        );
      }
    } catch (e) {
      print('Update check failed: $e');
    }
    return null;
  }

  /// Downloads the APK and returns a stream of progress (0.0 to 1.0).
  /// Once complete, the stream will yield the File object.
  static Stream<dynamic> downloadUpdate(String url) async* {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);

    final total = response.contentLength ?? 0;
    int received = 0;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/update.apk');
    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) {
        yield received / total;
      }
    }

    await sink.close();
    yield file;
  }

  static Future<String> _resolveReleaseNotes(
    Map<String, dynamic> releaseData,
  ) async {
    final body = (releaseData['body'] ?? '').toString().trim();
    if (body.isNotEmpty && body.toLowerCase() != 'null') {
      return body;
    }

    final tagName = (releaseData['tag_name'] ?? '').toString();
    final annotatedTagNotes = await _fetchAnnotatedTagMessage(tagName);
    if (annotatedTagNotes != null) {
      return annotatedTagNotes;
    }

    final tag = (releaseData['tag_name'] ?? '').toString();
    final name = (releaseData['name'] ?? '').toString();
    final publishedAt = (releaseData['published_at'] ?? '').toString();
    final prerelease = releaseData['prerelease'] == true;
    final assets = (releaseData['assets'] as List?) ?? const [];

    final assetLines = assets
        .map((asset) => '- ${(asset['name'] ?? '').toString()}')
        .where((line) => line.trim().length > 2)
        .toList();

    final dateLabel = publishedAt.isEmpty
        ? 'unknown date'
        : publishedAt.split('T').first;

    final fallback = StringBuffer()
      ..writeln('## Update $tag')
      ..writeln()
      ..writeln('- Release: ${name.isEmpty ? tag : name}')
      ..writeln('- Published: $dateLabel')
      ..writeln('- Channel: ${prerelease ? 'Pre-release' : 'Stable'}')
      ..writeln();

    if (assetLines.isNotEmpty) {
      fallback.writeln('### Included Assets');
      fallback.writeln(assetLines.join('\n'));
      fallback.writeln();
    }

    fallback.writeln(
      'No release notes were provided for this version.\n'
      'Tip: add notes in the GitHub Release description so this section shows full details.',
    );

    return fallback.toString().trim();
  }

  static Future<String?> _fetchAnnotatedTagMessage(String tagName) async {
    if (tagName.trim().isEmpty) return null;

    try {
      final encodedTag = Uri.encodeComponent(tagName);
      final refResponse = await http.get(
        Uri.parse('$_apiBase/git/ref/tags/$encodedTag'),
      );
      if (refResponse.statusCode != 200) return null;

      final refData = json.decode(refResponse.body) as Map<String, dynamic>;
      final obj = refData['object'] as Map<String, dynamic>?;
      if (obj == null) return null;

      // Only annotated tags have a message payload.
      if ((obj['type'] ?? '').toString() != 'tag') return null;
      final tagSha = (obj['sha'] ?? '').toString();
      if (tagSha.isEmpty) return null;

      final tagResponse = await http.get(
        Uri.parse('$_apiBase/git/tags/$tagSha'),
      );
      if (tagResponse.statusCode != 200) return null;

      final tagData = json.decode(tagResponse.body) as Map<String, dynamic>;
      final message = (tagData['message'] ?? '').toString().trim();
      if (message.isEmpty) return null;
      return message;
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String latest, String current) {
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
