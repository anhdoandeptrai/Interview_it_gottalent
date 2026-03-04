import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import '../models/behavior_result.dart';

/// Service phân tích hành vi học tập thông qua Face Detection
///
/// Tương tự như AIDetector trong Final_edu/ai-detector.ts
/// Sử dụng ML Kit Face Detection thay vì TensorFlow MoveNet
class AIBehaviorDetectorService {
  // Face detector instance
  late FaceDetector _faceDetector;

  // Tracking variables
  final List<_FacePosition> _positionHistory = [];
  final int _historyBufferSize = 15;

  // State
  bool _isInitialized = false;
  bool _isProcessing = false;

  // Behavior tracking
  BehaviorResult? _lastBehavior;
  final List<BehaviorResult> _behaviorHistory = [];

  // Stream for real-time behavior updates
  final _behaviorController = StreamController<BehaviorResult>.broadcast();
  Stream<BehaviorResult> get behaviorStream => _behaviorController.stream;

  // Statistics
  final Map<String, int> _behaviorCounts = {};
  final Map<BehaviorType, int> _typeCounts = {
    BehaviorType.positive: 0,
    BehaviorType.negative: 0,
    BehaviorType.neutral: 0,
    BehaviorType.warning: 0,
  };
  DateTime? _sessionStartTime;

  AIBehaviorDetectorService() {
    _initialize();
  }

