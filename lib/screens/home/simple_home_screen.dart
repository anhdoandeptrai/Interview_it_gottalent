import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('Interview Practice',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              try {
                if (Get.isRegistered<AuthViewModel>()) {
                  Get.find<AuthViewModel>().signOut();
                } else {
                  print('AuthViewModel not registered');
                  Get.offAllNamed(AppRoutes.LOGIN);
                }
              } catch (e) {
                print('Error signing out: $e');
                Get.offAllNamed(AppRoutes.LOGIN);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_rounded,
              size: 100,
              color: Color(0xFF667EEA),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Interview Practice!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ready to practice your skills?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to practice setup
          Get.snackbar('Info', 'Practice feature coming soon!');
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}
