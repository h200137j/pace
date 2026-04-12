import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  static final PhotoService instance = PhotoService._();
  PhotoService._();

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from camera or gallery.
  /// Standardizes on high quality for montages.
  Future<File?> pickImage({required bool fromCamera}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100, // Maintain high quality as requested
    );

    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  /// Copies a temporary picked image to permanent app storage.
  /// Returns the relative path for database storage.
  Future<String> saveImageToAppStorage(File file, String dateKey, int activityId) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(directory.path, 'activity_photos'));
    
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Filename format: activityID_dateKey.jpg
    final extension = path.extension(file.path);
    final fileName = '${activityId}_$dateKey$extension';
    final savedFile = await file.copy(path.join(photosDir.path, fileName));

    return savedFile.path;
  }

  /// Deletes an image from storage.
  Future<void> deleteImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
