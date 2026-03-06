import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import '../models/practice_session.dart';
import '../services/local_firebase_service.dart';
import '../services/sync_service.dart';
import '../services/pdf_service.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';
import '../services/camera_service.dart';
import '../services/ai_behavior_detector_service.dart';
import '../models/behavior_result.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class PracticeController extends GetxController {
  static PracticeController get to => Get.find();

  final LocalFirebaseService _localFirebaseService = LocalFirebaseService();
  final SyncService _syncService = SyncService();
  final PdfService _pdfService = PdfService();
  final SpeechService _speechService = SpeechService();
  final CameraService _cameraService = CameraService();
  final AIBehaviorDetectorService _behaviorDetector = AIBehaviorDetectorService();
  late final AIService _aiService;

  // Observable variables
  final Rx<PracticeSession?> _currentSession = Rx<PracticeSession?>(null);
  final RxList<PracticeSession> _sessionHistory = <PracticeSession>[].obs;
  final Rx<SessionAnalytics?> _sessionAnalytics = Rx<SessionAnalytics?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSessionInProgress = false.obs;
  final RxBool _isRecording = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _currentQuestion = ''.obs;
  final RxInt _currentQuestionIndex = 0.obs;
  final RxDouble _sessionProgress = 0.0.obs;

  // Getters
  PracticeSession? get currentSession => _currentSession.value;
  List<PracticeSession> get sessionHistory => _sessionHistory;
  SessionAnalytics? get sessionAnalytics => _sessionAnalytics.value;
  bool get isLoading => _isLoading.value;
  bool get isSessionInProgress => _isSessionInProgress.value;
  bool get isRecording => _isRecording.value;
  String get errorMessage => _errorMessage.value;
  String get currentQuestion => _currentQuestion.value;
  int get currentQuestionIndex => _currentQuestionIndex.value;
  double get sessionProgress => _sessionProgress.value;

  // Reactive getters for binding
  RxBool get isSessionInProgressRx => _isSessionInProgress;
  RxBool get isRecordingRx => _isRecording;
  RxDouble get sessionProgressRx => _sessionProgress;

  // Camera controller getter
  get cameraController => _cameraService.controller;

  // Camera service getter for behavior detection
  CameraService? get cameraService => _cameraService;

  @override
  void onInit() {
    super.onInit();
    _initializeAI();
    _initializeServices();
    loadSessionHistory();
  }

  void _initializeAI() {
    const geminiApiKey = 'AIzaSyDWJtGE9RJ1RzvqV-zNAeebZsZu7UOCwsk';
    _aiService = AIService(geminiApiKey: geminiApiKey);
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _cameraService.initialize();
  }

  // Create new practice session
  Future<void> createSession({
    required PracticeMode mode,
    required File pdfFile,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final authController = AuthController.to;
      if (authController.currentUser == null) {
        throw Exception('User not authenticated');
      }

      print('📄 Starting PDF processing...');

      // Step 1: Validate PDF file
      final pdfValidation = await _pdfService.validatePdfFile(pdfFile);
      if (!pdfValidation['isValid']) {
        throw Exception(pdfValidation['error']);
      }

      print('✅ PDF validation passed: ${pdfValidation['fileSize']} bytes');
      print('📖 Extracting text from PDF...');

      // Step 2: Extract text from PDF with timeout (60 seconds max)
      final pdfResult = await _pdfService.extractTextFromPdf(pdfFile).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏱️ PDF extraction timeout after 60 seconds');
          return {
            'success': false,
            'error': 'Quá thời gian xử lý PDF. Vui lòng thử file nhỏ hơn.',
            'text': '',
            'pageCount': 0,
            'wordCount': 0,
          };
        },
      );

      if (!pdfResult['success']) {
        throw Exception(
            pdfResult['error'] ?? 'Không thể trích xuất nội dung từ PDF');
      }

      final extractedText = pdfResult['text'] as String;
      final pageCount = pdfResult['pageCount'] as int;
      final wordCount = pdfResult['wordCount'] as int;

      print('✅ Text extracted successfully:');
      print('   - Pages: $pageCount');
      print('   - Words: $wordCount');
      print(
          '   - Text preview: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');

      // Step 3: Upload PDF file to storage
      print('☁️ Uploading PDF to storage...');
      final pdfUrl = await _localFirebaseService.uploadPdfFile(
        pdfFile,
        authController.currentUser!.uid,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (pdfUrl == null) {
        throw Exception('Không thể tải file PDF lên storage');
      }

      print('✅ PDF uploaded: $pdfUrl');
      print('🤖 Generating questions with Gemini AI...');

      // Step 4: Generate questions using AI
      final questions = await _aiService.generateQuestions(
        pdfContent: extractedText,
        mode: mode,
        questionCount: 5,
      );

      if (questions.isEmpty) {
        throw Exception(
            'AI không thể tạo câu hỏi từ nội dung PDF. Vui lòng thử file khác.');
      }

      print('✅ Generated ${questions.length} questions:');
      for (var i = 0; i < questions.length; i++) {
        print('   ${i + 1}. ${questions[i]}');
      }

      // Step 5: Create session object
      final session = PracticeSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authController.currentUser!.uid,
        mode: mode,
        pdfFileName: pdfFile.path.split('/').last,
        pdfUrl: pdfUrl,
        questions: questions,
        answers: [],
        startTime: DateTime.now(),
        analytics: SessionAnalytics(
          averageSpeakingSpeed: 0,
          averageClarity: 0,
          averageEyeContactRatio: 0,
          averageScore: 0,
          totalDuration: Duration.zero,
          emotionAverages: {},
          strengths: [],
          weaknesses: [],
          improvements: [],
        ),
      );

      _currentSession.value = session;

      // Step 6: Save to local database
      print('💾 Saving session to local database...');
      await _localFirebaseService.savePracticeSession(session);
      print('✅ Session saved locally');

      // Step 7: Sync to Firebase for statistics (optional, continue if fails)
      try {
        print('☁️ Syncing session to Firebase...');
        await _syncService.savePracticeSession(session);
        print('✅ Session synced to Firebase for statistics');
      } catch (syncError) {
        print('⚠️ Warning: Failed to sync session to Firebase: $syncError');
        // Continue anyway - local session is saved
      }

      print('🎉 Session created successfully!');
      Get.snackbar(
        '✅ Thành công',
        'Đã tạo ${questions.length} câu hỏi từ nội dung PDF',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to practice screen
      Get.toNamed(AppRoutes.PRACTICE_SESSION);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Start practice session
  Future<void> startSession() async {
    if (_currentSession.value == null) return;

    try {
      _isSessionInProgress.value = true;
      _currentQuestionIndex.value = 0;
      _sessionProgress.value = 0.0;

      if (_currentSession.value!.questions.isNotEmpty) {
        _currentQuestion.value = _currentSession.value!.questions.first;
      }

      await _cameraService.startPreview();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // Biến lưu tạm câu trả lời đang ghi
  String _currentAnswerText = '';
  DateTime? _answerStartTime;
  final List<BehaviorResult> _currentBehaviors = [];
  Timer? _behaviorDetectionTimer;

  // Start recording answer
  Future<void> startAnswer() async {
    try {
      _isRecording.value = true;
      _currentAnswerText = '';
      _answerStartTime = DateTime.now();
      _currentBehaviors.clear();

      print('🎤 Bắt đầu ghi âm câu trả lời...');

      await _speechService.startListening(
        onResult: (result) {
          // Lưu text từ speech-to-text
          _currentAnswerText = result;
          print('📝 Recognized: $result');
        },
        onSoundLevel: (level) {
          // Handle sound level for UI feedback
        },
      );

      // Bắt đầu phân tích emotion từ camera
      print('😊 Bắt đầu phân tích biểu cảm khuôn mặt...');
      _startEmotionAnalysis();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  /// Bắt đầu phân tích emotion detection
  void _startEmotionAnalysis() {
    if (!_behaviorDetector.isInitialized) {
      print('⚠️ Behavior detector chưa khởi tạo');
      return;
    }

    // Phân tích behavior mỗi 500ms để capture emotion liên tục
    _behaviorDetectionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) async {
        try {
          // Get current camera image
          final cameraController = _cameraService.controller;
          if (cameraController == null || !cameraController.value.isStreamingImages) {
            return;
          }

          // Note: Cần implement stream camera images trong CameraService
          // Hoặc có thể dùng behavior stream từ detector
          // Hiện tại lưu behavior từ detector
          final behavior = _behaviorDetector.lastBehavior;
          if (behavior != null) {
            _currentBehaviors.add(behavior);
            print('😊 Detected: ${behavior.label} (${behavior.type.name})');
          }
        } catch (e) {
          print('⚠️ Lỗi phân tích emotion: $e');
        }
      },
    );

    print('✅ Đã bắt đầu emotion tracking');
  }

  // Stop recording answer
  Future<void> stopAnswer() async {
    try {
      _isRecording.value = false;

      print('⏹️ Dừng ghi âm...');
      await _speechService.stopListening();

      // Dừng emotion analysis
      _stopEmotionAnalysis();

      // Convert BehaviorResult sang EmotionData
      final emotionData = _convertBehaviorsToEmotions(_currentBehaviors);
      
      print('😊 Thu thập được ${emotionData.length} emotion data points');

      // Process and save answer with AI evaluation
      print('🤖 Đang xử lý và đánh giá câu trả lời...');
      await _processAnswer(emotionData);

      // Move to next question
      _moveToNextQuestion();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  /// Dừng emotion analysis
  void _stopEmotionAnalysis() {
    _behaviorDetectionTimer?.cancel();
    _behaviorDetectionTimer = null;
    print('⏹️ Đã dừng emotion tracking');
  }

  /// Convert BehaviorResult list sang EmotionData list
  List<EmotionData> _convertBehaviorsToEmotions(List<BehaviorResult> behaviors) {
    if (behaviors.isEmpty) {
      return [];
    }

    return behaviors.map((behavior) {
      // Map behavior type sang emotion values
      double happiness = 0.0;
      double confidence = 0.0;
      double neutral = 0.0;
      double nervous = 0.0;
      bool lookingAtCamera = true;

      switch (behavior.label) {
        case 'Đang cười':
        case '😊':
          happiness = 0.9;
          confidence = 0.8;
          lookingAtCamera = true;
          break;
        case 'Tập trung':
        case '🎯':
          confidence = 0.9;
          neutral = 0.7;
          lookingAtCamera = true;
          break;
        case 'Đang lắng nghe':
        case '✅':
          confidence = 0.8;
          neutral = 0.8;
          lookingAtCamera = true;
          break;
        case 'Đang nói':
        case '🗣️':
          confidence = 0.85;
          neutral = 0.6;
          lookingAtCamera = true;
          break;
        case 'Bối rối':
        case '🤔':
          nervous = 0.6;
          confidence = 0.4;
          neutral = 0.3;
          lookingAtCamera = true;
          break;
        case 'Mất tập trung':
        case '👀':
          nervous = 0.5;
          confidence = 0.3;
          lookingAtCamera = false;
          break;
        case 'Cúi đầu':
        case '📱':
          nervous = 0.4;
          confidence = 0.2;
          lookingAtCamera = false;
          break;
        case 'Nghiêng đầu':
        case '⚠️':
          nervous = 0.3;
          confidence = 0.5;
          neutral = 0.4;
          lookingAtCamera = true;
          break;
        case 'Đang ngủ':
        case '😴':
          nervous = 0.1;
          confidence = 0.0;
          lookingAtCamera = false;
          break;
        default:
          neutral = 0.5;
          confidence = 0.5;
      }

      return EmotionData(
        timestamp: behavior.timestamp,
        happiness: happiness,
        confidence: confidence,
        neutral: neutral,
        nervous: nervous,
        lookingAtCamera: lookingAtCamera,
      );
    }).toList();
  }

  Future<void> _processAnswer(List<EmotionData> emotionData) async {
    if (_currentSession.value == null) return;

    final currentQuestion = _currentSession.value!.questions[_currentQuestionIndex.value];
    final answerText = _currentAnswerText.trim();

    print('📊 Đánh giá câu trả lời cho: $currentQuestion');
    print('💬 Câu trả lời: ${answerText.isNotEmpty ? answerText : "(Không có văn bản)"}');
    print('😊 Emotion data: ${emotionData.length} data points');

    // Tính toán metrics cơ bản
    final answerDuration = _answerStartTime != null
        ? DateTime.now().difference(_answerStartTime!)
        : Duration.zero;
    
    final wordCount = answerText.split(' ').where((w) => w.isNotEmpty).length;
    final speakingSpeed = answerDuration.inSeconds > 0
        ? (wordCount / answerDuration.inSeconds) * 60 // words per minute
        : 0.0;
    
    final clarity = answerText.isNotEmpty ? 80.0 : 0.0; // Placeholder
    
    // Tính eye contact ratio từ emotion data
    final eyeContactRatio = emotionData.isNotEmpty
        ? emotionData.where((e) => e.lookingAtCamera).length / emotionData.length * 100
        : 70.0;

    // Phân tích emotion để tạo summary cho Gemini
    String emotionSummary = '';
    if (emotionData.isNotEmpty) {
      final avgConfidence = emotionData.fold<double>(0, (sum, e) => sum + e.confidence) / emotionData.length;
      final avgHappiness = emotionData.fold<double>(0, (sum, e) => sum + e.happiness) / emotionData.length;
      final avgNervous = emotionData.fold<double>(0, (sum, e) => sum + e.nervous) / emotionData.length;
      final lookingAtCameraPercent = (eyeContactRatio).toStringAsFixed(0);

      emotionSummary = '''

📊 PHÂN TÍCH BIỂU CẢM KHUÔN MẶT:
- Độ tự tin: ${(avgConfidence * 100).toStringAsFixed(0)}%
- Vui vẻ/Thoải mái: ${(avgHappiness * 100).toStringAsFixed(0)}%
- Lo lắng/Căng thẳng: ${(avgNervous * 100).toStringAsFixed(0)}%
- Giao tiếp mắt: $lookingAtCameraPercent%
- Tổng số lần phân tích: ${emotionData.length}
''';
    }

    // Đánh giá bằng AI với emotion context
    Map<String, dynamic> aiEvaluation;
    int score = 5;
    
    if (answerText.isNotEmpty && answerText.length > 10) {
      try {
        print('🤖 Gửi câu trả lời + emotion data cho Gemini AI đánh giá...');
        
        // Tạo context đầy đủ cho Gemini bao gồm emotion data
        final enhancedAnswer = answerText + emotionSummary;
        
        aiEvaluation = await _aiService.evaluateAnswer(
          question: currentQuestion,
          answer: enhancedAnswer,
          mode: _currentSession.value!.mode,
        );
        score = aiEvaluation['score'] ?? 5;
        print('✅ AI đánh giá xong - Điểm: $score/10');
        print('   Feedback: ${aiEvaluation['overall']}');
      } catch (e) {
        print('⚠️ Lỗi AI đánh giá: $e');
        aiEvaluation = {
          'score': 5,
          'overall': 'Không thể đánh giá do lỗi kỹ thuật',
          'strengths': ['Đã cố gắng trả lời'],
          'improvements': ['Thử lại sau'],
          'suggestions': ['Kiểm tra kết nối mạng'],
        };
      }
    } else {
      print('⚠️ Câu trả lời quá ngắn hoặc rỗng');
      aiEvaluation = {
        'score': 2,
        'overall': 'Câu trả lời quá ngắn hoặc không có nội dung',
        'strengths': [],
        'improvements': ['Trả lời đầy đủ hơn', 'Nói rõ ràng hơn'],
        'suggestions': ['Luyện tập nói nhiều hơn', 'Chuẩn bị nội dung trước'],
      };
      score = 2;
    }

    // Tạo Answer object với emotion data đầy đủ
    final answer = Answer(
      questionId: _currentQuestionIndex.value.toString(),
      question: currentQuestion,
      spokenText: answerText,
      audioUrl: '', // TODO: Save audio file and get URL
      timestamp: DateTime.now(),
      speakingSpeed: speakingSpeed,
      clarity: clarity,
      emotions: emotionData, // Lưu emotion data đầy đủ
      eyeContactRatio: eyeContactRatio,
      aiEvaluation: aiEvaluation['overall'] ?? '',
      score: score,
    );

    // Thêm answer vào session
    final updatedAnswers = List<Answer>.from(_currentSession.value!.answers)
      ..add(answer);

    _currentSession.value = PracticeSession(
      id: _currentSession.value!.id,
      userId: _currentSession.value!.userId,
      mode: _currentSession.value!.mode,
      pdfFileName: _currentSession.value!.pdfFileName,
      pdfUrl: _currentSession.value!.pdfUrl,
      questions: _currentSession.value!.questions,
      answers: updatedAnswers,
      startTime: _currentSession.value!.startTime,
      endTime: _currentSession.value!.endTime,
      analytics: _currentSession.value!.analytics,
      isCompleted: _currentSession.value!.isCompleted,
    );

    // Lưu session đã cập nhật
    await _localFirebaseService.updatePracticeSession(_currentSession.value!);
    print('💾 Đã lưu câu trả lời với ${emotionData.length} emotion data points');

    // Show feedback với emotion context
    String emotionFeedback = '';
    if (emotionData.isNotEmpty) {
      final avgConfidence = emotionData.fold<double>(0, (sum, e) => sum + e.confidence) / emotionData.length;
      if (avgConfidence >= 0.7) {
        emotionFeedback = ' - Tự tin 👍';
      } else if (avgConfidence < 0.5) {
        emotionFeedback = ' - Cần tự tin hơn 💪';
      }
    }

    Get.snackbar(
      '✅ Đã đánh giá',
      'Điểm: $score/10$emotionFeedback',
      backgroundColor: score >= 7 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex.value <
        _currentSession.value!.questions.length - 1) {
      _currentQuestionIndex.value++;
      _currentQuestion.value =
          _currentSession.value!.questions[_currentQuestionIndex.value];
      _sessionProgress.value = (_currentQuestionIndex.value + 1) /
          _currentSession.value!.questions.length;
    } else {
      // Session completed
      _endSession();
    }
  }

  // Move to specific question (for navigation)
  void moveToQuestion(int index) {
    if (_currentSession.value == null) return;
    if (index < 0 || index >= _currentSession.value!.questions.length) return;

    _currentQuestionIndex.value = index;
    _currentQuestion.value = _currentSession.value!.questions[index];
    _sessionProgress.value =
        (index + 1) / _currentSession.value!.questions.length;

    // Stop recording if moving between questions
    if (_isRecording.value) {
      stopAnswer();
    }
  }

  // End practice session
  Future<void> _endSession() async {
    try {
      _isSessionInProgress.value = false;
      _isRecording.value = false;

      print('🏁 Kết thúc phiên luyện tập...');

      await _cameraService.stopPreview();

      // Tính toán analytics
      final analytics = _calculateAnalytics();

      // Gọi AI để phân tích tổng thể session
      print('🤖 Đang phân tích tổng thể phiên luyện tập bằng AI...');
      Map<String, dynamic>? aiAnalysis;
      
      try {
        aiAnalysis = await _aiService.generateSessionAnalysis(
          answers: _currentSession.value!.answers,
          analytics: analytics,
          mode: _currentSession.value!.mode,
        );
        print('✅ AI đã phân tích xong phiên luyện tập');

        // Cập nhật analytics với insights từ AI
        final enhancedAnalytics = SessionAnalytics(
          averageSpeakingSpeed: analytics.averageSpeakingSpeed,
          averageClarity: analytics.averageClarity,
          averageEyeContactRatio: analytics.averageEyeContactRatio,
          averageScore: analytics.averageScore,
          totalDuration: analytics.totalDuration,
          emotionAverages: analytics.emotionAverages,
          strengths: (aiAnalysis['strengths'] as List?)?.cast<String>() ?? analytics.strengths,
          weaknesses: analytics.weaknesses,
          improvements: (aiAnalysis['improvements'] as List?)?.cast<String>() ?? analytics.improvements,
        );

        // Update session with end time and AI analysis
        final updatedSession = PracticeSession(
          id: _currentSession.value!.id,
          userId: _currentSession.value!.userId,
          mode: _currentSession.value!.mode,
          pdfFileName: _currentSession.value!.pdfFileName,
          pdfUrl: _currentSession.value!.pdfUrl,
          questions: _currentSession.value!.questions,
          answers: _currentSession.value!.answers,
          startTime: _currentSession.value!.startTime,
          endTime: DateTime.now(),
          analytics: enhancedAnalytics,
          isCompleted: true,
        );

        _currentSession.value = updatedSession;
        _sessionAnalytics.value = enhancedAnalytics;
        
        await _localFirebaseService.updatePracticeSession(updatedSession);
        print('💾 Đã lưu kết quả phiên luyện tập');

        // Sync to Firebase for statistics
        try {
          await _syncService.savePracticeSession(updatedSession);
          print('✅ Updated session synced to Firebase');
        } catch (e) {
          print('⚠️ Failed to sync updated session: $e');
        }

        Get.snackbar(
          '🎉 Hoàn thành',
          'Điểm trung bình: ${analytics.averageScore.toStringAsFixed(1)}/10',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed(AppRoutes.PRACTICE_RESULT);
      } catch (aiError) {
        print('⚠️ Lỗi phân tích AI: $aiError');
        
        // Vẫn kết thúc session với analytics cơ bản
        final updatedSession = PracticeSession(
          id: _currentSession.value!.id,
          userId: _currentSession.value!.userId,
          mode: _currentSession.value!.mode,
          pdfFileName: _currentSession.value!.pdfFileName,
          pdfUrl: _currentSession.value!.pdfUrl,
          questions: _currentSession.value!.questions,
          answers: _currentSession.value!.answers,
          startTime: _currentSession.value!.startTime,
          endTime: DateTime.now(),
          analytics: analytics,
          isCompleted: true,
        );

        _currentSession.value = updatedSession;
        _sessionAnalytics.value = analytics;
        
        await _localFirebaseService.updatePracticeSession(updatedSession);

        Get.offAllNamed(AppRoutes.PRACTICE_RESULT);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  SessionAnalytics _calculateAnalytics() {
    if (_currentSession.value == null || _currentSession.value!.answers.isEmpty) {
      return SessionAnalytics(
        averageSpeakingSpeed: 0,
        averageClarity: 0,
        averageEyeContactRatio: 0,
        averageScore: 0,
        totalDuration: Duration.zero,
        emotionAverages: {},
        strengths: [],
        weaknesses: [],
        improvements: [],
      );
    }

    final answers = _currentSession.value!.answers;
    final totalAnswers = answers.length;

    // Tính toán điểm trung bình
    final totalScore = answers.fold<int>(0, (sum, answer) => sum + answer.score);
    final averageScore = totalScore / totalAnswers;

    // Tính toán speaking speed trung bình
    final totalSpeed = answers.fold<double>(0, (sum, answer) => sum + answer.speakingSpeed);
    final averageSpeakingSpeed = totalSpeed / totalAnswers;

    // Tính toán clarity trung bình
    final totalClarity = answers.fold<double>(0, (sum, answer) => sum + answer.clarity);
    final averageClarity = totalClarity / totalAnswers;

    // Tính toán eye contact ratio trung bình
    final totalEyeContact = answers.fold<double>(0, (sum, answer) => sum + answer.eyeContactRatio);
    final averageEyeContactRatio = totalEyeContact / totalAnswers;

    // Tính thời gian tổng
    final totalDuration = _currentSession.value!.endTime != null
        ? _currentSession.value!.endTime!.difference(_currentSession.value!.startTime)
        : DateTime.now().difference(_currentSession.value!.startTime);

    // Phân tích điểm mạnh và yếu
    final strengths = <String>[];
    final weaknesses = <String>[];
    final improvements = <String>[];

    if (averageScore >= 8) {
      strengths.add('Trả lời xuất sắc với điểm cao');
    } else if (averageScore >= 6) {
      strengths.add('Trả lời tốt, có nội dung');
    }

    if (averageSpeakingSpeed >= 120 && averageSpeakingSpeed <= 160) {
      strengths.add('Tốc độ nói phù hợp');
    } else if (averageSpeakingSpeed < 100) {
      weaknesses.add('Nói hơi chậm');
      improvements.add('Luyện tập nói nhanh hơn');
    } else if (averageSpeakingSpeed > 180) {
      weaknesses.add('Nói hơi nhanh');
      improvements.add('Giảm tốc độ để rõ ràng hơn');
    }

    if (averageClarity >= 75) {
      strengths.add('Phát âm rõ ràng');
    } else {
      weaknesses.add('Cần cải thiện độ rõ ràng');
      improvements.add('Luyện phát âm và nói chậm rãi');
    }

    if (averageEyeContactRatio >= 60) {
      strengths.add('Giao tiếp mắt tốt');
    } else {
      weaknesses.add('Ít giao tiếp mắt');
      improvements.add('Nhìn vào camera nhiều hơn');
    }

    if (averageScore < 6) {
      improvements.add('Chuẩn bị nội dung kỹ hơn');
      improvements.add('Luyện tập thường xuyên');
    }

    // Emotion averages
    final emotionAverages = <String, double>{
      'happiness': 0.0,
      'confidence': 0.0,
      'neutral': 0.0,
      'nervous': 0.0,
    };

    int emotionCount = 0;
    for (final answer in answers) {
      for (final emotion in answer.emotions) {
        emotionAverages['happiness'] = 
            (emotionAverages['happiness']! + emotion.happiness);
        emotionAverages['confidence'] = 
            (emotionAverages['confidence']! + emotion.confidence);
        emotionAverages['neutral'] = 
            (emotionAverages['neutral']! + emotion.neutral);
        emotionAverages['nervous'] = 
            (emotionAverages['nervous']! + emotion.nervous);
        emotionCount++;
      }
    }

    if (emotionCount > 0) {
      emotionAverages.forEach((key, value) {
        emotionAverages[key] = value / emotionCount;
      });
    }

    return SessionAnalytics(
      averageSpeakingSpeed: averageSpeakingSpeed,
      averageClarity: averageClarity,
      averageEyeContactRatio: averageEyeContactRatio,
      averageScore: averageScore,
      totalDuration: totalDuration,
      emotionAverages: emotionAverages,
      strengths: strengths,
      weaknesses: weaknesses,
      improvements: improvements,
    );
  }

  // Load session history
  Future<void> loadSessionHistory() async {
    try {
      final authController = AuthController.to;
      if (authController.currentUser == null) return;

      final sessions = await _localFirebaseService.getUserPracticeSessions(
        authController.currentUser!.uid,
      );

      _sessionHistory.assignAll(sessions);
    } catch (e) {
      _errorMessage.value = e.toString();
    }
  }

  // Navigate to home
  void navigateToHome() {
    _currentSession.value = null;
    _sessionAnalytics.value = null;
    _isSessionInProgress.value = false;
    _isRecording.value = false;
    _currentQuestionIndex.value = 0;
    _sessionProgress.value = 0.0;
    Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    _behaviorDetectionTimer?.cancel();
    _behaviorDetector.dispose();
    _cameraService.dispose();
    super.onClose();
  }
}
