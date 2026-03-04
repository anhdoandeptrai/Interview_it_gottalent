import 'package:flutter/material.dart';

/// Enum cho các loại hành vi
enum BehaviorType {
  positive,
  negative,
  neutral,
  warning,
}

/// Model cho kết quả phân tích hành vi
class BehaviorResult {
  final String label;
  final String emoji;
  final Color color;
  final Color bgColor;
  final BehaviorType type;
  final DateTime timestamp;
  final double confidence;

  BehaviorResult({
    required this.label,
    required this.emoji,
    required this.color,
    required this.bgColor,
    required this.type,
    DateTime? timestamp,
    this.confidence = 1.0,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructors cho các hành vi cụ thể
  factory BehaviorResult.sleeping() {
    return BehaviorResult(
      label: 'Đang ngủ',
      emoji: '😴',
      color: const Color(0xFFA855F7),
      bgColor: const Color(0xFFA855F7).withOpacity(0.2),
      type: BehaviorType.negative,
    );
  }

  factory BehaviorResult.distracted() {
    return BehaviorResult(
      label: 'Mất tập trung',
      emoji: '👀',
      color: const Color(0xFFF43F5E),
      bgColor: const Color(0xFFF43F5E).withOpacity(0.2),
      type: BehaviorType.negative,
    );
  }

  factory BehaviorResult.tiltedHead() {
    return BehaviorResult(
      label: 'Nghiêng đầu',
      emoji: '⚠️',
      color: const Color(0xFFF59E0B),
      bgColor: const Color(0xFFF59E0B).withOpacity(0.2),
      type: BehaviorType.warning,
    );
  }

  factory BehaviorResult.lookingDown() {
    return BehaviorResult(
      label: 'Cúi đầu',
      emoji: '📱',
      color: const Color(0xFFF43F5E),
      bgColor: const Color(0xFFF43F5E).withOpacity(0.2),
      type: BehaviorType.negative,
    );
  }

  factory BehaviorResult.listening() {
    return BehaviorResult(
      label: 'Đang lắng nghe',
      emoji: '✅',
      color: const Color(0xFF3B82F6),
      bgColor: const Color(0xFF3B82F6).withOpacity(0.2),
      type: BehaviorType.positive,
    );
  }

  factory BehaviorResult.focused() {
    return BehaviorResult(
      label: 'Tập trung',
      emoji: '🎯',
      color: const Color(0xFF10B981),
      bgColor: const Color(0xFF10B981).withOpacity(0.2),
      type: BehaviorType.positive,
    );
  }

  factory BehaviorResult.smiling() {
    return BehaviorResult(
      label: 'Đang cười',
      emoji: '😊',
      color: const Color(0xFF10B981),
      bgColor: const Color(0xFF10B981).withOpacity(0.2),
      type: BehaviorType.positive,
    );
  }

  factory BehaviorResult.confused() {
    return BehaviorResult(
      label: 'Bối rối',
      emoji: '🤔',
      color: const Color(0xFFF59E0B),
      bgColor: const Color(0xFFF59E0B).withOpacity(0.2),
      type: BehaviorType.warning,
    );
  }

  factory BehaviorResult.noFace() {
    return BehaviorResult(
      label: 'Không thấy người',
      emoji: '❓',
      color: const Color(0xFF64748B),
      bgColor: const Color(0xFF64748B).withOpacity(0.2),
      type: BehaviorType.neutral,
    );
  }

  factory BehaviorResult.speaking() {
    return BehaviorResult(
      label: 'Đang nói',
      emoji: '🗣️',
      color: const Color(0xFF3B82F6),
      bgColor: const Color(0xFF3B82F6).withOpacity(0.2),
      type: BehaviorType.positive,
    );
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'emoji': emoji,
      'color': color.value,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'confidence': confidence,
    };
  }

  // Create from Map
  factory BehaviorResult.fromMap(Map<String, dynamic> map) {
    return BehaviorResult(
      label: map['label'] ?? '',
      emoji: map['emoji'] ?? '',
      color: Color(map['color'] ?? 0xFF000000),
      bgColor: Color(map['color'] ?? 0xFF000000).withOpacity(0.2),
      type: BehaviorType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BehaviorType.neutral,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      confidence: map['confidence'] ?? 1.0,
    );
  }

  @override
  String toString() {
    return 'BehaviorResult(label: $label, emoji: $emoji, type: ${type.name}, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Model cho thống kê hành vi
class BehaviorStatistics {
  final Map<String, int> behaviorCounts;
  final Map<BehaviorType, int> typeCounts;
  final int totalDetections;
  final Duration totalDuration;
  final double positivePercentage;
  final double negativePercentage;
  final List<BehaviorResult> recentBehaviors;

  BehaviorStatistics({
    required this.behaviorCounts,
    required this.typeCounts,
    required this.totalDetections,
    required this.totalDuration,
    required this.recentBehaviors,
  })  : positivePercentage = totalDetections > 0
            ? (typeCounts[BehaviorType.positive] ?? 0) / totalDetections * 100
            : 0,
        negativePercentage = totalDetections > 0
            ? (typeCounts[BehaviorType.negative] ?? 0) / totalDetections * 100
            : 0;

  // Get focus score (0-100)
  double get focusScore {
    if (totalDetections == 0) return 0;

    final positive = typeCounts[BehaviorType.positive] ?? 0;
    final negative = typeCounts[BehaviorType.negative] ?? 0;
    final warning = typeCounts[BehaviorType.warning] ?? 0;

    // Positive behaviors add to score, negative subtract
    final score = (positive * 1.0 - negative * 1.5 - warning * 0.5) /
        totalDetections *
        100;
    return score.clamp(0, 100);
  }

  // Get most common behavior
  String get mostCommonBehavior {
    if (behaviorCounts.isEmpty) return 'Chưa có dữ liệu';

    final sorted = behaviorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  Map<String, dynamic> toMap() {
    return {
      'behaviorCounts': behaviorCounts,
      'typeCounts': typeCounts.map((key, value) => MapEntry(key.name, value)),
      'totalDetections': totalDetections,
      'totalDurationMs': totalDuration.inMilliseconds,
      'positivePercentage': positivePercentage,
      'negativePercentage': negativePercentage,
      'focusScore': focusScore,
      'mostCommonBehavior': mostCommonBehavior,
    };
  }

  @override
  String toString() {
    return 'BehaviorStatistics(detections: $totalDetections, focusScore: ${focusScore.toStringAsFixed(1)}%, positive: ${positivePercentage.toStringAsFixed(1)}%, negative: ${negativePercentage.toStringAsFixed(1)}%)';
  }
}
