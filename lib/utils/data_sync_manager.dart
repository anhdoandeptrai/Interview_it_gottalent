import 'package:flutter/foundation.dart';
import '../models/practice_session.dart';
import '../services/local_firebase_service.dart';
import '../utils/app_state_manager.dart';

/// Manager để đồng bộ dữ liệu giữa các screen và services
class DataSyncManager extends ChangeNotifier {
  final LocalFirebaseService _localService = LocalFirebaseService();
  AppStateManager? _appStateManager; // Optional reference

  // Cached data
  List<PracticeSession> _userSessions = [];
  PracticeSession? _currentSession;
  Map<String, dynamic> _userStats = {};
  bool _isDataLoaded = false;

  // Getters
  List<PracticeSession> get userSessions => List.unmodifiable(_userSessions);
  PracticeSession? get currentSession => _currentSession;
  Map<String, dynamic> get userStats => Map.unmodifiable(_userStats);
  bool get isDataLoaded => _isDataLoaded;

  // Set app state manager reference
  void setAppStateManager(AppStateManager appStateManager) {
    _appStateManager = appStateManager;
  }

  /// Tải dữ liệu người dùng từ local storage
  Future<void> loadUserData(String userId) async {
    try {
      print('📊 Loading user data for: $userId');

      // Load user sessions
      _userSessions = await _localService.getUserPracticeSessions(userId);
      print('📋 Loaded ${_userSessions.length} sessions');

      // Load user statistics
      _userStats = await _localService.getUserStatistics(userId);
      print('📈 Loaded user statistics');

      // Load current session if any
      final currentSessionId = _appStateManager?.currentSessionId;
      if (currentSessionId != null) {
        _currentSession =
            await _localService.getPracticeSession(currentSessionId);
        print('🎯 Loaded current session: $currentSessionId');
      }

      _isDataLoaded = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user data: $e');
      _isDataLoaded = false;
      notifyListeners();
    }
  }

  /// Tải lại dữ liệu
  Future<void> refreshUserData() async {
    final userId = _appStateManager?.currentUserId;
    if (userId != null) {
      _isDataLoaded = false;
      notifyListeners();
      await loadUserData(userId);
    }
  }

  /// Thêm phiên luyện tập mới
  Future<void> addSession(PracticeSession session) async {
    try {
      await _localService.savePracticeSession(session);

      // Update local cache
      _userSessions.add(session);
      _currentSession = session;

      // Update app state
      _appStateManager?.setCurrentSession(session.id, session.userId);

      // Recalculate stats
      await _recalculateStats(session.userId);

      notifyListeners();
    } catch (e) {
      print('❌ Error adding session: $e');
      rethrow;
    }
  }

  /// Cập nhật phiên luyện tập
  Future<void> updateSession(PracticeSession session) async {
    try {
      await _localService.updatePracticeSession(session);

      // Update local cache
      final index = _userSessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _userSessions[index] = session;
      }

      if (_currentSession?.id == session.id) {
        _currentSession = session;
      }

      // Recalculate stats
      await _recalculateStats(session.userId);

      notifyListeners();
    } catch (e) {
      print('❌ Error updating session: $e');
      rethrow;
    }
  }

  /// Xóa phiên luyện tập
  Future<void> deleteSession(String sessionId) async {
    try {
      await _localService.deletePracticeSession(sessionId);

      // Update local cache
      _userSessions.removeWhere((s) => s.id == sessionId);

      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _appStateManager?.clearCurrentSession();
      }

      // Recalculate stats
      final userId = _appStateManager?.currentUserId;
      if (userId != null) {
        await _recalculateStats(userId);
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Đặt phiên hiện tại
  void setCurrentSession(PracticeSession session) {
    _currentSession = session;
    _appStateManager?.setCurrentSession(session.id, session.userId);
    notifyListeners();
  }

  /// Xóa phiên hiện tại
  void clearCurrentSession() {
    _currentSession = null;
    _appStateManager?.clearCurrentSession();
    notifyListeners();
  }

  /// Tính lại thống kê người dùng
  Future<void> _recalculateStats(String userId) async {
    try {
      _userStats = await _localService.getUserStatistics(userId);
    } catch (e) {
      print('❌ Error recalculating stats: $e');
    }
  }

  /// Tìm kiếm phiên luyện tập
  List<PracticeSession> searchSessions({
    String? query,
    PracticeMode? mode,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _userSessions.where((session) {
      // Filter by query
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        if (!session.pdfFileName.toLowerCase().contains(queryLower) &&
            !session.questions
                .any((q) => q.toLowerCase().contains(queryLower))) {
          return false;
        }
      }

      // Filter by mode
      if (mode != null && session.mode != mode) {
        return false;
      }

      // Filter by date range
      if (fromDate != null && session.startTime.isBefore(fromDate)) {
        return false;
      }

      if (toDate != null && session.startTime.isAfter(toDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Lấy thống kê nhanh
  Map<String, dynamic> getQuickStats() {
    if (_userSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'averageScore': 0.0,
        'totalHours': 0.0,
        'improvementRate': 0.0,
      };
    }

    final completedSessions =
        _userSessions.where((s) => s.isCompleted).toList();

    double totalScore = 0.0;
    double totalMinutes = 0.0;

    for (final session in completedSessions) {
      totalScore += session.analytics.averageScore;
      totalMinutes += session.analytics.totalDuration.inMinutes;
    }

    final averageScore = completedSessions.isNotEmpty
        ? totalScore / completedSessions.length
        : 0.0;

    // Calculate improvement rate (compare first and last sessions)
    double improvementRate = 0.0;
    if (completedSessions.length >= 2) {
      final firstScore = completedSessions.first.analytics.averageScore;
      final lastScore = completedSessions.last.analytics.averageScore;
      improvementRate =
          ((lastScore - firstScore) / firstScore * 100).clamp(-100, 100);
    }

    return {
      'totalSessions': _userSessions.length,
      'averageScore': averageScore,
      'totalHours': totalMinutes / 60,
      'improvementRate': improvementRate,
    };
  }

  /// Xóa tất cả dữ liệu
  Future<void> clearAllData() async {
    try {
      _userSessions.clear();
      _currentSession = null;
      _userStats.clear();
      _isDataLoaded = false;
      // Không gọi _appStateManager.clearCurrentUser() ở đây để tránh setState trong build
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  /// Export dữ liệu để backup
  Future<Map<String, dynamic>> exportData() async {
    return {
      'sessions': _userSessions.map((s) => s.toMap()).toList(),
      'stats': _userStats,
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }
}
