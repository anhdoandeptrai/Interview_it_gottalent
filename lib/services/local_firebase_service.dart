import 'dart:io';
import '../models/practice_session.dart';
import 'hybrid_storage_service.dart';

class LocalFirebaseService {
  final HybridStorageService _localService = HybridStorageService();

  // Save practice session to local storage
  Future<void> savePracticeSession(PracticeSession session) async {
    try {
      await _localService.savePracticeSession(session, session.pdfUrl);
      print('✅ Practice session saved locally');
    } catch (e) {
      print('❌ Error saving practice session: $e');
      rethrow;
    }
  }

  // Update practice session
  Future<void> updatePracticeSession(PracticeSession session) async {
    try {
      await _localService.updatePracticeSession(session);
      print('✅ Practice session updated locally');
    } catch (e) {
      print('❌ Error updating practice session: $e');
      rethrow;
    }
  }

  // Get practice session by ID
  Future<PracticeSession?> getPracticeSession(String sessionId) async {
    try {
      return await _localService.getPracticeSession(sessionId);
    } catch (e) {
      print('❌ Error getting practice session: $e');
      return null;
    }
  }

  // Get user's practice sessions
  Future<List<PracticeSession>> getUserPracticeSessions(String userId) async {
    try {
      return await _localService.getUserPracticeSessions(userId);
    } catch (e) {
      print('❌ Error getting user practice sessions: $e');
      return [];
    }
  }

  // Upload PDF file to local storage (FREE!)
  Future<String?> uploadPdfFile(
    File pdfFile,
    String userId,
    String sessionId, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('💾 Starting local PDF save attempt $attempt/$maxRetries...');
        print('File path: ${pdfFile.path}');
        print('File exists: ${await pdfFile.exists()}');
        print('File size: ${await pdfFile.length()} bytes');
        print('User ID: $userId');
        print('Session ID: $sessionId');

        // Check if file exists and is readable
        if (!await pdfFile.exists()) {
          throw Exception('PDF file does not exist');
        }

        final fileSize = await pdfFile.length();
        if (fileSize == 0) {
          throw Exception('PDF file is empty');
        }

        // Save to local storage
        String localPath =
            await _localService.savePdfFile(pdfFile, userId, sessionId);

        print('✅ PDF saved locally: $localPath');
        return localPath; // Return local path as "URL"
      } catch (e) {
        print('❌ Error saving PDF locally (attempt $attempt): $e');

        // If this is the last attempt, return null
        if (attempt == maxRetries) {
          print('All save attempts failed');
          return null;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
        print('Retrying save in ${attempt * 2} seconds...');
      }
    }
    return null;
  }

  // Save audio file locally (FREE!)
  Future<String?> uploadAudioFile(
    File audioFile,
    String userId,
    String sessionId,
    String questionId,
  ) async {
    try {
      print('💾 Saving audio file locally...');

      // For now, just return the local path
      // You can implement actual local audio saving later
      return audioFile.path;
    } catch (e) {
      print('❌ Error saving audio file: $e');
      return null;
    }
  }

  // Delete practice session
  Future<void> deletePracticeSession(String sessionId) async {
    try {
      await _localService.deletePracticeSession(sessionId);
      print('✅ Practice session deleted');
    } catch (e) {
      print('❌ Error deleting practice session: $e');
      rethrow;
    }
  }

  // Get practice session statistics for user
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      return await _localService.getUserStatistics(userId);
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {
        'totalSessions': 0,
        'averageScore': 0.0,
        'recentSessions': [],
        'practiceTime': 0,
      };
    }
  }

  // Get storage usage (FREE monitoring!)
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      return await _localService.getStorageStatistics();
    } catch (e) {
      print('❌ Error getting storage usage: $e');
      return {
        'totalSize': 0,
        'totalSizeMB': '0.00',
        'fileCount': 0,
        'pdfCount': 0,
        'audioCount': 0,
      };
    }
  }

  // Test local storage connectivity (always works!)
  Future<bool> testStorageConnectivity() async {
    try {
      print('🧪 Testing local storage connectivity...');

      // Test writing and reading
      await _localService.saveUser({
        'uid': 'test_user',
        'email': 'test@test.com',
        'displayName': 'Test User',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      final user = await _localService.getUser('test_user');
      print('✅ Local storage test passed: ${user != null}');

      return user != null;
    } catch (e) {
      print('❌ Local storage test failed: $e');
      return false;
    }
  }

  // Export data for backup
  Future<String?> exportAllData() async {
    try {
      return await _localService.exportData();
    } catch (e) {
      print('❌ Error exporting data: $e');
      return null;
    }
  }

  // Import data from backup
  Future<bool> importAllData(String jsonData) async {
    try {
      return await _localService.importData(jsonData);
    } catch (e) {
      print('❌ Error importing data: $e');
      return false;
    }
  }

  // Clear all local data
  Future<void> clearAllData() async {
    try {
      await _localService.clearAllData();
      print('✅ All local data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  // Stream of user's practice sessions (simulated)
  Stream<List<PracticeSession>> streamUserPracticeSessions(
      String userId) async* {
    try {
      // Yield initial data
      yield await getUserPracticeSessions(userId);

      // For local storage, we can't have real-time updates
      // But we can check periodically
      while (true) {
        await Future.delayed(Duration(seconds: 5));
        yield await getUserPracticeSessions(userId);
      }
    } catch (e) {
      print('❌ Error in stream: $e');
      yield [];
    }
  }

  // Search practice sessions
  Future<List<PracticeSession>> searchPracticeSessions({
    required String userId,
    String? query,
    PracticeMode? mode,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allSessions = await getUserPracticeSessions(userId);

      return allSessions.where((session) {
        // Filter by mode
        if (mode != null && session.mode != mode) return false;

        // Filter by date range
        if (startDate != null && session.startTime.isBefore(startDate))
          return false;
        if (endDate != null && session.startTime.isAfter(endDate)) return false;

        // Filter by query (search in PDF filename)
        if (query != null && query.isNotEmpty) {
          return session.pdfFileName
              .toLowerCase()
              .contains(query.toLowerCase());
        }

        return true;
      }).toList();
    } catch (e) {
      print('❌ Error searching sessions: $e');
      return [];
    }
  }
}
