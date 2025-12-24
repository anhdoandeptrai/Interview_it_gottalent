import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              _buildProfileSection(controller),
              const Divider(),

              // Settings List
              _buildSettingsList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: controller.userPhotoUrl.value.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      controller.userPhotoUrl.value,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.userName.value,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.userEmail.value,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to profile edit screen
              Get.toNamed(AppRoutes.PROFILE);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Chỉnh sửa hồ sơ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(SettingsController controller) {
    return Column(
      children: [
        _buildSectionHeader('Cài đặt chung'),
        _buildSettingTile(
          icon: Icons.notifications_outlined,
          title: 'Thông báo',
          subtitle: 'Quản lý thông báo ứng dụng',
          trailing: Obx(() => Switch(
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              )),
        ),
        _buildSettingTile(
          icon: Icons.dark_mode_outlined,
          title: 'Chế độ tối',
          subtitle: 'Bật/tắt giao diện tối',
          trailing: Obx(() => Switch(
                value: controller.darkModeEnabled.value,
                onChanged: controller.toggleDarkMode,
              )),
        ),
        _buildSettingTile(
          icon: Icons.language_outlined,
          title: 'Ngôn ngữ',
          subtitle: 'Tiếng Việt',
          onTap: () {
            // Show language selection
          },
        ),
        const Divider(),
        _buildSectionHeader('Luyện tập'),
        _buildSettingTile(
          icon: Icons.timer_outlined,
          title: 'Thời gian mặc định',
          subtitle: '${controller.defaultDuration.value} phút',
          onTap: () {
            _showDurationPicker(controller);
          },
        ),
        _buildSettingTile(
          icon: Icons.mic_outlined,
          title: 'Cài đặt âm thanh',
          subtitle: 'Microphone và loa',
          onTap: () {
            // Navigate to audio settings
          },
        ),
        const Divider(),
        _buildSectionHeader('Khác'),
        _buildSettingTile(
          icon: Icons.help_outline,
          title: 'Trợ giúp & Hỗ trợ',
          onTap: () {
            // Navigate to help screen
          },
        ),
        _buildSettingTile(
          icon: Icons.info_outline,
          title: 'Về ứng dụng',
          subtitle: 'Phiên bản 1.0.0',
          onTap: () {
            // Show about dialog
          },
        ),
        _buildSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Chính sách bảo mật',
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        const Divider(),
        _buildSettingTile(
          icon: Icons.logout,
          title: 'Đăng xuất',
          titleColor: Colors.red,
          onTap: () {
            _showLogoutDialog(controller);
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Get.textTheme.titleSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: titleColor != null
            ? TextStyle(color: titleColor, fontWeight: FontWeight.w500)
            : null,
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showDurationPicker(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn thời gian mặc định'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 5, 10, 15, 20, 30]
              .map((duration) => RadioListTile<int>(
                    title: Text('$duration phút'),
                    value: duration,
                    groupValue: controller.defaultDuration.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDefaultDuration(value);
                        Get.back();
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
