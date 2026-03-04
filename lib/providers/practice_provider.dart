import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/practice_session.dart';
import '../services/local_firebase_service.dart'; // Changed to local service
import '../services/pdf_service.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';
import '../services/camera_service.dart';
import '../utils/app_state_manager.dart';

class PracticeProvider extends ChangeNotifier {
  final LocalFirebaseService _localFirebaseService =
      LocalFirebaseService(); // Using local service
  final PdfService _pdfService = PdfService();
  final SpeechService _speechService = SpeechService();
  final CameraService _cameraService = CameraService();
  final AppStateManager _appStateManager = AppStateManager();
  late final AIService? _aiService;

  // Callback for session updates
  Function(PracticeSession)? onSessionCreated;
  Function(PracticeSession)? onSessionUpdated;

  // Current session state
  PracticeSession? _currentSession;
  bool _isSessionActive = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Session data
  File? _selectedPdfFile;
  String? _extractedText;
  List<String> _questions = [];
  int _currentQuestionIndex = 0;
  List<Answer> _answers = [];

  // Real-time feedback
  Map<String, dynamic> _realTimeFeedback = {};

  // Analytics
  SessionAnalytics? _sessionAnalytics;

  // Getters
  PracticeSession? get currentSession => _currentSession;
  bool get isSessionActive => _isSessionActive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedPdfFile => _selectedPdfFile;
  String? get extractedText => _extractedText;
  List<String> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  String? get currentQuestion => _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;
  List<Answer> get answers => _answers;
  Map<String, dynamic> get realTimeFeedback => _realTimeFeedback;
  SessionAnalytics? get sessionAnalytics => _sessionAnalytics;
  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;

  // Services
  SpeechService get speechService => _speechService;
  CameraService get cameraService => _cameraService;

  PracticeProvider({required String geminiApiKey, String? openAIApiKey}) {
    try {
      if (geminiApiKey.isEmpty || geminiApiKey == 'fallback-key') {
        throw Exception('Invalid Gemini API key');
      }

      _aiService = AIService(
        geminiApiKey: geminiApiKey,
        openAIApiKey: openAIApiKey,
      );
      print('AI Service initialized successfully');
    } catch (e) {
      print('Error initializing AI Service: $e');
      // Continue without crashing - AI service will use fallbacks
      try {
        _aiService = AIService(
          geminiApiKey: 'dummy-key-for-fallback',
          openAIApiKey: null,
        );
        print('AI Service initialized with fallback key');
      } catch (fallbackError) {
        print(
            'Failed to initialize AI Service even with fallback: $fallbackError');
        // Continue - will rely entirely on fallback questions
      }
    }
  }

