import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/sync_service.dart';
import '../controllers/settings_controller.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final isSaving = false.obs;
  final photoUrl = ''.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();
  final _syncService = SyncService();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        emailController.text = user.email ?? '';
        nameController.text = user.displayName ?? '';
        photoUrl.value = user.photoURL ?? '';

        // Load additional data from Firestore via SyncService
        final userData = await _syncService.getUserProfile(user.uid);
        if (userData != null) {
          nameController.text = userData['displayName'] ?? nameController.text;
          phoneController.text = userData['phone'] ?? '';
          bioController.text = userData['bio'] ?? '';
          photoUrl.value = userData['photoURL'] ?? photoUrl.value;
        }
      }

      isLoading.value = false;
    } catch (e) {
      print('Error loading profile: $e');
      isLoading.value = false;
      Get.snackbar(
        'Lỗi',
        'Không thể tải thông tin hồ sơ',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      isSaving.value = true;
      final user = _auth.currentUser;

      if (user == null) return;

      // Update display name in Firebase Auth
      await user.updateDisplayName(nameController.text);

      // Update data in Firestore via SyncService
      await _syncService.saveUserProfile(
        userId: user.uid,
        displayName: nameController.text,
        photoURL: photoUrl.value.isEmpty ? null : photoUrl.value,
        phone: phoneController.text.isEmpty ? null : phoneController.text,
        bio: bioController.text.isEmpty ? null : bioController.text,
      );

      isSaving.value = false;
      Get.snackbar(
        'Thành công',
        'Đã lưu thông tin hồ sơ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload settings to sync data
      if (Get.isRegistered<SettingsController>()) {
        final settingsController = Get.find<SettingsController>();
        await settingsController.loadUserData();
      }
    } catch (e) {
      print('Error saving profile: $e');
      isSaving.value = false;
      Get.snackbar(
        'Lỗi',
        'Không thể lưu thông tin hồ sơ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final user = _auth.currentUser;
      if (user == null) return;

      // Upload to Firebase Storage
      final storageRef =
          _storage.ref().child('profile_images').child('${user.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Update photoURL
      photoUrl.value = downloadUrl;
      await user.updatePhotoURL(downloadUrl);

      // Update in Firestore via SyncService
      await _syncService.saveUserProfile(
        userId: user.uid,
        displayName: nameController.text,
        photoURL: downloadUrl,
        phone: phoneController.text.isEmpty ? null : phoneController.text,
        bio: bioController.text.isEmpty ? null : bioController.text,
      );

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Thành công',
        'Đã cập nhật ảnh đại diện',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload settings to sync data
      if (Get.isRegistered<SettingsController>()) {
        final settingsController = Get.find<SettingsController>();
        await settingsController.loadUserData();
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật ảnh đại diện',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
