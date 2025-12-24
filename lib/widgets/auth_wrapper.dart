import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../screens/auth/getx_login_screen.dart';
import '../screens/home/getx_modern_home_screen.dart';
import '../screens/splash_screen.dart';
import '../utils/initialization_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthViewModel>(
      init: AuthViewModel(),
      builder: (authViewModel) {
        // Initialize connections once
        if (authViewModel.isLoggedIn) {
          InitializationService.initializeConnections();
        }

        // Check auth state
        if (authViewModel.isBusy) {
          return const SplashScreen();
        }

        if (authViewModel.isLoggedIn) {
          return const ModernHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
