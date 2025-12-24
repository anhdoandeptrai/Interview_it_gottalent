import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/base_viewmodel.dart';
import '../controllers/auth_controller.dart';

class AuthViewModel extends BaseViewModel {
  AuthController? _authController;

  AuthController? get authController {
    try {
      if (Get.isRegistered<AuthController>()) {
        _authController ??= Get.find<AuthController>();
        return _authController;
      }
      return null;
    } catch (e) {
      print('Error getting AuthController: $e');
      return null;
    }
  }

  // Form fields
  final RxString _email = ''.obs;
  final RxString _password = ''.obs;
  final RxString _displayName = ''.obs;
  final RxString _confirmPassword = ''.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;

  // Getters
  String get email => _email.value;
  String get password => _password.value;
  String get displayName => _displayName.value;
  String get confirmPassword => _confirmPassword.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  User? get currentUser => authController?.firebaseUser;
  bool get isLoggedIn => authController?.firebaseUser != null;

  // Form validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên hiển thị';
    }
    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _password.value) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // Update form fields
  void updateEmail(String value) => _email.value = value;
  void updatePassword(String value) => _password.value = value;
  void updateDisplayName(String value) => _displayName.value = value;
  void updateConfirmPassword(String value) => _confirmPassword.value = value;

  // Aliases for convenience
  void setEmail(String value) => updateEmail(value);
  void setPassword(String value) => updatePassword(value);
  void setDisplayName(String value) => updateDisplayName(value);
  void setConfirmPassword(String value) => updateConfirmPassword(value);

  // Toggle password visibility
  void togglePasswordVisibility() => _isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => _isConfirmPasswordVisible.toggle();

  // Sign in
  Future<void> signIn() async {
    if (validateEmail(_email.value) != null ||
        validatePassword(_password.value) != null) {
      setError('Vui lòng kiểm tra lại thông tin đăng nhập');
      return;
    }

    final controller = authController;
    if (controller == null) {
      setError('Không thể kết nối đến dịch vụ xác thực');
      return;
    }

    await runBusyFuture(
      controller.signIn(
        email: _email.value,
        password: _password.value,
      ),
      errorMessage: 'Đăng nhập thất bại',
    );
  }

  // Sign up
  Future<void> signUp() async {
    if (validateEmail(_email.value) != null ||
        validatePassword(_password.value) != null ||
        validateDisplayName(_displayName.value) != null ||
        validateConfirmPassword(_confirmPassword.value) != null) {
      setError('Vui lòng kiểm tra lại thông tin đăng ký');
      return;
    }

    final controller = authController;
    if (controller == null) {
      setError('Không thể kết nối đến dịch vụ xác thực');
      return;
    }

    await runBusyFuture(
      controller.signUp(
        email: _email.value,
        password: _password.value,
        displayName: _displayName.value,
      ),
      errorMessage: 'Đăng ký thất bại',
    );
  }

  // Sign out
  Future<void> signOut() async {
    final controller = authController;
    if (controller == null) {
      setError('Không thể kết nối đến dịch vụ xác thực');
      return;
    }

    await runBusyFuture(
      controller.signOut(),
      errorMessage: 'Đăng xuất thất bại',
    );
  }

  // Clear form
  void clearForm() {
    _email.value = '';
    _password.value = '';
    _displayName.value = '';
    _confirmPassword.value = '';
    _isPasswordVisible.value = false;
    _isConfirmPasswordVisible.value = false;
    clearError();
  }
}
