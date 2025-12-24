import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../viewmodels/practice_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/practice_session.dart';
import '../practice/getx_modern_setup_screen.dart';

class ModernHomeScreen extends StatelessWidget {
  const ModernHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ViewModels are available
    if (!Get.isRegistered<PracticeViewModel>()) {
      Get.put<PracticeViewModel>(PracticeViewModel());
    }
    if (!Get.isRegistered<AuthViewModel>()) {
      Get.put<AuthViewModel>(AuthViewModel());
    }

    return GetBuilder<PracticeViewModel>(
      builder: (practiceViewModel) {
        return GetBuilder<AuthViewModel>(
          builder: (authViewModel) {
            return Scaffold(
              backgroundColor: const Color(0xFF0F0F23),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F0F23),
                      Color(0xFF1A1A2E),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(authViewModel),
                      _buildWelcomeCard(authViewModel),
                      _buildQuickActions(practiceViewModel),
                      _buildRecentSessions(practiceViewModel),
                      _buildStatistics(practiceViewModel),
                      _buildTips(),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: _buildFloatingButton(practiceViewModel),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar(AuthViewModel authViewModel) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xin chào ${authViewModel.currentUser?.displayName ?? 'Bạn'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sẵn sàng cho buổi luyện tập mới?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                  ),
                  color: const Color(0xFF2A2A3E),
                  onSelected: (value) =>
                      _handleMenuAction(value, authViewModel),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.white70),
                          SizedBox(width: 8),
                          Text('Hồ sơ', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: Colors.white70),
                          SizedBox(width: 8),
                          Text('Cài đặt',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Đăng xuất',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthViewModel authViewModel) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Luyện tập phỏng vấn\nvới AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Cải thiện kỹ năng phỏng vấn của bạn với công nghệ AI tiên tiến. Nhận phản hồi chi tiết về ngôn ngữ cơ thể, giọng nói và nội dung trả lời.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(PracticeViewModel practiceViewModel) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chế độ luyện tập',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Phỏng vấn',
                    subtitle: 'Luyện tập phỏng vấn công việc',
                    icon: Icons.business_center,
                    color: const Color(0xFF10B981),
                    onTap: () => Get.to(() => const ModernSetupScreen(mode: PracticeMode.interview)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Thuyết trình',
                    subtitle: 'Thực hành kỹ năng thuyết trình',
                    icon: Icons.campaign,
                    color: const Color(0xFF3B82F6),
                    onTap: () => Get.to(() => const ModernSetupScreen(mode: PracticeMode.presentation)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(PracticeViewModel practiceViewModel) {
    return Obx(() {
      final recentSessions = practiceViewModel.recentSessions.value;

      if (recentSessions.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử gần đây',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllSessions(practiceViewModel),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recentSessions
                  .take(3)
                  .map(
                    (session) => _SessionCard(
                      session: session,
                      onTap: () =>
                          practiceViewModel.viewSessionDetails(session.id),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatistics(PracticeViewModel practiceViewModel) {
    return Obx(() {
      final stats = practiceViewModel.userStatistics.value;

      if (stats == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống kê của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Tổng phiên',
                      value: stats.totalSessions.toString(),
                      icon: Icons.assignment,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Điểm TB',
                      value: practiceViewModel.formatScore(stats.averageScore),
                      icon: Icons.star,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Thời gian luyện',
                      value: practiceViewModel
                          .formatDuration(stats.totalPracticeTime),
                      icon: Icons.timer,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Cải thiện',
                      value: '${(stats.improvementRate * 100).toInt()}%',
                      icon: Icons.trending_up,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTips() {
    final tips = [
      'Luyện tập thường xuyên để cải thiện kỹ năng phỏng vấn',
      'Tập trung vào giao tiếp bằng mắt khi trả lời câu hỏi',
      'Chuẩn bị kỹ các câu trả lời cho câu hỏi phổ biến',
      'Thực hành với các tình huống phỏng vấn khác nhau',
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Mẹo luyện tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...tips
                  .map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(PracticeViewModel practiceViewModel) {
    return FloatingActionButton.extended(
      onPressed: () => practiceViewModel.navigateToSetup(),
      backgroundColor: const Color(0xFF667EEA),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Luyện tập mới',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, AuthViewModel authViewModel) {
    switch (action) {
      case 'profile':
        Get.snackbar(
          'Hồ sơ',
          'Tính năng hồ sơ sẽ được cập nhật trong phiên bản tiếp theo',
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );
        break;
      case 'settings':
        Get.snackbar(
          'Cài đặt',
          'Tính năng cài đặt sẽ được cập nhật trong phiên bản tiếp theo',
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );
        break;
      case 'logout':
        authViewModel.signOut();
        break;
    }
  }

  void _showRecentResults(PracticeViewModel practiceViewModel) {
    Get.snackbar(
      'Kết quả',
      'Đang tải kết quả gần đây...',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void _showAllSessions(PracticeViewModel practiceViewModel) {
    Get.snackbar(
      'Lịch sử',
      'Tính năng xem tất cả phiên sẽ được cập nhật trong phiên bản tiếp theo',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final PracticeSession session;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.questions.isNotEmpty
                        ? 'Phỏng vấn ${session.questions.length} câu hỏi'
                        : 'Phiên luyện tập',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(session.timestamp),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (session.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(session.averageScore * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (session.isCompleted) return const Color(0xFF10B981);
    return const Color(0xFFF59E0B);
  }

  IconData _getStatusIcon() {
    if (session.isCompleted) return Icons.check_circle;
    return Icons.access_time;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
