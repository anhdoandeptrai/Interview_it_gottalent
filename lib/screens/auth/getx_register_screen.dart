import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthViewModel>(
      init: AuthViewModel(),
      builder: (viewModel) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Display name field
                    _buildDisplayNameField(viewModel),

                    const SizedBox(height: 20),

                    // Email field
                    _buildEmailField(viewModel),

                    const SizedBox(height: 20),

                    // Password field
                    _buildPasswordField(viewModel),

                    const SizedBox(height: 20),

                    // Confirm password field
                    _buildConfirmPasswordField(viewModel),

                    const SizedBox(height: 32),

                    // Sign up button
                    _buildSignUpButton(viewModel),

                    const SizedBox(height: 24),

                    // Login link
                    _buildLoginLink(),

                    const SizedBox(height: 20),

                    // Error message
                    Obx(() => viewModel.hasError
                        ? _buildErrorMessage(viewModel.errorMessage)
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA).withOpacity(0.8),
                const Color(0xFF764BA2).withOpacity(0.8),
              ],
            ),
          ),
          child: const Icon(
            Icons.person_add_outlined,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tạo tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tham gia cùng chúng tôi ngay hôm nay',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayNameField(AuthViewModel viewModel) {
    return TextFormField(
      onChanged: viewModel.updateDisplayName,
      validator: viewModel.validateDisplayName,
      decoration: InputDecoration(
        labelText: 'Tên hiển thị',
        prefixIcon: const Icon(Icons.person_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildEmailField(AuthViewModel viewModel) {
    return TextFormField(
      onChanged: viewModel.updateEmail,
      keyboardType: TextInputType.emailAddress,
      validator: viewModel.validateEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildPasswordField(AuthViewModel viewModel) {
    return Obx(() => TextFormField(
          onChanged: viewModel.updatePassword,
          obscureText: !viewModel.isPasswordVisible,
          validator: viewModel.validatePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: viewModel.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
          style: const TextStyle(color: Colors.white),
        ));
  }

  Widget _buildConfirmPasswordField(AuthViewModel viewModel) {
    return Obx(() => TextFormField(
          onChanged: viewModel.updateConfirmPassword,
          obscureText: !viewModel.isConfirmPasswordVisible,
          validator: viewModel.validateConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.isConfirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: viewModel.toggleConfirmPasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
          style: const TextStyle(color: Colors.white),
        ));
  }

  Widget _buildSignUpButton(AuthViewModel viewModel) {
    return Obx(() => SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: viewModel.isBusy ? null : viewModel.signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: viewModel.isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => Get.offNamed(AppRoutes.LOGIN),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