  void _initialize() {
    try {
      // Initialize Face Detector with FAST mode to reduce crashes
      final options = FaceDetectorOptions(
        enableContours: false, // Tắt contours để giảm tải
        enableClassification: true,
        enableTracking: false, // Tắt tracking để tránh crash
        performanceMode: FaceDetectorMode.fast, // Chế độ fast thay vì accurate
      );

      _faceDetector = FaceDetector(options: options);
      _isInitialized = true;
      _sessionStartTime = DateTime.now();

      debugPrint('✅ [AI Behavior] Đã khởi tạo Face Detector (Fast Mode)');
    } catch (e) {
      debugPrint('❌ [AI Behavior] Lỗi khởi tạo: $e');
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
  BehaviorResult? get lastBehavior => _lastBehavior;
  List<BehaviorResult> get behaviorHistory =>
      List.unmodifiable(_behaviorHistory);

  /// Phát hiện và phân tích hành vi từ camera image
  Future<BehaviorResult?> detectBehavior(CameraImage image) async {
    if (!_isInitialized || _isProcessing) {
      return null;
    }

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage for ML Kit
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      // Detect faces với timeout để tránh crash
      final faces = await _faceDetector.processImage(inputImage).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⚠️ [AI Behavior] Face detection timeout');
          return <Face>[];
        },
      );

      // Analyze behavior from face detection
      final behavior = _analyzeBehavior(faces);

      _updateTracking(behavior);
      _lastBehavior = behavior;
      _behaviorController.add(behavior);

      _isProcessing = false;
      return behavior;
    } catch (e, stackTrace) {
      debugPrint('❌ [AI Behavior] Lỗi phát hiện: $e');
      debugPrint('Stack trace: $stackTrace');
      _isProcessing = false;

      // Trả về behavior mặc định khi có lỗi
      return BehaviorResult.noFace();
    }
  }

  /// Phân tích hành vi từ face detection results
  /// Logic tương tự AIDetector.analyzeBehavior() trong Final_edu
  BehaviorResult _analyzeBehavior(List<Face> faces) {
    // Không phát hiện khuôn mặt
    if (faces.isEmpty) {
      return BehaviorResult.noFace();
    }

    final face = faces.first;

    // Check face classification (smiling, eyes open/closed)
    if (face.smilingProbability != null) {
      final smiling = face.smilingProbability! > 0.7;
      if (smiling) {
        return BehaviorResult.smiling();
      }
    }

    // Check if eyes are closed (sleeping detection)
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      final leftEyeClosed = face.leftEyeOpenProbability! < 0.3;
      final rightEyeClosed = face.rightEyeOpenProbability! < 0.3;

      if (leftEyeClosed && rightEyeClosed) {
        // Both eyes closed for a while = sleeping
        return BehaviorResult.sleeping();
      }
    }

    // Check head pose (Euler angles)
    if (face.headEulerAngleY != null && face.headEulerAngleZ != null) {
      final yaw = face.headEulerAngleY!; // Left/Right rotation
      final roll = face.headEulerAngleZ!; // Tilt

      // Head turned away significantly (distracted)
      if (yaw.abs() > 30) {
        return BehaviorResult.distracted();
      }

      // Head tilted significantly
      if (roll.abs() > 25) {
        return BehaviorResult.tiltedHead();
      }

      // Head down (looking at phone/paper)
      if (face.headEulerAngleX != null) {
        final pitch = face.headEulerAngleX!; // Up/Down
        if (pitch > 20) {
          return BehaviorResult.lookingDown();
        }
      }
    }

    // Check face position history for gestures
    _updatePositionHistory(face);
    final gesture = _detectHeadGesture();

    // Confused if moving too much
    if (gesture == 'MOVING') {
      return BehaviorResult.confused();
    }

    // Default: focused and listening
    return BehaviorResult.focused();
  }

  /// Convert CameraImage to InputImage for ML Kit
  InputImage? _convertToInputImage(CameraImage image) {
    try {
      // Get image format
      final format = InputImageFormat.nv21;

      // Create input image metadata
      final metadata = InputImageMetadata(
        size: ui.Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      // Create input image from bytes
      final bytes = image.planes[0].bytes;
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('❌ [AI Behavior] Lỗi convert image: $e');
      return null;
    }
  }

  /// Update position history for gesture detection
  void _updatePositionHistory(Face face) {
    final boundingBox = face.boundingBox;
    final position = _FacePosition(
      x: boundingBox.center.dx,
      y: boundingBox.center.dy,
      timestamp: DateTime.now(),
    );

    _positionHistory.add(position);

    // Keep only recent positions
    if (_positionHistory.length > _historyBufferSize) {
      _positionHistory.removeAt(0);
    }
  }

  /// Detect head gestures from position history
  /// Tương tự AIDetector.detectHeadGesture() trong Final_edu
  String _detectHeadGesture() {
    if (_positionHistory.length < 8) {
      return 'MOVING';
    }

    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (final pos in _positionHistory) {
      if (pos.x < xMin) xMin = pos.x;
      if (pos.x > xMax) xMax = pos.x;
      if (pos.y < yMin) yMin = pos.y;
      if (pos.y > yMax) yMax = pos.y;
    }

    final xRange = xMax - xMin;
    final yRange = yMax - yMin;

    // Vertical movement (nodding)
    if (yRange > 20 && xRange < 10) {
      return 'NOD';
    }

    // Horizontal movement (shaking)
    if (xRange > 25 && yRange < 10) {
      return 'SHAKE';
    }

    // Very still
    if (xRange < 5 && yRange < 5) {
      return 'STILL';
    }

    return 'MOVING';
  }

  /// Update tracking statistics
  void _updateTracking(BehaviorResult behavior) {
    _behaviorHistory.add(behavior);

    // Update counts
    _behaviorCounts[behavior.label] =
        (_behaviorCounts[behavior.label] ?? 0) + 1;
    _typeCounts[behavior.type] = (_typeCounts[behavior.type] ?? 0) + 1;

    // Keep history limited to last 100 behaviors
    if (_behaviorHistory.length > 100) {
      final removed = _behaviorHistory.removeAt(0);
      _behaviorCounts[removed.label] =
          (_behaviorCounts[removed.label] ?? 1) - 1;
      _typeCounts[removed.type] = (_typeCounts[removed.type] ?? 1) - 1;
    }
  }

  /// Get behavior statistics
  BehaviorStatistics getStatistics() {
    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return BehaviorStatistics(
      behaviorCounts: Map.from(_behaviorCounts),
      typeCounts: Map.from(_typeCounts),
      totalDetections: _behaviorHistory.length,
      totalDuration: duration,
      recentBehaviors: _behaviorHistory.isEmpty
          ? []
          : _behaviorHistory.sublist(
              _behaviorHistory.length > 10 ? _behaviorHistory.length - 10 : 0),
    );
  }

  /// Reset tracking
  void reset() {
    _positionHistory.clear();
    _behaviorHistory.clear();
    _behaviorCounts.clear();
    _typeCounts[BehaviorType.positive] = 0;
    _typeCounts[BehaviorType.negative] = 0;
    _typeCounts[BehaviorType.neutral] = 0;
    _typeCounts[BehaviorType.warning] = 0;
    _lastBehavior = null;
    _sessionStartTime = DateTime.now();
    debugPrint('🔄 [AI Behavior] Đã reset tracking');
  }

  /// Dispose resources
  void dispose() {
    _faceDetector.close();
    _behaviorController.close();
    _isInitialized = false;
    debugPrint('✅ [AI Behavior] Đã dispose');
  }
}

/// Helper class for tracking face position
class _FacePosition {
  final double x;
  final double y;
  final DateTime timestamp;

  _FacePosition({
    required this.x,
    required this.y,
    required this.timestamp,
  });
}
