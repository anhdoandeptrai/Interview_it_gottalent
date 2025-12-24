import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthViewModel>(
      init: AuthViewModel(),
      builder: (viewModel) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo and title
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Email field
                    _buildEmailField(viewModel),

                    const SizedBox(height: 20),

                    // Password field
                    _buildPasswordField(viewModel),

                    const SizedBox(height: 32),

                    // Sign in button
                    _buildSignInButton(viewModel),

                    const SizedBox(height: 24),

                    // Register link
                    _buildRegisterLink(),

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
            Icons.person_outline,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chào mừng bạn quay trở lại',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
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

  Widget _buildSignInButton(AuthViewModel viewModel) {
    return Obx(() => SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: viewModel.isBusy ? null : viewModel.signIn,
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
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.REGISTER),
          child: const Text(
            'Đăng ký ngay',
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
