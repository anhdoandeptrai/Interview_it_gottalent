enum PracticeMode { presentation, interview }

class PracticeSession {
  final String id;
  final String userId;
  final PracticeMode mode;
  final String pdfFileName;
  final String pdfUrl;
  final List<String> questions;
  final List<Answer> answers;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionAnalytics analytics;
  final bool isCompleted;

  // Additional getters for UI compatibility
  DateTime get timestamp => startTime;
  double get averageScore => analytics.averageScore;
  int get currentQuestionIndex => answers.length;

  PracticeSession({
    required this.id,
    required this.userId,
    required this.mode,
    required this.pdfFileName,
    required this.pdfUrl,
    required this.questions,
    this.answers = const [],
    required this.startTime,
    this.endTime,
    required this.analytics,
    this.isCompleted = false,
  });

  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      mode: PracticeMode.values.firstWhere(
        (mode) => mode.toString() == map['mode'],
        orElse: () => PracticeMode.interview,
      ),
      pdfFileName: map['pdfFileName'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      questions: List<String>.from(map['questions'] ?? []),
      answers: (map['answers'] as List? ?? [])
          .map((answer) => Answer.fromMap(answer))
          .toList(),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      analytics: SessionAnalytics.fromMap(map['analytics'] ?? {}),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mode': mode.toString(),
      'pdfFileName': pdfFileName,
      'pdfUrl': pdfUrl,
      'questions': questions,
      'answers': answers.map((answer) => answer.toMap()).toList(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'analytics': analytics.toMap(),
      'isCompleted': isCompleted,
    };
  }
}

class Answer {
  final String questionId;
  final String question;
  final String spokenText;
  final String audioUrl;
  final DateTime timestamp;
  final double speakingSpeed; // words per minute
  final double clarity; // percentage
  final List<EmotionData> emotions;
  final double eyeContactRatio;
  final String aiEvaluation;
  final int score; // 1-10

  Answer({
    required this.questionId,
    required this.question,
    required this.spokenText,
    required this.audioUrl,
    required this.timestamp,
    required this.speakingSpeed,
    required this.clarity,
    required this.emotions,
    required this.eyeContactRatio,
    required this.aiEvaluation,
    required this.score,
  });

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      questionId: map['questionId'] ?? '',
      question: map['question'] ?? '',
      spokenText: map['spokenText'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      speakingSpeed: (map['speakingSpeed'] ?? 0).toDouble(),
      clarity: (map['clarity'] ?? 0).toDouble(),
      emotions: (map['emotions'] as List? ?? [])
          .map((emotion) => EmotionData.fromMap(emotion))
          .toList(),
      eyeContactRatio: (map['eyeContactRatio'] ?? 0).toDouble(),
      aiEvaluation: map['aiEvaluation'] ?? '',
      score: map['score'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'question': question,
      'spokenText': spokenText,
      'audioUrl': audioUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'speakingSpeed': speakingSpeed,
      'clarity': clarity,
      'emotions': emotions.map((emotion) => emotion.toMap()).toList(),
      'eyeContactRatio': eyeContactRatio,
      'aiEvaluation': aiEvaluation,
      'score': score,
    };
  }
}

class EmotionData {
  final DateTime timestamp;
  final double happiness;
  final double confidence;
  final double neutral;
  final double nervous;
  final bool lookingAtCamera;

  EmotionData({
    required this.timestamp,
    required this.happiness,
    required this.confidence,
    required this.neutral,
    required this.nervous,
    required this.lookingAtCamera,
  });

  factory EmotionData.fromMap(Map<String, dynamic> map) {
    return EmotionData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      happiness: (map['happiness'] ?? 0).toDouble(),
      confidence: (map['confidence'] ?? 0).toDouble(),
      neutral: (map['neutral'] ?? 0).toDouble(),
      nervous: (map['nervous'] ?? 0).toDouble(),
      lookingAtCamera: map['lookingAtCamera'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'happiness': happiness,
      'confidence': confidence,
      'neutral': neutral,
      'nervous': nervous,
      'lookingAtCamera': lookingAtCamera,
    };
  }
}

class SessionAnalytics {
  final double averageSpeakingSpeed;
  final double averageClarity;
  final double averageEyeContactRatio;
  final double averageScore;
  final Duration totalDuration;
  final Map<String, double> emotionAverages;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvements;

  SessionAnalytics({
    required this.averageSpeakingSpeed,
    required this.averageClarity,
    required this.averageEyeContactRatio,
    required this.averageScore,
    required this.totalDuration,
    required this.emotionAverages,
    required this.strengths,
    required this.weaknesses,
    required this.improvements,
  });

  factory SessionAnalytics.fromMap(Map<String, dynamic> map) {
    return SessionAnalytics(
      averageSpeakingSpeed: (map['averageSpeakingSpeed'] ?? 0).toDouble(),
      averageClarity: (map['averageClarity'] ?? 0).toDouble(),
      averageEyeContactRatio: (map['averageEyeContactRatio'] ?? 0).toDouble(),
      averageScore: (map['averageScore'] ?? 0).toDouble(),
      totalDuration: Duration(milliseconds: map['totalDuration'] ?? 0),
      emotionAverages: Map<String, double>.from(map['emotionAverages'] ?? {}),
      strengths: List<String>.from(map['strengths'] ?? []),
      weaknesses: List<String>.from(map['weaknesses'] ?? []),
      improvements: List<String>.from(map['improvements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageSpeakingSpeed': averageSpeakingSpeed,
      'averageClarity': averageClarity,
      'averageEyeContactRatio': averageEyeContactRatio,
      'averageScore': averageScore,
      'totalDuration': totalDuration.inMilliseconds,
      'emotionAverages': emotionAverages,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'improvements': improvements,
    };
  }
}