  // Initialize new practice session
  Future<bool> createSession({
    required String userId,
    required PracticeMode mode,
    required File pdfFile,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      print('Creating session for user: $userId');
      print('Mode: $mode');
      print('PDF file: ${pdfFile.path}');

      // Validate PDF file
      if (!await pdfFile.exists()) {
        throw Exception('PDF file does not exist');
      }

      final fileSize = await pdfFile.length();
      if (fileSize == 0) {
        throw Exception('PDF file is empty');
      }

      if (fileSize > 50 * 1024 * 1024) {
        // 50MB limit
        throw Exception('PDF file is too large (max 50MB)');
      }

      print('PDF file validation passed. Size: $fileSize bytes');

      // Extract text from PDF using improved service
      _selectedPdfFile = pdfFile;
      print('Extracting text from PDF...');

      final extractionResult = await _pdfService.extractTextFromPdf(pdfFile);

      if (!extractionResult['success']) {
        throw Exception('PDF processing failed: ${extractionResult['error']}');
      }

      _extractedText = extractionResult['text'] as String;
      final wordCount = extractionResult['wordCount'] as int;

      if (_extractedText == null || _extractedText!.isEmpty) {
        throw Exception(
            'Could not extract text from PDF file. Please ensure the PDF contains readable text.');
      }

      if (wordCount < 10) {
        throw Exception(
            'PDF content is too short to generate meaningful questions (minimum 10 words required).');
      }

      print(
          'Text extraction successful. Word count: $wordCount, Character length: ${_extractedText!.length}');

      // Generate session ID
      String sessionId = const Uuid().v4();
      print('Generated session ID: $sessionId');

      // Update global state
      _appStateManager.setCurrentSession(sessionId, userId);

      // Test Local Storage connectivity first (với timeout)
      print('Testing Local Storage connectivity...');
      bool storageConnected = false;
      try {
        storageConnected =
            await _localFirebaseService.testStorageConnectivity().timeout(
                  const Duration(seconds: 10),
                  onTimeout: () => false,
                );
      } catch (e) {
        print('Storage connectivity test error: $e');
        storageConnected = false;
      }

      if (!storageConnected) {
        print(
            'Storage connectivity failed, continuing with local storage only...');
        // Không throw exception, chỉ log warning
      } else {
        print('Firebase Storage connectivity test passed');
      }

      // Upload PDF to Local Storage (luôn hoạt động)
      print('Uploading PDF to Local Storage...');
      String? pdfUrl;

      try {
        pdfUrl = await _localFirebaseService
            .uploadPdfFile(
              pdfFile,
              userId,
              sessionId,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => null,
            );
      } catch (e) {
        print('PDF upload error: $e');
        // Tạo URL local thay vì throw exception
        pdfUrl =
            'local://pdf/${userId}/${sessionId}/${pdfFile.path.split('/').last}';
        print('Using local URL: $pdfUrl');
      }

      if (pdfUrl == null || pdfUrl.isEmpty) {
        throw Exception('Không thể lưu file PDF. Vui lòng thử lại.');
      }

      print('PDF upload successful. URL: $pdfUrl');

      // Generate questions using AI (với fallback)
      print('Generating questions using AI...');
      try {
        // Kiểm tra mode trước khi gọi AI service
        if (mode != PracticeMode.interview &&
            mode != PracticeMode.presentation) {
          throw Exception('Invalid practice mode: $mode');
        }

        // Kiểm tra xem AI service có được khởi tạo đúng không
        if (_aiService == null) {
          throw Exception('AI service not initialized');
        }

        if (_aiService != null) {
          _questions = await _aiService!
              .generateQuestions(
            pdfContent: _extractedText!,
            mode: mode,
            questionCount: 5,
          )
              .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              print('❌ AI service timeout after 45 seconds');
              throw Exception(
                  'Gemini AI không phản hồi. Vui lòng kiểm tra kết nối internet và thử lại.');
            },
          );
        } else {
          throw Exception(
              'AI service chưa được khởi tạo. Vui lòng khởi động lại ứng dụng.');
        }
      } catch (e) {
        print('❌ AI service error: $e');
        // Throw error thay vì dùng fallback
        throw Exception('Không thể tạo câu hỏi từ AI: ${e.toString()}');
      }

      if (_questions.isEmpty) {
        print('❌ No questions generated from AI');
        throw Exception(
            'AI không thể tạo câu hỏi từ nội dung PDF. Vui lòng thử file PDF khác.');
      }

      print('Generated ${_questions.length} questions');

      // Create session
      _currentSession = PracticeSession(
        id: sessionId,
        userId: userId,
        mode: mode,
        pdfFileName: pdfFile.path.split('/').last,
        pdfUrl: pdfUrl,
        questions: _questions,
        startTime: DateTime.now(),
        analytics: SessionAnalytics(
          averageSpeakingSpeed: 0.0,
          averageClarity: 0.0,
          averageEyeContactRatio: 0.0,
          averageScore: 0.0,
          totalDuration: const Duration(),
          emotionAverages: {},
          strengths: [],
          weaknesses: [],
          improvements: [],
        ),
      );

      // Save to local storage
      print('Saving session to local storage...');
      await _localFirebaseService.savePracticeSession(_currentSession!);
      print('Session saved successfully!');

      // Notify listeners about new session
      onSessionCreated?.call(_currentSession!);

      _currentQuestionIndex = 0;
      _answers.clear();

