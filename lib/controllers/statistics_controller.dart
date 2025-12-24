import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/sync_service.dart';
import 'dart:async';

class StatisticsController extends GetxController {
  final isLoading = true.obs;
  final totalSessions = 0.obs;
  final totalMinutes = 0.obs;
  final averageScore = 0.0.obs;
  final recentSessions = <Map<String, dynamic>>[].obs;

  final _auth = FirebaseAuth.instance;
  final _syncService = SyncService();

  StreamSubscription<List<Map<String, dynamic>>>? _sessionsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
    _listenToSessionsUpdates();
  }

  @override
  void onClose() {
    _sessionsSubscription?.cancel();
    super.onClose();
  }

  /// Listen to real-time updates
  void _listenToSessionsUpdates() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _sessionsSubscription = _syncService
        .watchUserPracticeSessions(userId, limit: 10)
        .listen((sessions) {
      if (sessions.isNotEmpty) {
        _processSessionsData(sessions);
      }
    });
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Load statistics from cached data first
      final stats = await _syncService.getUserStatistics(userId);
      if (stats != null) {
        totalSessions.value = stats['totalSessions'] ?? 0;
        totalMinutes.value = stats['totalMinutes'] ?? 0;
        averageScore.value = (stats['averageScore'] ?? 0).toDouble();
      }

      // Load recent sessions
      final sessions =
          await _syncService.getUserPracticeSessions(userId, limit: 10);
      _processSessionsData(sessions);

      isLoading.value = false;
    } catch (e) {
      print('Error loading statistics: $e');
      isLoading.value = false;
    }
  }

  /// Process sessions data for display
  void _processSessionsData(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      totalSessions.value = 0;
      totalMinutes.value = 0;
      averageScore.value = 0;
      recentSessions.value = [];
      return;
    }

    // Calculate statistics if not cached
    double totalScore = 0;
    int totalDuration = 0;
    List<Map<String, dynamic>> formattedSessions = [];

    for (var data in sessions) {
      totalScore += (data['score'] ?? 0).toDouble();
      totalDuration += (data['duration'] ?? 0) as int;

      formattedSessions.add({
        'type': _getTypeLabel(data['type'] ?? data['mode'] ?? 'interview'),
        'date': _formatDate(data['createdAt'] as Timestamp?),
        'score': data['score'] ?? 0,
      });
    }

    totalSessions.value = sessions.length;
    averageScore.value = totalScore / sessions.length;
    totalMinutes.value = (totalDuration / 60).round();
    recentSessions.value = formattedSessions;
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'interview':
        return 'Phỏng vấn';
      case 'presentation':
        return 'Thuyết trình';
      default:
        return 'Luyện tập';
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> refresh() async {
    await loadStatistics();
  }
}
