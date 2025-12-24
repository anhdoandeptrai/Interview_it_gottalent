import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeedbackSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color iconColor;
  final IconData icon;

  const FeedbackSection({
    super.key,
    required this.title,
    required this.items,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 12),

          // Feedback container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: items.map((item) => _buildFeedbackItem(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.secondaryText,
                height: 1.4,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernFeedbackCard extends StatelessWidget {
  final String title;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> suggestions;

  const ModernFeedbackCard({
    super.key,
    required this.title,
    required this.strengths,
    required this.improvements,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Điểm mạnh
                  if (strengths.isNotEmpty)
                    FeedbackSection(
                      title: 'Điểm mạnh',
                      items: strengths,
                      iconColor: AppTheme.successColor,
                      icon: Icons.check_circle_outline,
                    ),

                  // Cần cải thiện
                  if (improvements.isNotEmpty)
                    FeedbackSection(
                      title: 'Cần cải thiện',
                      items: improvements,
                      iconColor: AppTheme.warningColor,
                      icon: Icons.warning_amber_outlined,
                    ),

                  // Gợi ý cải thiện
                  if (suggestions.isNotEmpty)
                    FeedbackSection(
                      title: 'Gợi ý cải thiện',
                      items: suggestions,
                      iconColor: AppTheme.primaryColor,
                      icon: Icons.lightbulb_outline,
                    ),

                  const SizedBox(height: 32),

                  // Bottom actions
                  Column(
                    children: [
                      // Save to Firestore button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle save to Firestore
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã lưu kết quả vào hệ thống'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          },
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Lưu kết quả (Firestore)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Practice again button
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Luyện tập lại'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
