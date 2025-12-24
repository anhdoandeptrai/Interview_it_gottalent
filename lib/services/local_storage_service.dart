import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static const String _pdfFolderName = 'pdfs';
  static const String _audioFolderName = 'audio';

  // Get app documents directory
  Future<Directory> _getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Create folder if not exists
  Future<Directory> _createFolder(String folderName) async {
    final appDir = await _getAppDirectory();
    final folder = Directory(path.join(appDir.path, folderName));

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folder;
  }

  // Save PDF file locally
  Future<String> savePdfFile(
      File pdfFile, String userId, String sessionId) async {
    try {
      print('💾 Saving PDF locally...');

      // Create PDF folder
      final pdfFolder =
          await _createFolder('$_pdfFolderName/$userId/$sessionId');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'pdf_$timestamp.pdf';
      final localPath = path.join(pdfFolder.path, fileName);

      // Copy file to local storage
      await pdfFile.copy(localPath);

      print('✅ PDF saved locally: $localPath');
      return localPath;
    } catch (e) {
      print('❌ Error saving PDF locally: $e');
      throw Exception('Failed to save PDF locally: $e');
    }
  }

  // Save audio file locally
  Future<String> saveAudioFile(File audioFile, String userId, String sessionId,
      String questionId) async {
    try {
      print('💾 Saving audio locally...');

      // Create audio folder
      final audioFolder =
          await _createFolder('$_audioFolderName/$userId/$sessionId');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'audio_${questionId}_$timestamp.m4a';
      final localPath = path.join(audioFolder.path, fileName);

      // Copy file to local storage
      await audioFile.copy(localPath);

      print('✅ Audio saved locally: $localPath');
      return localPath;
    } catch (e) {
      print('❌ Error saving audio locally: $e');
      throw Exception('Failed to save audio locally: $e');
    }
  }

  // Get PDF file from local storage
  Future<File?> getPdfFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Error getting PDF file: $e');
      return null;
    }
  }

  // Get audio file from local storage
  Future<File?> getAudioFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Error getting audio file: $e');
      return null;
    }
  }

  // Delete PDF file
  Future<bool> deletePdfFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ PDF deleted: $localPath');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting PDF: $e');
      return false;
    }
  }

  // Delete audio file
  Future<bool> deleteAudioFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Audio deleted: $localPath');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting audio: $e');
      return false;
    }
  }

  // Get storage usage
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final appDir = await _getAppDirectory();
      int totalSize = 0;
      int fileCount = 0;

      await for (FileSystemEntity entity in appDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
          fileCount++;
        }
      }

      return {
        'totalSize': totalSize,
        'fileCount': fileCount,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Error getting storage usage: $e');
      return {'totalSize': 0, 'fileCount': 0, 'totalSizeMB': '0.00'};
    }
  }

  // Clear all local data
  Future<void> clearAllData() async {
    try {
      final appDir = await _getAppDirectory();

      // Delete PDF folder
      final pdfFolder = Directory(path.join(appDir.path, _pdfFolderName));
      if (await pdfFolder.exists()) {
        await pdfFolder.delete(recursive: true);
      }

      // Delete audio folder
      final audioFolder = Directory(path.join(appDir.path, _audioFolderName));
      if (await audioFolder.exists()) {
        await audioFolder.delete(recursive: true);
      }

      print('🧹 All local data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
