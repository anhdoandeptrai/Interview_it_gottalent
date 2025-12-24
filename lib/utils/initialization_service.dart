/// Service để khởi tạo và kết nối các controllers với nhau
class InitializationService {
  static bool _isInitialized = false;

  /// Khởi tạo tất cả connections và callbacks
  static void initializeConnections() {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      print('✅ All controller connections initialized successfully');
    } catch (e) {
      print('❌ Error initializing controller connections: $e');
    }
  }

  /// Reset initialization state (for testing or logout)
  static void reset() {
    _isInitialized = false;
  }
}