      print('Session created successfully!');
      return true;
    } catch (e) {
      print('Error creating session: $e');
      print('Stack trace: ${StackTrace.current}');
      String errorMessage = 'Failed to create session: ';

      if (e.toString().contains('PDF file does not exist')) {
        errorMessage += 'Selected file not found';
      } else if (e.toString().contains('PDF file is empty')) {
        errorMessage += 'PDF file is empty';
      } else if (e.toString().contains('PDF file is too large')) {
        errorMessage += 'PDF file is too large (max 50MB)';
      } else if (e.toString().contains('Could not extract text')) {
        errorMessage +=
            'Cannot read text from PDF. Please use a PDF with readable text';
      } else if (e.toString().contains('Failed to upload PDF')) {
        errorMessage += 'Upload failed. Check internet connection';
      } else if (e.toString().contains('Failed to generate questions')) {
        errorMessage += 'AI service unavailable. Please try again later';
      } else if (e.toString().contains('Invalid practice mode')) {
        errorMessage += 'Chế độ luyện tập không hợp lệ';
      } else if (e.toString().contains('Gemini AI không phản hồi')) {
        errorMessage += 'AI không phản hồi. Vui lòng kiểm tra kết nối internet';
      } else if (e.toString().contains('Không thể tạo câu hỏi từ AI')) {
        errorMessage += 'Không thể tạo câu hỏi. Vui lòng thử file PDF khác';
      } else {
        errorMessage += e.toString();
      }

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start practice session
  Future<bool> startSession() async {
    try {
      if (_currentSession == null) {
        print('Error: No session to start');
        _setError('No session available to start');
        return false;
      }

      if (_questions.isEmpty) {
        print('Error: No questions available');
        _setError('No questions available for practice');
        return false;
      }

      _setLoading(true);
      _clearError();

      _isSessionActive = true;
      _cameraService.clearHistory();

      // Initialize camera with error handling
      bool cameraInitialized = await _cameraService.initialize();
      if (!cameraInitialized) {
        print(
            'Warning: Camera initialization failed, continuing without camera');
      }

      // Start real-time feedback
      _startRealTimeFeedback();

      print('Practice session started successfully');
      return true;
    } catch (e) {
      print('Error starting session: $e');
      _setError('Failed to start session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start answering current question
  Future<void> startAnswer() async {
    try {
      if (!_isSessionActive || _currentSession == null) {
        print('Error: Session not active or not available');
        _setError('Session not active');
        return;
      }

      if (_currentQuestionIndex >= _questions.length) {
        print('Error: No more questions available');
        _setError('No questions available');
        return;
      }

      _setLoading(true);
      _clearError();

      print('Starting answer for question ${_currentQuestionIndex + 1}');

      // Initialize services with error handling
      try {
        bool speechInitialized = await _speechService.initialize();
        if (!speechInitialized) {
          print('Warning: Speech service not available');
        }
      } catch (e) {
        print('Warning: Speech service initialization failed: $e');
      }

      try {
        await _cameraService.startPreview();
      } catch (e) {
        print('Warning: Camera preview failed: $e');
      }

      // Start recording with error handling
      try {
        await _speechService.startListening(
          onResult: (result) {
            print('Speech result: $result');
          },
        );
      } catch (e) {
        print('Warning: Speech listening failed: $e');
      }
    } catch (e) {
      print('Error starting answer: $e');
      _setError('Failed to start recording: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Stop answering and process answer
  Future<void> stopAnswer() async {
    if (!_speechService.isListening) return;

    try {
      await _speechService.stopListening();

      String spokenText = _speechService.lastWords;
      if (spokenText.isEmpty) {
        _setError('No speech detected');
        return;
      }

      // Get speech analytics
      Map<String, dynamic> speechAnalytics =
          _speechService.getSpeechAnalytics();

      // Get camera analytics
      Map<String, dynamic> cameraAnalytics =
          _cameraService.getSessionAnalytics();

      // Evaluate answer with AI
      Map<String, dynamic> evaluation = {};
      if (_aiService != null) {
        try {
          evaluation = await _aiService!.evaluateAnswer(
            question: currentQuestion!,
            answer: spokenText,
            mode: _currentSession!.mode,
          );
        } catch (e) {
          print('AI evaluation failed: $e');
          evaluation = {'overall': 'Đã hoàn thành câu trả lời', 'score': 7.0};
        }
      } else {
        evaluation = {'overall': 'Đã hoàn thành câu trả lời', 'score': 7.0};
      }

      // Create answer object
      Answer answer = Answer(
        questionId: _currentQuestionIndex.toString(),
        question: currentQuestion!,
        spokenText: spokenText,
        audioUrl: '', // Would upload audio file here if needed
        timestamp: DateTime.now(),
        speakingSpeed: speechAnalytics['speakingSpeed'] ?? 0.0,
        clarity: speechAnalytics['clarity'] ?? 0.0,
        emotions: _cameraService.emotionHistory,
        eyeContactRatio: cameraAnalytics['eyeContactRatio'] ?? 0.0,
        aiEvaluation: evaluation['overall'] ?? '',
        score: evaluation['score'] ?? 0,
      );

      _answers.add(answer);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to process answer: ${e.toString()}');
    }
  }

  // Move to next question
  void nextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      _cameraService.clearHistory(); // Reset emotion tracking for new question
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (hasPreviousQuestion) {
      _currentQuestionIndex--;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // End practice session
  Future<void> endSession() async {
    if (_currentSession == null) {
      print('❌ endSession: No current session');
      _setError('Không có phiên luyện tập hiện tại');
      return;
    }

    try {
      print('✅ endSession: Starting end session process');
      _setLoading(true);
      _clearError();

      // Stop services safely
      try {
        await _speechService.stopListening();
      } catch (e) {
        print('⚠️ endSession: Failed to stop speech service: $e');
      }

      try {
        await _cameraService.stopPreview();
      } catch (e) {
        print('⚠️ endSession: Failed to stop camera service: $e');
      }

      // Calculate session analytics
      print('📊 endSession: Calculating analytics');
      _sessionAnalytics = _calculateSessionAnalytics();

      // Generate AI analysis (with fallback if fails)
      Map<String, dynamic> aiAnalysis = {};
      try {
        print('🤖 endSession: Generating AI analysis');
        if (_sessionAnalytics != null && _aiService != null) {
          aiAnalysis = await _aiService!.generateSessionAnalysis(
            answers: _answers,
            analytics: _sessionAnalytics!,
            mode: _currentSession!.mode,
          );
        } else {
          throw Exception('No session analytics or AI service available');
        }
      } catch (e) {
        print('⚠️ endSession: AI analysis failed, using defaults: $e');
        aiAnalysis = {
          'strengths': ['Hoàn thành phiên luyện tập thành công'],
          'improvements': ['Tiếp tục luyện tập để cải thiện kỹ năng'],
          'recommendations': [
            'Thực hành thường xuyên hơn để đạt kết quả tốt hơn'
          ]
        };
      }

      // Update session analytics with AI insights
      if (_sessionAnalytics != null) {
        _sessionAnalytics = SessionAnalytics(
          averageSpeakingSpeed: _sessionAnalytics!.averageSpeakingSpeed,
          averageClarity: _sessionAnalytics!.averageClarity,
          averageEyeContactRatio: _sessionAnalytics!.averageEyeContactRatio,
          averageScore: _sessionAnalytics!.averageScore,
          totalDuration: _sessionAnalytics!.totalDuration,
          emotionAverages: _sessionAnalytics!.emotionAverages,
          strengths: List<String>.from(aiAnalysis['strengths'] ??
              ['Hoàn thành phiên luyện tập thành công']),
          weaknesses: List<String>.from(aiAnalysis['improvements'] ??
              ['Tiếp tục luyện tập để cải thiện']),
          improvements: List<String>.from(
              aiAnalysis['recommendations'] ?? ['Thực hành thường xuyên hơn']),
        );
      } else {
        print('❌ endSession: No session analytics to update');
        throw Exception('Session analytics not available');
      }

      // Update session
      print('💾 endSession: Updating session data');
      _currentSession = PracticeSession(
        id: _currentSession!.id,
        userId: _currentSession!.userId,
        mode: _currentSession!.mode,
        pdfFileName: _currentSession!.pdfFileName,
        pdfUrl: _currentSession!.pdfUrl,
        questions: _currentSession!.questions,
        answers: _answers,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
        analytics: _sessionAnalytics!,
        isCompleted: true,
      );

      // Update session in local storage
      try {
        await _localFirebaseService.updatePracticeSession(_currentSession!);
        print('✅ endSession: Session saved successfully');
      } catch (e) {
        print('⚠️ endSession: Failed to save session: $e');
        // Continue even if save fails
      }

      // Notify listeners about session update
      onSessionUpdated?.call(_currentSession!);

      _isSessionActive = false;
      _stopRealTimeFeedback();

      print('🎯 endSession: Session completed successfully');
      print('📈 Current session: ${_currentSession != null}');
      print('📊 Session analytics: ${_sessionAnalytics != null}');

      // Don't clear session data here - let Result screen access it
      // _appStateManager.clearCurrentSession(); // Removed this line
    } catch (e) {
      print('❌ endSession: Error - ${e.toString()}');
      _setError('Failed to end session: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners(); // Make sure UI updates
    }
  }

  // Calculate session analytics
  SessionAnalytics _calculateSessionAnalytics() {
    if (_answers.isEmpty) {
      print('⚠️ _calculateSessionAnalytics: No answers, using default values');
      return SessionAnalytics(
        averageSpeakingSpeed: 150.0, // Default speaking speed
        averageClarity: 75.0, // Default clarity
        averageEyeContactRatio: 60.0, // Default eye contact
        averageScore: 7.0, // Default score
        totalDuration: DateTime.now()
            .difference(_currentSession?.startTime ?? DateTime.now()),
        emotionAverages: {
          'happiness': 0.5,
          'confidence': 0.6,
          'neutral': 0.7,
          'nervous': 0.2,
        },
        strengths: ['Hoàn thành phiên luyện tập'],
        weaknesses: ['Cần thêm thời gian thực hành'],
        improvements: ['Thực hành thường xuyên hơn'],
      );
    }

    try {
      // Prevent division by zero
      if (_answers.isEmpty) {
        throw Exception('No answers to calculate analytics');
      }

      double avgSpeed =
          _answers.map((a) => a.speakingSpeed).reduce((a, b) => a + b) /
              _answers.length;
      double avgClarity =
          _answers.map((a) => a.clarity).reduce((a, b) => a + b) /
              _answers.length;
      double avgEyeContact =
          _answers.map((a) => a.eyeContactRatio).reduce((a, b) => a + b) /
              _answers.length;
      double avgScore = _answers.map((a) => a.score).reduce((a, b) => a + b) /
          _answers.length;

      Duration totalDuration = DateTime.now().difference(
        _currentSession!.startTime,
      );

      // Calculate emotion averages
      List<EmotionData> allEmotions =
          _answers.expand((a) => a.emotions).toList();
      Map<String, double> emotionAverages = {};

      if (allEmotions.isNotEmpty) {
        emotionAverages = {
          'happiness':
              allEmotions.map((e) => e.happiness).reduce((a, b) => a + b) /
                  allEmotions.length,
          'confidence':
              allEmotions.map((e) => e.confidence).reduce((a, b) => a + b) /
                  allEmotions.length,
          'neutral': allEmotions.map((e) => e.neutral).reduce((a, b) => a + b) /
              allEmotions.length,
          'nervous': allEmotions.map((e) => e.nervous).reduce((a, b) => a + b) /
              allEmotions.length,
        };
      } else {
        // Default emotion values if no emotion data
        emotionAverages = {
          'happiness': 0.5,
          'confidence': 0.6,
          'neutral': 0.7,
          'nervous': 0.2,
        };
      }

      return SessionAnalytics(
        averageSpeakingSpeed: avgSpeed,
        averageClarity: avgClarity,
        averageEyeContactRatio: avgEyeContact,
        averageScore: avgScore,
        totalDuration: totalDuration,
        emotionAverages: emotionAverages,
        strengths: [],
        weaknesses: [],
        improvements: [],
      );
    } catch (e) {
      print('❌ _calculateSessionAnalytics error: $e');
      // Return safe default values
      return SessionAnalytics(
        averageSpeakingSpeed: 150.0,
        averageClarity: 75.0,
        averageEyeContactRatio: 60.0,
        averageScore: 7.0,
        totalDuration: DateTime.now()
            .difference(_currentSession?.startTime ?? DateTime.now()),
        emotionAverages: {
          'happiness': 0.5,
          'confidence': 0.6,
          'neutral': 0.7,
          'nervous': 0.2,
        },
        strengths: ['Hoàn thành phiên luyện tập'],
        weaknesses: ['Cần thêm thời gian thực hành'],
        improvements: ['Thực hành thường xuyên hơn'],
      );
    }
  }

  // Start real-time feedback (called during session)
  void _startRealTimeFeedback() {
    // Update feedback every 2 seconds
    Stream.periodic(const Duration(seconds: 2)).listen((_) {
      if (_isSessionActive) {
        _realTimeFeedback = _cameraService.getRealTimeFeedback();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
  }

  // Stop real-time feedback
  void _stopRealTimeFeedback() {
    _realTimeFeedback.clear();
  }

  // Reset session
  void resetSession() {
    _currentSession = null;
    _isSessionActive = false;
    _selectedPdfFile = null;
    _extractedText = null;
    _questions.clear();
    _currentQuestionIndex = 0;
    _answers.clear();
    _realTimeFeedback.clear();
    _sessionAnalytics = null;
    _clearError();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Clear session data (call this when leaving result screen)
  void clearSessionData() {
    print('🧹 Clearing session data');
    _currentSession = null;
    _sessionAnalytics = null;
    _isSessionActive = false;
    _selectedPdfFile = null;
    _extractedText = null;
    _questions.clear();
    _currentQuestionIndex = 0;
    _answers.clear();
    _realTimeFeedback.clear();
    _clearError();
    _appStateManager.clearCurrentSession();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _errorMessage = error;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _errorMessage = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _speechService.dispose();
    _cameraService.dispose();
    super.dispose();
  }
}
