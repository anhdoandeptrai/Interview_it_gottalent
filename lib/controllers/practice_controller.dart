import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    // Đọc API key từ environment variable (.env file)
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];

    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      print('❌ GEMINI_API_KEY not found in .env file');
      print('   Create .env file with: GEMINI_API_KEY=your_key_here');
      throw Exception('Gemini API key not configured');
    }

    _aiService = AIService(geminiApiKey: geminiApiKey);
    print('✅ AI Service initialized with API key from .env');
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

  // Start recording answer
  Future<void> startAnswer() async {
    try {
      _isRecording.value = true;

      await _speechService.startListening(
        onResult: (result) {
          // Handle speech result
        },
        onSoundLevel: (level) {
          // Handle sound level
        },
      );

      // Process camera emotion analysis here
      // _cameraService.startEmotionAnalysis();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // Stop recording answer
  Future<void> stopAnswer() async {
    try {
      _isRecording.value = false;

      await _speechService.stopListening();
      // Process emotion data here
      final emotionData = <EmotionData>[];
      // final emotionData = _cameraService.stopEmotionAnalysis();

      // Process and save answer
      await _processAnswer(emotionData);

      // Move to next question
      _moveToNextQuestion();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> _processAnswer(List<EmotionData> emotionData) async {
    // Implementation for processing answer
    // This would include AI evaluation, saving audio, etc.
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

      await _cameraService.stopPreview();

      // Update session with end time
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
        analytics: _calculateAnalytics(),
        isCompleted: true,
      );

      _currentSession.value = updatedSession;
      await _localFirebaseService.updatePracticeSession(updatedSession);

      // Sync to Firebase for statistics
      try {
        await _syncService.savePracticeSession(updatedSession);
        print('✅ Updated session synced to Firebase');
      } catch (e) {
        print('⚠️ Failed to sync updated session: $e');
      }

      // Load analytics for result screen
      _sessionAnalytics.value = updatedSession.analytics;

      Get.offAllNamed(AppRoutes.PRACTICE_RESULT);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString());
    }
  }

  SessionAnalytics _calculateAnalytics() {
    // Implementation for calculating session analytics
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
    _cameraService.dispose();
    super.onClose();
  }
}
