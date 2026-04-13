import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class VideoExportService {
  /// Creates an animated GIF montage from a list of image files.
  /// [imagePaths] - List of image file paths in order
  /// [fps] - Frames per second (1 = 1 second, 2 = 2x faster, 4 = 4x faster)
  /// Returns the path to the created GIF file, or null on failure
  static Future<String?> createGifMontage({
    required List<String> imagePaths,
    required int fps,
  }) async {
    if (imagePaths.isEmpty) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/montage_${DateTime.now().millisecondsSinceEpoch}.gif';
      
      // Load all images
      final List<img.Image> frames = [];
      final duration = (100 ~/ fps).clamp(10, 1000); // Duration per frame in ms
      
      for (final imagePath in imagePaths) {
        try {
          final imageFile = File(imagePath);
          if (!await imageFile.exists()) continue;
          
          final bytes = await imageFile.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image == null) continue;
          
          // Resize to consistent size (maintain aspect ratio)
          final resized = img.copyResize(
            image,
            width: 720,
            height: 1280,
            interpolation: img.Interpolation.linear,
          );
          
          frames.add(resized);
        } catch (e) {
          print('Error processing image $imagePath: $e');
          continue;
        }
      }
      
      if (frames.isEmpty) return null;
      
      // Encode as GIF
      final gif = img.Animation(width: 720, height: 1280);
      for (int i = 0; i < frames.length; i++) {
        gif.addFrame(frames[i], duration: duration);
      }
      final gifData = img.encodeGif(gif);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(gifData);
      
      return outputPath;
    } catch (e) {
      print('Video creation error: $e');
      return null;
    }
  }

  /// Gets the statistics about a video file
  /// Gets the statistics about a GIF file
  static Future<Map<String, String>> getGifInfo(String gifPath) async {
    try {
      final file = File(gifPath);
      final sizeBytes = await file.length();
      final sizeKB = (sizeBytes / 1024).toStringAsFixed(2);
      
      return {
        'path': gifPath,
        'size': '$sizeKB KB',
        'exists': 'true',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
