import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../viewmodels/base_viewmodel.dart';
import '../controllers/practice_controller.dart';
import '../models/practice_session.dart';
import '../models/user_statistics.dart';

class PracticeViewModel extends BaseViewModel {
  // Use lazy initialization with better error handling
  PracticeController get _practiceController {
    try {
      return Get.find<PracticeController>();
    } catch (e) {
      // If not found, put it and return
      Get.put<PracticeController>(PracticeController());
      return Get.find<PracticeController>();
    }
  }

  // Setup form fields
  final Rx<File?> _selectedFile = Rx<File?>(null);
  final Rx<PracticeMode> _selectedMode = PracticeMode.presentation.obs;

  // Session state
  final RxBool _isSessionActive = false.obs;
  final RxBool _isRecording = false.obs;
  final RxString _currentInstruction = ''.obs;
  final RxDouble _progress = 0.0.obs;

  // Additional reactive properties for home screen
  final Rx<List<PracticeSession>> recentSessions =
      Rx<List<PracticeSession>>([]);
  final Rx<UserStatistics?> userStatistics = Rx<UserStatistics?>(null);

  // Setup form properties
  final RxString selectedModeString = 'interview'.obs;
  final Rx<PlatformFile?> selectedFileSetup = Rx<PlatformFile?>(null);
  final RxBool isFileValid = false.obs;

  // Getters
  File? get selectedFile => _selectedFile.value;
  PracticeMode get selectedMode => _selectedMode.value;
  bool get isSessionActive => _isSessionActive.value;
  bool get isRecording => _isRecording.value;
  String get currentInstruction => _currentInstruction.value;
  double get progress => _progress.value;

  // Getters from controller
  PracticeSession? get currentSession => _practiceController.currentSession;
  List<PracticeSession> get sessionHistory =>
      _practiceController.sessionHistory;
  SessionAnalytics? get sessionAnalytics =>
      _practiceController.sessionAnalytics;
  String get currentQuestion => _practiceController.currentQuestion;
  int get currentQuestionIndex => _practiceController.currentQuestionIndex;
  double get sessionProgress => _practiceController.sessionProgress;

  @override
  void onInit() {
    super.onInit();
    _setupBindings();
    loadUserData();
  }

  void _setupBindings() {
    // Bind controller states to viewmodel
    ever(_practiceController.isSessionInProgressRx, (bool isInProgress) {
      _isSessionActive.value = isInProgress;
    });

    ever(_practiceController.isRecordingRx, (bool recording) {
      _isRecording.value = recording;
    });

    ever(_practiceController.sessionProgressRx, (double progress) {
      _progress.value = progress;
    });
  }

  // Navigation methods
  void navigateToSetup() {
    Get.toNamed('/practice-setup');
  }

  void navigateToHome() {
    Get.offAllNamed('/home');
  }

  void viewSessionDetails(String sessionId) {
    Get.snackbar(
      'Chi tiết phiên',
      'Xem chi tiết phiên $sessionId',
      backgroundColor: Get.theme.primaryColor.withOpacity(0.8),
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      setBusy();

      // Load recent sessions
      final sessions = await _loadRecentSessions();
      recentSessions.value = sessions;

      // Load user statistics
      final stats = await _loadUserStatistics();
      userStatistics.value = stats;
    } catch (e) {
      setError('Không thể tải dữ liệu người dùng: $e');
    } finally {
      setIdle();
    }
  }

