import 'package:get/get.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  // Observable variables
  final RxBool _isConnectedToInternet = true.obs;
  final RxBool _isUsingLocalStorage = true.obs;
  final RxMap<String, dynamic> _globalCache = <String, dynamic>{}.obs;
  final RxString _currentSessionId = ''.obs;
  final RxBool _isSessionInProgress = false.obs;

  // Getters
  bool get isConnectedToInternet => _isConnectedToInternet.value;
  bool get isUsingLocalStorage => _isUsingLocalStorage.value;
  Map<String, dynamic> get globalCache => _globalCache;
  String get currentSessionId => _currentSessionId.value;
  bool get isSessionInProgress => _isSessionInProgress.value;

  // Update connection status
  void updateConnectionStatus(bool isConnected) {
    _isConnectedToInternet.value = isConnected;

    if (isConnected) {
      Get.snackbar('Kết nối', 'Đã kết nối mạng');
    } else {
      Get.snackbar('Mất kết nối', 'Ứng dụng đang hoạt động offline');
    }
  }

  // Update storage mode
  void updateStorageMode(bool useLocal) {
    _isUsingLocalStorage.value = useLocal;
  }

  // Set session state
  void setSession(String sessionId, bool inProgress) {
    _currentSessionId.value = sessionId;
    _isSessionInProgress.value = inProgress;
  }

  // Clear session
  void clearSession() {
    _currentSessionId.value = '';
    _isSessionInProgress.value = false;
  }

  // Update cache
  void updateCache(String key, dynamic value) {
    _globalCache[key] = value;
  }

  // Get cache value
  T? getCacheValue<T>(String key) {
    return _globalCache[key] as T?;
  }

  // Clear cache
  void clearCache() {
    _globalCache.clear();
  }
}
