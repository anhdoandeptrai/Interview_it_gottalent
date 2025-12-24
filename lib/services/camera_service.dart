import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import '../models/practice_session.dart';

class CameraService {
  CameraController? _controller;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  bool _isInitialized = false;
  bool _isDetecting = false;

  // Face analysis data
  List<EmotionData> _emotionHistory = [];
  DateTime? _analysisStartTime;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  List<EmotionData> get emotionHistory => _emotionHistory;

  // Initialize camera
  Future<bool> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available');
        return false;
      }

      // Use front camera for self-recording
      CameraDescription frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Audio handled separately
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  // Start camera preview
  Future<void> startPreview() async {
    if (_controller != null && _isInitialized) {
      await _controller!.startImageStream(_processCameraImage);
      _analysisStartTime = DateTime.now();
    }
  }

  // Stop camera preview
  Future<void> stopPreview() async {
    if (_controller != null && _isInitialized) {
      await _controller!.stopImageStream();
    }
  }

  // Take a picture
  Future<XFile?> takePicture() async {
    if (_controller != null && _isInitialized) {
      try {
        return await _controller!.takePicture();
      } catch (e) {
        print('Error taking picture: $e');
        return null;
      }
    }
    return null;
  }

  // Process camera image for face detection
  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final faces = await _faceDetector.processImage(inputImage);
        _analyzeFaces(faces);
      }
    } catch (e) {
      print('Error processing camera image: $e');
    }

    _isDetecting = false;
  }

  // Convert camera image to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _controller!.description;
      InputImageRotation? rotation;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotation = InputImageRotation.rotation270deg;
      } else {
        rotation = InputImageRotation.rotation90deg;
      }

      final format = InputImageFormat.nv21;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  // Analyze detected faces
  void _analyzeFaces(List<Face> faces) {
    if (faces.isEmpty) {
      // No face detected
      _recordEmotionData(null);
      return;
    }

    // Use the first (primary) face
    Face face = faces.first;
    _recordEmotionData(face);
  }

  // Record emotion data
  void _recordEmotionData(Face? face) {
    DateTime now = DateTime.now();

    if (face == null) {
      // No face detected
      EmotionData emotionData = EmotionData(
        timestamp: now,
        happiness: 0.0,
        confidence: 0.0,
        neutral: 1.0,
        nervous: 0.0,
        lookingAtCamera: false,
      );
      _emotionHistory.add(emotionData);
      return;
    }

    // Extract emotion probabilities
    double happiness = 0.0;
    double confidence = 0.5; // Default neutral confidence
    double neutral = 0.5;
    double nervous = 0.0;

    // Analyze facial expressions
    if (face.smilingProbability != null) {
      happiness = face.smilingProbability!;
      neutral = 1.0 - happiness;
    }

    // Estimate confidence based on facial features
    confidence = _estimateConfidence(face);
    nervous = _estimateNervousness(face);

    // Check eye contact (looking at camera)
    bool lookingAtCamera = _isLookingAtCamera(face);

    EmotionData emotionData = EmotionData(
      timestamp: now,
      happiness: happiness,
      confidence: confidence,
      neutral: neutral,
      nervous: nervous,
      lookingAtCamera: lookingAtCamera,
    );

    _emotionHistory.add(emotionData);
  }

  // Estimate confidence based on facial features
  double _estimateConfidence(Face face) {
    double confidence = 0.5; // Base confidence

    // Head pose analysis
    if (face.headEulerAngleY != null && face.headEulerAngleX != null) {
      double headStability =
          1.0 -
          (face.headEulerAngleY!.abs() + face.headEulerAngleX!.abs()) / 90.0;
      confidence += headStability.clamp(0.0, 0.3);
    }

    // Eye openness (if available through landmarks)
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      double eyeOpenness =
          (face.leftEyeOpenProbability! + face.rightEyeOpenProbability!) / 2.0;
      if (eyeOpenness > 0.5) {
        confidence += 0.2;
      }
    }

    return confidence.clamp(0.0, 1.0);
  }

  // Estimate nervousness based on facial features
  double _estimateNervousness(Face face) {
    double nervousness = 0.0;

    // Rapid head movements or extreme angles suggest nervousness
    if (face.headEulerAngleY != null && face.headEulerAngleX != null) {
      double headMovement =
          (face.headEulerAngleY!.abs() + face.headEulerAngleX!.abs()) / 90.0;
      nervousness = headMovement.clamp(0.0, 0.8);
    }

    // Blinking patterns (if detectable)
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      double eyeOpenness =
          (face.leftEyeOpenProbability! + face.rightEyeOpenProbability!) / 2.0;
      if (eyeOpenness < 0.3) {
        nervousness += 0.2; // Frequent blinking
      }
    }

    return nervousness.clamp(0.0, 1.0);
  }

  // Check if person is looking at camera
  bool _isLookingAtCamera(Face face) {
    // Use head pose to determine eye contact
    if (face.headEulerAngleY != null && face.headEulerAngleX != null) {
      double yAngle = face.headEulerAngleY!.abs();
      double xAngle = face.headEulerAngleX!.abs();

      // Consider looking at camera if head is relatively straight
      return yAngle < 15.0 && xAngle < 20.0;
    }

    return false;
  }

  // Get real-time feedback
  Map<String, dynamic> getRealTimeFeedback() {
    if (_emotionHistory.isEmpty) {
      return {
        'eyeContact': 'No face detected',
        'emotion': 'Please position yourself in front of the camera',
        'confidence': 'neutral',
      };
    }

    // Get recent emotion data (last 5 seconds)
    DateTime fiveSecondsAgo = DateTime.now().subtract(
      const Duration(seconds: 5),
    );
    List<EmotionData> recentEmotions = _emotionHistory
        .where((emotion) => emotion.timestamp.isAfter(fiveSecondsAgo))
        .toList();

    if (recentEmotions.isEmpty) {
      return {
        'eyeContact': 'No recent data',
        'emotion': 'Continue speaking',
        'confidence': 'neutral',
      };
    }

    // Calculate averages
    double avgEyeContact =
        recentEmotions
            .map((e) => e.lookingAtCamera ? 1.0 : 0.0)
            .reduce((a, b) => a + b) /
        recentEmotions.length;

    double avgHappiness =
        recentEmotions.map((e) => e.happiness).reduce((a, b) => a + b) /
        recentEmotions.length;

    double avgConfidence =
        recentEmotions.map((e) => e.confidence).reduce((a, b) => a + b) /
        recentEmotions.length;

    // Generate feedback
    String eyeContactFeedback = avgEyeContact > 0.6
        ? 'Good eye contact!'
        : 'Try to look at the camera more';

    String emotionFeedback = avgHappiness > 0.4
        ? 'Great positive expression!'
        : 'Try to smile and appear more engaging';

    String confidenceFeedback = avgConfidence > 0.6
        ? 'You appear confident!'
        : avgConfidence > 0.4
        ? 'Good posture, keep it up'
        : 'Straighten up and project confidence';

    return {
      'eyeContact': eyeContactFeedback,
      'emotion': emotionFeedback,
      'confidence': confidenceFeedback,
    };
  }

  // Get session analytics
  Map<String, dynamic> getSessionAnalytics() {
    if (_emotionHistory.isEmpty) {
      return {
        'averageEyeContact': 0.0,
        'averageHappiness': 0.0,
        'averageConfidence': 0.0,
        'totalDuration': 0,
        'eyeContactRatio': 0.0,
      };
    }

    double avgEyeContact =
        _emotionHistory
            .map((e) => e.lookingAtCamera ? 1.0 : 0.0)
            .reduce((a, b) => a + b) /
        _emotionHistory.length;

    double avgHappiness =
        _emotionHistory.map((e) => e.happiness).reduce((a, b) => a + b) /
        _emotionHistory.length;

    double avgConfidence =
        _emotionHistory.map((e) => e.confidence).reduce((a, b) => a + b) /
        _emotionHistory.length;

    Duration totalDuration = _analysisStartTime != null
        ? DateTime.now().difference(_analysisStartTime!)
        : const Duration();

    return {
      'averageEyeContact': avgEyeContact,
      'averageHappiness': avgHappiness,
      'averageConfidence': avgConfidence,
      'totalDuration': totalDuration.inSeconds,
      'eyeContactRatio': avgEyeContact * 100,
      'emotionHistory': _emotionHistory,
    };
  }

  // Clear emotion history
  void clearHistory() {
    _emotionHistory.clear();
    _analysisStartTime = null;
  }

  // Dispose resources
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
  }
}