  Future<List<PracticeSession>> _loadRecentSessions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  Future<UserStatistics> _loadUserStatistics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserStatistics(
      totalSessions: 5,
      averageScore: 0.8,
      totalPracticeTime: const Duration(hours: 2, minutes: 30),
      improvementRate: 0.15,
    );
  }

  // File selection
  void setSelectedFile(File? file) {
    _selectedFile.value = file;
    clearError();
  }

  // Mode selection
  void setSelectedMode(PracticeMode mode) {
    _selectedMode.value = mode;
  }

  void selectMode(String mode) {
    selectedModeString.value = mode;
  }

  // File handling methods for setup
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFileSetup.value = result.files.first;
        isFileValid.value = _validateFile(result.files.first);
      }
    } catch (e) {
      setError('Không thể chọn file: $e');
    }
  }

  bool _validateFile(PlatformFile file) {
    if (file.size > 10 * 1024 * 1024) {
      setError('File quá lớn. Vui lòng chọn file nhỏ hơn 10MB');
      return false;
    }

    final allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];
    final extension = file.extension?.toLowerCase();
    if (extension == null || !allowedExtensions.contains(extension)) {
      setError('Định dạng file không được hỗ trợ');
      return false;
    }

    return true;
  }

  void clearSelectedFile() {
    selectedFileSetup.value = null;
    isFileValid.value = false;
  }

  // Start practice session
  Future<void> startPractice() async {
    if (!_validateSetup()) return;

    try {
      setBusy();
      Get.toNamed('/practice-session');
    } catch (e) {
      setError('Không thể bắt đầu phiên luyện tập: $e');
    } finally {
      setIdle();
    }
  }

  bool _validateSetup() {
    if (selectedModeString.value == 'upload' &&
        selectedFileSetup.value == null) {
      setError('Vui lòng chọn file để upload');
      return false;
    }

    if (selectedModeString.value == 'upload' && !isFileValid.value) {
      setError('File được chọn không hợp lệ');
      return false;
    }

    return true;
  }

  // Validation
  String? validateFileSelection() {
    if (_selectedFile.value == null) {
      return 'Vui lòng chọn file PDF';
    }

    final fileName = _selectedFile.value!.path.toLowerCase();
    if (!fileName.endsWith('.pdf')) {
      return 'Chỉ hỗ trợ file PDF';
    }

    return null;
  }

  // Get mode description
  String get modeDescription {
    switch (_selectedMode.value) {
      case PracticeMode.presentation:
        return 'thuyết trình';
      case PracticeMode.interview:
        return 'phỏng vấn';
    }
  }

  // Create session with file upload
  Future<void> createSession({
    required PracticeMode mode,
    required File pdfFile,
    required String userId,
  }) async {
    try {
      setBusy();

      await _practiceController.createSession(
        mode: mode,
        pdfFile: pdfFile,
      );

      _selectedMode.value = mode;
      _selectedFile.value = pdfFile;
      _isSessionActive.value = true;
    } catch (e) {
      setError('Không thể tạo phiên luyện tập: $e');
      rethrow;
    } finally {
      setIdle();
    }
  }

  // Start answer recording
  Future<void> startAnswer() async {
    try {
      await _practiceController.startAnswer();
      _isRecording.value = true;
    } catch (e) {
      setError('Không thể bắt đầu ghi âm: $e');
    }
  }

  // Stop answer recording
  Future<void> stopAnswer() async {
    try {
      await _practiceController.stopAnswer();
      _isRecording.value = false;
    } catch (e) {
      setError('Không thể dừng ghi âm: $e');
    }
  }

  // Get mode title
  String get modeTitle {
    switch (_selectedMode.value) {
      case PracticeMode.presentation:
        return 'Luyện tập Thuyết trình';
      case PracticeMode.interview:
        return 'Luyện tập Phỏng vấn';
    }
  }

  // Start session
  Future<void> startSession() async {
    final validation = validateFileSelection();
    if (validation != null) {
      setError(validation);
      return;
    }

    switch (_selectedMode.value) {
      case PracticeMode.presentation:
        _currentInstruction.value =
            'Hãy bắt đầu thuyết trình dựa trên nội dung bạn đã chuẩn bị';
        break;
      case PracticeMode.interview:
        _currentInstruction.value =
            'Hãy giới thiệu bản thân và chờ câu hỏi đầu tiên';
        break;
    }
  }

  // Recording controls
  Future<void> toggleRecording() async {
    _isRecording.value = !_isRecording.value;
  }

  Future<void> pauseSession() async {
    // Placeholder implementation
  }

  Future<void> resumeSession() async {
    // Placeholder implementation
  }

  Future<void> endSession() async {
    Get.toNamed('/practice-result');
  }

  // Format methods
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String formatScore(double score) {
    return '${(score * 100).toInt()}%';
  }

  String getScoreDescription(double score) {
    if (score >= 0.9) return 'Xuất sắc';
    if (score >= 0.8) return 'Tốt';
    if (score >= 0.7) return 'Khá';
    if (score >= 0.6) return 'Trung bình';
    return 'Cần cải thiện';
  }

  String getScoreColorHex(double score) {
    if (score >= 0.8) return '#10B981';
    if (score >= 0.6) return '#F59E0B';
    return '#EF4444';
  }

  // Get progress text
  String getProgressText() {
    final session = currentSession;
    if (session == null) return '';

    final totalQuestions = session.questions.length;
    return 'Câu 1/$totalQuestions';
  }

  // Reset methods
  void reset() {
    _selectedFile.value = null;
    _selectedMode.value = PracticeMode.presentation;
    _isSessionActive.value = false;
    _isRecording.value = false;
    _currentInstruction.value = '';
    _progress.value = 0.0;
    clearError();
  }
}
