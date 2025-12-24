import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/practice_session.dart';

class HybridStorageService {
  static const String _dataFileName = 'app_data.json';
  static const String _pdfFolderName = 'pdfs';
  static const String _audioFolderName = 'audio';

  // Get app documents directory
  Future<Directory> _getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get data file
  Future<File> _getDataFile() async {
    final appDir = await _getAppDirectory();
    return File(path.join(appDir.path, _dataFileName));
  }

  // Load data from JSON file
  Future<Map<String, dynamic>> _loadData() async {
    try {
      final dataFile = await _getDataFile();
      if (await dataFile.exists()) {
        final jsonString = await dataFile.readAsString();
        return json.decode(jsonString);
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    }

    // Return default structure
    return {
      'users': {},
      'sessions': {},
      'answers': {},
    };
  }

  // Save data to JSON file
  Future<void> _saveData(Map<String, dynamic> data) async {
    try {
      final dataFile = await _getDataFile();
      final jsonString = json.encode(data);
      await dataFile.writeAsString(jsonString);
      print('💾 Data saved to local JSON file');
    } catch (e) {
      print('❌ Error saving data: $e');
      throw Exception('Failed to save data locally: $e');
    }
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

  // Save PDF file and return local path
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

  // Save user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final data = await _loadData();
    data['users'][userData['uid']] = userData;
    await _saveData(data);
    print('💾 User saved locally');
  }

  // Get user data
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final data = await _loadData();
    return data['users'][uid];
  }

  // Save practice session
  Future<void> savePracticeSession(
      PracticeSession session, String pdfLocalPath) async {
    final data = await _loadData();

    // Convert session to map and add local path
    final sessionMap = session.toMap();
    sessionMap['pdfLocalPath'] = pdfLocalPath;
    sessionMap['pdfUrl'] = pdfLocalPath; // Use local path as URL

    data['sessions'][session.id] = sessionMap;
    await _saveData(data);
    print('💾 Practice session saved locally');
  }

  // Get practice session
  Future<PracticeSession?> getPracticeSession(String sessionId) async {
    final data = await _loadData();
    final sessionData = data['sessions'][sessionId];

    if (sessionData != null) {
      return PracticeSession.fromMap(sessionData);
    }
    return null;
  }

  // Get user's practice sessions
  Future<List<PracticeSession>> getUserPracticeSessions(String userId) async {
    final data = await _loadData();
    final sessions = <PracticeSession>[];

    for (String sessionId in data['sessions'].keys) {
      final sessionData = data['sessions'][sessionId];
      if (sessionData['userId'] == userId) {
        sessions.add(PracticeSession.fromMap(sessionData));
      }
    }

    // Sort by start time (newest first)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  // Update practice session
  Future<void> updatePracticeSession(PracticeSession session) async {
    final data = await _loadData();
    data['sessions'][session.id] = session.toMap();
    await _saveData(data);
    print('📝 Practice session updated locally');
  }

  // Save answer
  Future<void> saveAnswer(Answer answer, String sessionId) async {
    final data = await _loadData();

    if (data['answers'][sessionId] == null) {
      data['answers'][sessionId] = [];
    }

    data['answers'][sessionId].add(answer.toMap());
    await _saveData(data);
    print('💾 Answer saved locally');
  }

  // Get session answers
  Future<List<Answer>> getSessionAnswers(String sessionId) async {
    final data = await _loadData();
    final answersData = data['answers'][sessionId] ?? [];

    return answersData
        .map<Answer>((answerData) => Answer.fromMap(answerData))
        .toList();
  }

  // Delete practice session
  Future<void> deletePracticeSession(String sessionId) async {
    final data = await _loadData();

    // Get session data to find PDF path
    final sessionData = data['sessions'][sessionId];
    if (sessionData != null && sessionData['pdfLocalPath'] != null) {
      // Delete PDF file
      try {
        final pdfFile = File(sessionData['pdfLocalPath']);
        if (await pdfFile.exists()) {
          await pdfFile.delete();
          print('🗑️ PDF file deleted');
        }
      } catch (e) {
        print('⚠️ Error deleting PDF file: $e');
      }
    }

    // Delete from data
    data['sessions'].remove(sessionId);
    data['answers'].remove(sessionId);

    await _saveData(data);
    print('🗑️ Practice session deleted locally');
  }

  // Get storage statistics
  Future<Map<String, dynamic>> getStorageStatistics() async {
    try {
      final appDir = await _getAppDirectory();
      int totalSize = 0;
      int fileCount = 0;
      int pdfCount = 0;
      int audioCount = 0;

      await for (FileSystemEntity entity in appDir.list(recursive: true)) {
        if (entity is File) {
          final size = await entity.length();
          totalSize += size;
          fileCount++;

          if (entity.path.endsWith('.pdf')) pdfCount++;
          if (entity.path.endsWith('.m4a') || entity.path.endsWith('.wav'))
            audioCount++;
        }
      }

      return {
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'fileCount': fileCount,
        'pdfCount': pdfCount,
        'audioCount': audioCount,
      };
    } catch (e) {
      print('❌ Error getting storage statistics: $e');
      return {
        'totalSize': 0,
        'totalSizeMB': '0.00',
        'fileCount': 0,
        'pdfCount': 0,
        'audioCount': 0,
      };
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final sessions = await getUserPracticeSessions(userId);
    final completedSessions = sessions.where((s) => s.isCompleted).toList();

    if (completedSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'averageScore': 0.0,
        'recentSessions': [],
        'practiceTime': 0,
      };
    }

    // Calculate average score
    double totalScore = 0;
    int answerCount = 0;
    int totalPracticeMinutes = 0;

    for (final session in completedSessions) {
      for (final answer in session.answers) {
        totalScore += answer.score;
        answerCount++;
      }

      if (session.endTime != null) {
        final duration = session.endTime!.difference(session.startTime);
        totalPracticeMinutes += duration.inMinutes;
      }
    }

    return {
      'totalSessions': completedSessions.length,
      'averageScore': answerCount > 0 ? totalScore / answerCount : 0.0,
      'recentSessions': completedSessions.take(5).toList(),
      'practiceTime': totalPracticeMinutes,
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      // Delete JSON data file
      final dataFile = await _getDataFile();
      if (await dataFile.exists()) {
        await dataFile.delete();
      }

      // Delete all folders
      final appDir = await _getAppDirectory();

      final pdfFolder = Directory(path.join(appDir.path, _pdfFolderName));
      if (await pdfFolder.exists()) {
        await pdfFolder.delete(recursive: true);
      }

      final audioFolder = Directory(path.join(appDir.path, _audioFolderName));
      if (await audioFolder.exists()) {
        await audioFolder.delete(recursive: true);
      }

      print('🧹 All local data and files cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // Export data to JSON (for backup)
  Future<String?> exportData() async {
    try {
      final data = await _loadData();
      return json.encode(data);
    } catch (e) {
      print('❌ Error exporting data: $e');
      return null;
    }
  }

  // Import data from JSON (for restore)
  Future<bool> importData(String jsonData) async {
    try {
      final data = json.decode(jsonData);
      await _saveData(data);
      print('📥 Data imported successfully');
      return true;
    } catch (e) {
      print('❌ Error importing data: $e');
      return false;
    }
  }
}
