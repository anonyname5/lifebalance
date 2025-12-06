import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

/// Service for managing receipt photo storage
class ReceiptPhotoService {
  static final ReceiptPhotoService instance = ReceiptPhotoService._init();
  final ImagePicker _picker = ImagePicker();

  ReceiptPhotoService._init();

  /// Get the directory for storing receipt photos
  Future<Directory> _getReceiptPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory(path.join(appDir.path, 'receipt_photos'));
    if (!await receiptDir.exists()) {
      await receiptDir.create(recursive: true);
    }
    return receiptDir;
  }

  /// Pick receipt photo from gallery
  Future<String?> pickReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        return await saveReceiptPhoto(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking receipt from gallery: $e');
      return null;
    }
  }

  /// Pick receipt photo from camera
  Future<String?> pickReceiptFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        return await saveReceiptPhoto(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking receipt from camera: $e');
      return null;
    }
  }

  /// Save receipt photo from file path
  Future<String?> saveReceiptPhoto(String sourcePath) async {
    try {
      final receiptDir = await _getReceiptPhotosDirectory();
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = path.join(receiptDir.path, fileName);

      // Copy file to receipt photos directory
      final sourceFile = File(sourcePath);
      final destFile = await sourceFile.copy(destPath);

      return destFile.path;
    } catch (e) {
      print('Error saving receipt photo: $e');
      return null;
    }
  }

  /// Delete receipt photo
  Future<bool> deleteReceiptPhoto(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return true;
    
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true;
    } catch (e) {
      print('Error deleting receipt photo: $e');
      return false;
    }
  }

  /// Check if receipt photo exists
  Future<bool> receiptPhotoExists(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return false;
    
    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
