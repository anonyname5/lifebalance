import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

/// Service for managing profile picture storage
class ProfilePictureService {
  static final ProfilePictureService instance = ProfilePictureService._init();
  final ImagePicker _picker = ImagePicker();

  ProfilePictureService._init();

  /// Get the directory for storing profile pictures
  Future<Directory> _getProfilePicturesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(path.join(appDir.path, 'profile_pictures'));
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    return profileDir;
  }

  /// Save profile picture from file path
  Future<String?> saveProfilePicture(String sourcePath) async {
    try {
      final profileDir = await _getProfilePicturesDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = path.join(profileDir.path, fileName);

      // Copy file to profile pictures directory
      final sourceFile = File(sourcePath);
      final destFile = await sourceFile.copy(destPath);

      // Delete old profile picture if exists
      await _deleteOldProfilePictures(destPath);

      return destFile.path;
    } catch (e) {
      print('Error saving profile picture: $e');
      return null;
    }
  }

  /// Delete old profile pictures (keep only the latest)
  Future<void> _deleteOldProfilePictures(String keepPath) async {
    try {
      final profileDir = await _getProfilePicturesDirectory();
      final files = profileDir.listSync();

      for (var file in files) {
        if (file is File && file.path != keepPath) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error deleting old profile pictures: $e');
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String? picturePath) async {
    if (picturePath == null || picturePath.isEmpty) return;

    try {
      final file = File(picturePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await saveProfilePicture(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return await saveProfilePicture(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }
}
