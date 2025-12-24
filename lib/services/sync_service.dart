import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/practice_session.dart';

/// Service để đồng bộ dữ liệu giữa các màn hình và Firebase
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Lưu practice session vào Firestore với cấu trúc đúng
  Future<void> savePracticeSession(PracticeSession session) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lưu vào collection users/{userId}/practice_sessions
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('practice_sessions')
          .doc(session.id)
          .set({
        'id': session.id,
        'userId': userId,
        'type': session.mode.toString().split('.').last,
        'mode': session.mode.toString().split('.').last,
        'score': session.averageScore,
        'duration': session.endTime != null
            ? session.endTime!.difference(session.startTime).inSeconds
            : 0,
        'startTime': session.startTime,
        'endTime': session.endTime,
        'pdfUrl': session.pdfUrl,
        'pdfFileName': session.pdfFileName,
        'questions': session.questions,
        'answersCount': session.answers.length,
        'isCompleted': session.isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Cập nhật statistics trong user document
      await updateUserStatistics(userId);

      print('✅ Practice session saved to Firestore');
    } catch (e) {
      print('❌ Error saving practice session: $e');
      rethrow;
    }
  }

  /// Cập nhật thống kê người dùng
  Future<void> updateUserStatistics(String userId) async {
    try {
      // Lấy tất cả sessions
      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('practice_sessions')
          .get();

      if (sessionsSnapshot.docs.isEmpty) return;

      int totalSessions = sessionsSnapshot.docs.length;
      double totalScore = 0;
      int totalDuration = 0;

      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data();
        totalScore += (data['score'] ?? 0).toDouble();
        totalDuration += (data['duration'] ?? 0) as int;
      }

      double averageScore = totalScore / totalSessions;
      int totalMinutes = (totalDuration / 60).round();

      // Cập nhật statistics trong user document
      await _firestore.collection('users').doc(userId).set({
        'statistics': {
          'totalSessions': totalSessions,
          'totalMinutes': totalMinutes,
          'averageScore': averageScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      print('✅ User statistics updated');
    } catch (e) {
      print('❌ Error updating statistics: $e');
    }
  }

  /// Lấy practice sessions của user
  Future<List<Map<String, dynamic>>> getUserPracticeSessions(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('practice_sessions')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error getting practice sessions: $e');
      return [];
    }
  }

  /// Lấy thống kê người dùng
  Future<Map<String, dynamic>?> getUserStatistics(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['statistics'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return null;
    }
  }

  /// Listen to practice sessions changes (real-time)
  Stream<List<Map<String, dynamic>>> watchUserPracticeSessions(
    String userId, {
    int limit = 10,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('practice_sessions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lưu user profile
  Future<void> saveUserProfile({
    required String userId,
    required String displayName,
    String? photoURL,
    String? phone,
    String? bio,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'displayName': displayName,
        'photoURL': photoURL,
        'phone': phone,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ User profile saved');
    } catch (e) {
      print('❌ Error saving user profile: $e');
      rethrow;
    }
  }

  /// Lấy user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Lưu settings
  Future<void> saveUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ User settings saved');
    } catch (e) {
      print('❌ Error saving settings: $e');
    }
  }

  /// Lấy settings
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['settings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting settings: $e');
      return null;
    }
  }
}
