import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/practice_session.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Test Firebase Storage connectivity
  Future<bool> testStorageConnectivity() async {
    try {
      print('Testing Firebase Storage connectivity...');

      // Check Storage instance
      print('Storage bucket: ${_storage.bucket}');
      print('Storage app: ${_storage.app.name}');
      print('Storage app options: ${_storage.app.options}');

      // Try to create a reference
      Reference testRef = _storage.ref().child('test/connectivity_test.txt');
      print('Test reference created: ${testRef.fullPath}');

      return true;
    } catch (e) {
      print('Storage connectivity test failed: $e');
      return false;
    }
  }

  // Save practice session to Firestore
  Future<void> savePracticeSession(PracticeSession session) async {
    try {
      await _firestore
          .collection('practice_sessions')
          .doc(session.id)
          .set(session.toMap());
    } catch (e) {
      print('Error saving practice session: $e');
      rethrow;
    }
  }

  // Update practice session
  Future<void> updatePracticeSession(PracticeSession session) async {
    try {
      await _firestore
          .collection('practice_sessions')
          .doc(session.id)
          .update(session.toMap());
    } catch (e) {
      print('Error updating practice session: $e');
      rethrow;
    }
  }

  // Get practice session by ID
  Future<PracticeSession?> getPracticeSession(String sessionId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('practice_sessions').doc(sessionId).get();

      if (doc.exists) {
        return PracticeSession.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting practice session: $e');
      return null;
    }
  }

  // Get user's practice sessions
  Future<List<PracticeSession>> getUserPracticeSessions(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('practice_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                PracticeSession.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting user practice sessions: $e');
      return [];
    }
  }

  // Upload PDF file to Firebase Storage with retry mechanism
  Future<String?> uploadPdfFile(
    File pdfFile,
    String userId,
    String sessionId, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('Starting PDF upload attempt $attempt/$maxRetries...');
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

        // Check Firebase Storage instance
        print('Firebase Storage instance: $_storage');
        print('Storage bucket: ${_storage.bucket}');
        print('Storage app: ${_storage.app.name}');

        // Test basic Storage connectivity
        try {
          Reference testRef = _storage.ref().child('test.txt');
          print('Test reference created successfully: ${testRef.fullPath}');
        } catch (e) {
          print('Error creating test reference: $e');
          throw Exception('Firebase Storage connectivity issue: $e');
        }

        // Create unique filename
        String fileName =
            'pdfs/$userId/$sessionId/${DateTime.now().millisecondsSinceEpoch}.pdf';

        print('Upload path: $fileName');

        Reference ref = _storage.ref().child(fileName);
        print('Storage reference created: ${ref.fullPath}');
        print('Reference bucket: ${ref.bucket}');
        print('Reference name: ${ref.name}');

        // Set metadata
        SettableMetadata metadata = SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': userId,
            'sessionId': sessionId,
            'uploadTime': DateTime.now().toIso8601String(),
            'fileSize': fileSize.toString(),
          },
        );

        print('Starting upload task...');
        UploadTask uploadTask = ref.putFile(pdfFile, metadata);

        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
        });

        // Wait for upload completion with timeout
        TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw Exception('Upload timeout after 5 minutes');
          },
        );

        print('Upload completed. Getting download URL...');

        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL obtained: $downloadUrl');

        // Verify the uploaded file exists
        try {
          await ref.getMetadata();
          print('Upload verification successful');
        } catch (e) {
          throw Exception('Upload verification failed: $e');
        }

        return downloadUrl;
      } catch (e) {
        print('Error uploading PDF file (attempt $attempt): $e');
        if (e is FirebaseException) {
          print('Firebase error code: ${e.code}');
          print('Firebase error message: ${e.message}');
          print('Firebase error details: ${e.plugin}');
        }

        // If this is the last attempt, return null
        if (attempt == maxRetries) {
          print('All upload attempts failed');
          return null;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
        print('Retrying upload in ${attempt * 2} seconds...');
      }
    }
    return null;
  }

  // Upload audio file to Firebase Storage
  Future<String?> uploadAudioFile(
    File audioFile,
    String userId,
    String sessionId,
    String questionId,
  ) async {
    try {
      String fileName = 'audio/$userId/$sessionId/$questionId.wav';

      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(audioFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      return null;
    }
  }

  // Delete practice session
  Future<void> deletePracticeSession(String sessionId) async {
    try {
      // Get session data first to delete associated files
      PracticeSession? session = await getPracticeSession(sessionId);

      if (session != null) {
        // Delete PDF file
        if (session.pdfUrl.isNotEmpty) {
          await _deleteFileFromUrl(session.pdfUrl);
        }

        // Delete audio files
        for (Answer answer in session.answers) {
          if (answer.audioUrl.isNotEmpty) {
            await _deleteFileFromUrl(answer.audioUrl);
          }
        }
      }

      // Delete Firestore document
      await _firestore.collection('practice_sessions').doc(sessionId).delete();
    } catch (e) {
      print('Error deleting practice session: $e');
      rethrow;
    }
  }

  // Delete file from Firebase Storage using URL
  Future<void> _deleteFileFromUrl(String url) async {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file from storage: $e');
      // Don't rethrow, as this is not critical
    }
  }

  // Get practice session statistics for user
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('practice_sessions')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      List<PracticeSession> sessions = querySnapshot.docs
          .map(
            (doc) =>
                PracticeSession.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'averageScore': 0.0,
          'totalPracticeTime': 0,
          'interviewSessions': 0,
          'presentationSessions': 0,
          'averageSpeakingSpeed': 0.0,
          'averageClarity': 0.0,
          'averageEyeContact': 0.0,
        };
      }

      int totalSessions = sessions.length;
      int interviewSessions =
          sessions.where((s) => s.mode == PracticeMode.interview).length;
      int presentationSessions =
          sessions.where((s) => s.mode == PracticeMode.presentation).length;

      double averageScore = sessions
              .map((s) => s.analytics.averageScore)
              .reduce((a, b) => a + b) /
          totalSessions;

      int totalPracticeTime = sessions
          .map((s) => s.analytics.totalDuration.inMinutes)
          .reduce((a, b) => a + b);

      double averageSpeakingSpeed = sessions
              .map((s) => s.analytics.averageSpeakingSpeed)
              .reduce((a, b) => a + b) /
          totalSessions;

      double averageClarity = sessions
              .map((s) => s.analytics.averageClarity)
              .reduce((a, b) => a + b) /
          totalSessions;

      double averageEyeContact = sessions
              .map((s) => s.analytics.averageEyeContactRatio)
              .reduce((a, b) => a + b) /
          totalSessions;

      return {
        'totalSessions': totalSessions,
        'averageScore': averageScore,
        'totalPracticeTime': totalPracticeTime,
        'interviewSessions': interviewSessions,
        'presentationSessions': presentationSessions,
        'averageSpeakingSpeed': averageSpeakingSpeed,
        'averageClarity': averageClarity,
        'averageEyeContact': averageEyeContact,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {};
    }
  }

  // Stream of user's practice sessions for real-time updates
  Stream<List<PracticeSession>> streamUserPracticeSessions(String userId) {
    return _firestore
        .collection('practice_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PracticeSession.fromMap(doc.data()))
              .toList(),
        );
  }

  // Search practice sessions
  Future<List<PracticeSession>> searchPracticeSessions({
    required String userId,
    PracticeMode? mode,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('practice_sessions')
          .where('userId', isEqualTo: userId);

      if (mode != null) {
        query = query.where('mode', isEqualTo: mode.toString());
      }

      if (startDate != null) {
        query = query.where(
          'startTime',
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
        );
      }

      if (endDate != null) {
        query = query.where(
          'startTime',
          isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
        );
      }

      QuerySnapshot querySnapshot =
          await query.orderBy('startTime', descending: true).get();

      return querySnapshot.docs
          .map(
            (doc) =>
                PracticeSession.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error searching practice sessions: $e');
      return [];
    }
  }
}
