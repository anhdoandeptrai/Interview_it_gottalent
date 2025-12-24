import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthService _authService = AuthService();

  // Observable variables
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  User? get firebaseUser => _firebaseUser.value;
  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _firebaseUser.bindStream(_authService.authStateChanges);
    ever(_firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) async {
    if (user != null) {
      try {
        _currentUser.value = await _authService.getUserData(user.uid);
        // Only navigate if we're not on splash screen
        if (Get.currentRoute != AppRoutes.SPLASH) {
          Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
        }
      } catch (e) {
        print('Error getting user data: $e');
        _currentUser.value = null;
      }
    } else {
      _currentUser.value = null;
      // Only navigate if we're not on splash screen
      if (Get.currentRoute != AppRoutes.SPLASH) {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    }
  }

  // Method to check auth status without navigation (for splash screen)
  Future<bool> checkAuthStatus() async {
    try {
      if (_firebaseUser.value != null) {
        _currentUser.value =
            await _authService.getUserData(_firebaseUser.value!.uid);
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking auth status: $e');
      return false;
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result != null) {
        Get.snackbar('Thành công', 'Đăng ký tài khoản thành công!');
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        Get.snackbar('Thành công', 'Đăng nhập thành công!');
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      Get.snackbar('Thành công', 'Đăng xuất thành công!');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel userData) async {
    try {
      _isLoading.value = true;
      await _authService.updateUserData(userData);
      _currentUser.value = userData;
      Get.snackbar('Thành công', 'Cập nhật thông tin thành công!');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }
}
