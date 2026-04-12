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

      final data = json.decode(response.body);
      final String latestTag = data['tag_name'];
      final String changelog = data['body'] ?? 'No release notes provided.';
      
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

    final Completer<void> completer = Completer<void>();

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
