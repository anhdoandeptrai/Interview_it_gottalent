import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../services/sync_service.dart';

class SettingsController extends GetxController {
  final isLoading = true.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhotoUrl = ''.obs;

  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final defaultDuration = 5.obs;

  final _auth = FirebaseAuth.instance;
  final _syncService = SyncService();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadSettings();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        userName.value = user.displayName ?? 'Người dùng';
        userEmail.value = user.email ?? '';
        userPhotoUrl.value = user.photoURL ?? '';

        // Load additional data from Firestore via SyncService
        final userData = await _syncService.getUserProfile(user.uid);
        if (userData != null) {
          userName.value = userData['displayName'] ?? userName.value;
          userPhotoUrl.value = userData['photoURL'] ?? userPhotoUrl.value;
        }
      }

      isLoading.value = false;
    } catch (e) {
      print('Error loading user data: $e');
      isLoading.value = false;
    }
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid;

      // Load from local preferences first
      notificationsEnabled.value =
          prefs.getBool('notifications_enabled') ?? true;
      darkModeEnabled.value = prefs.getBool('dark_mode_enabled') ?? false;
      defaultDuration.value = prefs.getInt('default_duration') ?? 5;

      // Sync with Firebase
      if (userId != null) {
        final settings = await _syncService.getUserSettings(userId);
        if (settings != null) {
          notificationsEnabled.value =
              settings['notificationsEnabled'] ?? notificationsEnabled.value;
          darkModeEnabled.value =
              settings['darkModeEnabled'] ?? darkModeEnabled.value;
          defaultDuration.value =
              settings['defaultDuration'] ?? defaultDuration.value;

          // Update local preferences
          await prefs.setBool(
              'notifications_enabled', notificationsEnabled.value);
          await prefs.setBool('dark_mode_enabled', darkModeEnabled.value);
          await prefs.setInt('default_duration', defaultDuration.value);
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await _saveSettings();
  }

  Future<void> toggleDarkMode(bool value) async {
    darkModeEnabled.value = value;
    await _saveSettings();
    // TODO: Update app theme
  }

  Future<void> setDefaultDuration(int minutes) async {
    defaultDuration.value = minutes;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      // Save to local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('dark_mode_enabled', darkModeEnabled.value);
      await prefs.setInt('default_duration', defaultDuration.value);

      // Sync to Firebase
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _syncService.saveUserSettings(
          userId: userId,
          settings: {
            'notificationsEnabled': notificationsEnabled.value,
            'darkModeEnabled': darkModeEnabled.value,
            'defaultDuration': defaultDuration.value,
          },
        );
      }
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      print('Error logging out: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể đăng xuất. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
