import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';
  double _confidence = 0.0;

  // Speech analysis metrics
  List<String> _spokenWords = [];
  DateTime? _speechStartTime;
  DateTime? _speechEndTime;
  List<DateTime> _pauseTimes = [];
  DateTime? _lastWordTime;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;
  double get confidence => _confidence;

  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      PermissionStatus permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('Microphone permission not granted');
        return false;
      }

      _isAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      return _isAvailable;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  // Start listening
  Future<void> startListening({
    required Function(String) onResult,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isAvailable) {
      await initialize();
    }

    if (_isAvailable && !_isListening) {
      _resetSpeechMetrics();
      _speechStartTime = DateTime.now();

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _confidence = result.confidence;
          _updateSpeechMetrics(result.recognizedWords);
          onResult(_lastWords);
        },
        onSoundLevelChange: onSoundLevel,
        listenFor: const Duration(minutes: 10), // Max listening time
        pauseFor: const Duration(seconds: 3), // Pause detection
        partialResults: true,
        localeId: 'vi_VN', // Vietnamese locale, change as needed
      );
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _speechEndTime = DateTime.now();
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _resetSpeechMetrics();
    }
  }

  // Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    return await _speechToText.locales();
  }

  // Calculate speaking speed (words per minute)
  double calculateSpeakingSpeed() {
    if (_speechStartTime == null ||
        _speechEndTime == null ||
        _spokenWords.isEmpty) {
      return 0.0;
    }

    Duration speechDuration = _speechEndTime!.difference(_speechStartTime!);
    double minutes = speechDuration.inMilliseconds / 60000.0;

    if (minutes <= 0) return 0.0;

    return _spokenWords.length / minutes;
  }

  // Calculate speech clarity (based on confidence and pause patterns)
  double calculateClarity() {
    if (_confidence == 0.0) return 0.0;

    // Base clarity on confidence
    double clarity = _confidence * 100;

    // Adjust based on pause patterns (too many pauses reduce clarity)
    if (_spokenWords.isNotEmpty && _pauseTimes.isNotEmpty) {
      double pauseRatio = _pauseTimes.length / _spokenWords.length;
      if (pauseRatio > 0.3) {
        // If more than 30% pauses
        clarity *= (1.0 - (pauseRatio - 0.3));
      }
    }

    return clarity.clamp(0.0, 100.0);
  }

  // Get speech duration
  Duration? getSpeechDuration() {
    if (_speechStartTime == null || _speechEndTime == null) {
      return null;
    }
    return _speechEndTime!.difference(_speechStartTime!);
  }

  // Get word count
  int getWordCount() {
    return _spokenWords.length;
  }

  // Get pause information
  Map<String, dynamic> getPauseAnalysis() {
    if (_pauseTimes.isEmpty ||
        _speechStartTime == null ||
        _speechEndTime == null) {
      return {'pauseCount': 0, 'averagePauseLength': 0.0, 'pauseRatio': 0.0};
    }

    Duration totalDuration = _speechEndTime!.difference(_speechStartTime!);
    double averagePauseLength = _pauseTimes.length > 1
        ? _pauseTimes
                  .map((time) => time.millisecondsSinceEpoch)
                  .reduce((a, b) => a + b) /
              _pauseTimes.length /
              1000.0
        : 0.0;

    return {
      'pauseCount': _pauseTimes.length,
      'averagePauseLength': averagePauseLength,
      'pauseRatio': _pauseTimes.length / (totalDuration.inSeconds + 1),
    };
  }

  // Get comprehensive speech analytics
  Map<String, dynamic> getSpeechAnalytics() {
    return {
      'wordCount': getWordCount(),
      'speakingSpeed': calculateSpeakingSpeed(),
      'clarity': calculateClarity(),
      'confidence': _confidence * 100,
      'duration': getSpeechDuration()?.inSeconds ?? 0,
      'pauseAnalysis': getPauseAnalysis(),
      'finalTranscript': _lastWords,
    };
  }

  // Private methods
  void _onSpeechStatus(String status) {
    print('Speech status: $status');
    _isListening = status == 'listening';
  }

  void _onSpeechError(dynamic error) {
    print('Speech error: $error');
    _isListening = false;
  }

  void _resetSpeechMetrics() {
    _spokenWords.clear();
    _pauseTimes.clear();
    _speechStartTime = null;
    _speechEndTime = null;
    _lastWordTime = null;
    _lastWords = '';
    _confidence = 0.0;
  }

  void _updateSpeechMetrics(String recognizedWords) {
    DateTime now = DateTime.now();

    // Track words
    List<String> newWords = recognizedWords.split(' ');
    if (newWords.length > _spokenWords.length) {
      // New words detected
      _spokenWords = newWords;

      // Detect pauses (if there's a significant gap between words)
      if (_lastWordTime != null) {
        Duration timeSinceLastWord = now.difference(_lastWordTime!);
        if (timeSinceLastWord.inMilliseconds > 1500) {
          // 1.5 second pause
          _pauseTimes.add(now);
        }
      }

      _lastWordTime = now;
    }
  }

  // Dispose resources
  void dispose() {
    _speechToText.cancel();
  }
}
