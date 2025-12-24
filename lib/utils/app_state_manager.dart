import 'package:flutter/foundation.dart';

/// Global state manager để đồng bộ dữ liệu giữa các screens
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // Current app state
  bool _isConnectedToInternet = true;
  bool _isUsingLocalStorage = true;
  Map<String, dynamic> _globalCache = {};

  // Session state
  String? _currentSessionId;
  String? _currentUserId;
  bool _isSessionInProgress = false;

  // Getters
  bool get isConnectedToInternet => _isConnectedToInternet;
  bool get isUsingLocalStorage => _isUsingLocalStorage;
  Map<String, dynamic> get globalCache => Map.unmodifiable(_globalCache);
  String? get currentSessionId => _currentSessionId;
  String? get currentUserId => _currentUserId;
  bool get isSessionInProgress => _isSessionInProgress;

  // Update connection status
  void updateConnectionStatus(bool isConnected) {
    if (_isConnectedToInternet != isConnected) {
      _isConnectedToInternet = isConnected;
      notifyListeners();
    }
  }

  // Update storage mode
  void updateStorageMode(bool useLocal) {
    if (_isUsingLocalStorage != useLocal) {
      _isUsingLocalStorage = useLocal;
      notifyListeners();
    }
  }

  // Set current session
  void setCurrentSession(String sessionId, String userId) {
    _currentSessionId = sessionId;
    _currentUserId = userId;
    _isSessionInProgress = true;
    notifyListeners();
  }

  // Clear current session
  void clearCurrentSession() {
    _currentSessionId = null;
    _isSessionInProgress = false;
    notifyListeners();
  }

  // Set current user
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Clear current user
  void clearCurrentUser() {
    _currentUserId = null;
    clearCurrentSession();
    _globalCache.clear();
    notifyListeners();
  }

  // Cache management
  void setCacheValue(String key, dynamic value) {
    _globalCache[key] = value;
    notifyListeners();
  }

  T? getCacheValue<T>(String key) {
    return _globalCache[key] as T?;
  }

  void removeCacheValue(String key) {
    _globalCache.remove(key);
    notifyListeners();
  }

  void clearCache() {
    _globalCache.clear();
    notifyListeners();
  }

  // Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isConnectedToInternet': _isConnectedToInternet,
      'isUsingLocalStorage': _isUsingLocalStorage,
      'currentSessionId': _currentSessionId,
      'currentUserId': _currentUserId,
      'isSessionInProgress': _isSessionInProgress,
      'cacheSize': _globalCache.length,
    };
  }
}
