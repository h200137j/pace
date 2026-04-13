import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class VideoExportService {
  /// Creates a video montage from a list of image files.
  /// [imagePaths] - List of image file paths in order
  /// [fps] - Frames per second (1 = 1 second per image, 2 = 0.5 seconds per image)
  /// Returns the path to the created video file, or null on failure
  static Future<String?> createVideoMontage({
    required List<String> imagePaths,
    required int fps,
  }) async {
    if (imagePaths.isEmpty) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/montage_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Create a concat demuxer file listing all images
      final concatFile = File('${tempDir.path}/concat.txt');
      final concatContent = imagePaths
          .map((path) => "file '$path'")
          .join('\n');
      await concatFile.writeAsString(concatContent);

      // Build FFmpeg command
      // -y: overwrite output file
      // -f concat: use concat demuxer
      // -safe 0: allow absolute paths
      // -i: input concat file
      // -r: frame rate (fps parameter)
      // -vf scale: scale to common resolution
      // -c:v libx264: use H.264 codec
      // -pix_fmt yuv420p: pixel format for compatibility
      // -crf 23: quality (lower = better, 0-51)
      final ffmpegCommand =
          '-y -f concat -safe 0 -i "${concatFile.path}" '
          '-r $fps '
          '-vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" '
          '-c:v libx264 -pix_fmt yuv420p -crf 23 '
          '"$outputPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      // Cleanup concat file
      if (await concatFile.exists()) {
        await concatFile.delete();
      }

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('FFmpeg error: ${await session.getFailStackTrace()}');
        return null;
      }
    } catch (e) {
      print('Video creation error: $e');
      return null;
    }
  }

  /// Gets the statistics about a video file
  static Future<Map<String, String>> getVideoInfo(String videoPath) async {
    try {
      final file = File(videoPath);
      final sizeBytes = await file.length();
      final sizeKB = (sizeBytes / 1024).toStringAsFixed(2);
      
      return {
        'path': videoPath,
        'size': '$sizeKB KB',
        'exists': 'true',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
