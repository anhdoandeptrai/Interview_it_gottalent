import 'package:flutter/material.dart';
import '../models/behavior_result.dart';

/// Widget hiển thị behavior badge real-time
/// Tương tự AIBehaviorDetector component trong Final_edu
class BehaviorBadgeWidget extends StatelessWidget {
  final BehaviorResult? behavior;
  final bool isLoading;
  final String? errorMessage;
  final bool isEnabled;
  final VoidCallback? onToggle;

  const BehaviorBadgeWidget({
    Key? key,
    this.behavior,
    this.isLoading = false,
    this.errorMessage,
    this.isEnabled = true,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Behavior Badge
          if (isEnabled && behavior != null && !isLoading)
            _buildBehaviorBadge(behavior!),

          // Loading State
          if (isEnabled && isLoading) _buildLoadingBadge(),

          // Error State
          if (errorMessage != null) _buildErrorBadge(errorMessage!),

          const SizedBox(height: 8),

          // Toggle Button
          if (onToggle != null) _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildBehaviorBadge(BehaviorResult behavior) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -5 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: behavior.color.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: behavior.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    behavior.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    behavior.label,
                    style: TextStyle(
                      color: behavior.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Đang tải AI...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBadge(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          border: Border.all(
            color: isEnabled
                ? Colors.green.withOpacity(0.4)
                : Colors.grey.withOpacity(0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🤖',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              'AI ${isEnabled ? 'ON' : 'OFF'}',
              style: TextStyle(
                color: isEnabled ? Colors.green : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị behavior history panel
class BehaviorHistoryPanel extends StatelessWidget {
  final List<BehaviorResult> behaviors;
  final BehaviorStatistics? statistics;

  const BehaviorHistoryPanel({
    Key? key,
    required this.behaviors,
    this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '📊 Phân tích hành vi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (statistics != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Điểm tập trung: ${statistics!.focusScore.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics
          if (statistics != null) ...[
            _buildStatRow(
                'Tích cực', statistics!.positivePercentage, Colors.green),
            const SizedBox(height: 8),
            _buildStatRow(
                'Tiêu cực', statistics!.negativePercentage, Colors.red),
            const SizedBox(height: 16),
          ],

          // Recent behaviors
          if (behaviors.isNotEmpty) ...[
            const Text(
              'Hành vi gần đây:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...behaviors
                .take(5)
                .map((behavior) => _buildBehaviorItem(behavior)),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Chưa có dữ liệu phân tích',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double percentage, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorItem(BehaviorResult behavior) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: behavior.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: behavior.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            behavior.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              behavior.label,
              style: TextStyle(
                color: behavior.color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatTimestamp(behavior.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s trước';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m trước';
    } else {
      return '${diff.inHours}h trước';
    }
  }
}
