import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/practice_session.dart';

class AIService {
  late final GenerativeModel _model;
  final String? _openAIApiKey;

  AIService({required String geminiApiKey, String? openAIApiKey})
      : _openAIApiKey = openAIApiKey {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);
  }

  // Generate questions based on PDF content and practice mode
  Future<List<String>> generateQuestions({
    required String pdfContent,
    required PracticeMode mode,
    int questionCount = 5,
  }) async {
    try {
      String prompt = _buildQuestionGenerationPrompt(
        pdfContent,
        mode,
        questionCount,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? '';

      return _parseQuestionsFromResponse(responseText);
    } catch (e) {
      print('Error generating questions with Gemini: $e');

      // Fallback to OpenAI if available
      if (_openAIApiKey != null) {
        return await _generateQuestionsWithOpenAI(
          pdfContent,
          mode,
          questionCount,
        );
      }

      return _getFallbackQuestions(mode);
    }
  }

  // Evaluate answer using AI
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String answer,
    required PracticeMode mode,
  }) async {
    try {
      String prompt = _buildEvaluationPrompt(question, answer, mode);

      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? '';

      return _parseEvaluationFromResponse(responseText);
    } catch (e) {
      print('Error evaluating answer with Gemini: $e');

      // Fallback to OpenAI if available
      if (_openAIApiKey != null) {
        return await _evaluateAnswerWithOpenAI(question, answer, mode);
      }

      return _getFallbackEvaluation();
    }
  }

  // Generate session analysis and recommendations
  Future<Map<String, dynamic>> generateSessionAnalysis({
    required List<Answer> answers,
    required SessionAnalytics analytics,
    required PracticeMode mode,
  }) async {
    try {
      String prompt = _buildAnalysisPrompt(answers, analytics, mode);

      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? '';

      return _parseAnalysisFromResponse(responseText);
    } catch (e) {
      print('Error generating session analysis: $e');
      return _getFallbackAnalysis();
    }
  }

  // Private methods for prompt building
  String _buildQuestionGenerationPrompt(
    String content,
    PracticeMode mode,
    int count,
  ) {
    final modeDescription =
        mode == PracticeMode.interview ? 'phỏng vấn xin việc' : 'thuyết trình';

    return '''
Bạn là một chuyên gia tuyển dụng và huấn luyện kỹ năng mềm hàng đầu tại Việt Nam.

Dựa trên nội dung sau đây, hãy tạo $count câu hỏi chất lượng cao cho buổi luyện tập $modeDescription bằng tiếng Việt:

Nội dung: $content

Yêu cầu:
1. Câu hỏi phải bằng tiếng Việt hoàn toàn
2. Phù hợp với văn hóa làm việc tại Việt Nam
3. Tập trung vào kỹ năng và kinh nghiệm thực tế
4. Từng câu hỏi trên một dòng riêng biệt
5. Không đánh số thứ tự
6. Câu hỏi phải rõ ràng và dễ hiểu

${mode == PracticeMode.interview ? '''
Đối với phỏng vấn, hãy tập trung vào:
- Kinh nghiệm và kỹ năng chuyên môn
- Tình huống xử lý công việc
- Động lực và mục tiêu nghề nghiệp
- Khả năng làm việc nhóm
- Điểm mạnh và cần cải thiện''' : '''
Đối với thuyết trình, hãy tập trung vào:
- Giải thích nội dung chính
- Trình bày ý tưởng sáng tạo
- Phân tích và đánh giá
- Đưa ra kết luận và khuyến nghị
- Tương tác với khán giả'''}

Trả lời chỉ gồm $count câu hỏi, mỗi câu một dòng:''';
  }

  String _buildEvaluationPrompt(
    String question,
    String answer,
    PracticeMode mode,
  ) {
    return '''
Bạn là một chuyên gia đánh giá kỹ năng phỏng vấn và thuyết trình tại Việt Nam.

Hãy đánh giá câu trả lời sau bằng tiếng Việt:

Câu hỏi: $question
Câu trả lời: $answer
Loại: ${mode == PracticeMode.interview ? 'Phỏng vấn' : 'Thuyết trình'}

Hãy trả về đánh giá theo định dạng JSON sau:
{
  "score": 8,
  "overall": "Nhận xét tổng quan bằng tiếng Việt",
  "strengths": [
    "Tham gia tích cực",
    "Nỗ lực kiên trì"
  ],
  "improvements": [
    "Độ tự tin khi nói",
    "Chi tiết trong trả lời"
  ],
  "suggestions": [
    "Luyện tập thường xuyên",
    "Ghi âm và tự nghe lại"
  ]
}

Điểm mạnh thường gặp:
- Tham gia tích cực (Active participation)
- Nỗ lực kiên trì (Consistent effort)
- Tự tin trong giao tiếp
- Nội dung phù hợp

Cần cải thiện thường gặp:
- Độ tự tin khi nói (Speaking confidence)
- Chi tiết trong trả lời (Response detail)
- Ngôn ngữ cơ thể
- Tốc độ nói

Gợi ý cải thiện:
- Luyện tập thường xuyên (Regular practice)
- Ghi âm và tự nghe lại (Record yourself speaking)
- Thực hành trước gương
- Học từ vựng chuyên ngành

Chỉ trả về JSON hợp lệ, không có văn bản khác.''';
  }

  String _buildAnalysisPrompt(
    List<Answer> answers,
    SessionAnalytics analytics,
    PracticeMode mode,
  ) {
    String answersText = answers
        .map((a) =>
            "Câu hỏi: ${a.question}\nCâu trả lời: ${a.spokenText}\nĐiểm: ${a.score}")
        .join('\n\n');

    return '''
Bạn là một chuyên gia phân tích kỹ năng phỏng vấn và thuyết trình.

Phân tích toàn bộ phiên luyện tập ${mode == PracticeMode.interview ? 'phỏng vấn' : 'thuyết trình'} sau:

Thông số phiên:
- Điểm trung bình: ${analytics.averageScore.toStringAsFixed(1)}/10
- Tốc độ nói: ${analytics.averageSpeakingSpeed.toStringAsFixed(1)} từ/phút
- Độ rõ ràng: ${analytics.averageClarity.toStringAsFixed(1)}%
- Giao tiếp mắt: ${analytics.averageEyeContactRatio.toStringAsFixed(1)}%
- Thời gian: ${analytics.totalDuration.inMinutes} phút

Câu hỏi và trả lời:
$answersText

Vui lòng trả lời theo định dạng JSON:
{
  "overall_performance": "[Đánh giá tổng quan bằng tiếng Việt]",
  "strengths": ["[Điểm mạnh 1]", "[Điểm mạnh 2]", "[Điểm mạnh 3]"],
  "improvements": ["[Cần cải thiện 1]", "[Cần cải thiện 2]", "[Cần cải thiện 3]"],
  "recommendations": ["[Khuyến nghị 1]", "[Khuyến nghị 2]", "[Khuyến nghị 3]"],
  "next_steps": "[Bước tiếp theo cụ thể bằng tiếng Việt]"
}''';
  }

  // Parse responses
  List<String> _parseQuestionsFromResponse(String response) {
    List<String> questions = [];

    // Split by lines and extract numbered questions
    List<String> lines = response.split('\n');

    for (String line in lines) {
      String trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          (RegExp(r'^\d+\.').hasMatch(trimmed) ||
              RegExp(r'^\d+\)').hasMatch(trimmed) ||
              trimmed.startsWith('Q:') ||
              trimmed.contains('?'))) {
        // Clean up the question
        String question = trimmed
            .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
            .replaceFirst(RegExp(r'^Q:\s*'), '')
            .trim();

        if (question.isNotEmpty && question.length > 10) {
          questions.add(question);
        }
      }
    }

    return questions.take(10).toList(); // Limit to 10 questions max
  }

  Map<String, dynamic> _parseEvaluationFromResponse(String response) {
    Map<String, dynamic> evaluation = {
      'score': 5,
      'strengths': <String>[],
      'weaknesses': <String>[],
      'suggestions': <String>[],
      'overall': 'Good effort, keep practicing!',
    };

    List<String> lines = response.split('\n');
    String currentSection = '';

    for (String line in lines) {
      String trimmed = line.trim();

      if (trimmed.toLowerCase().startsWith('score:')) {
        String scoreText = trimmed.substring(6).trim();
        evaluation['score'] = int.tryParse(scoreText.split('/')[0]) ?? 5;
      } else if (trimmed.toLowerCase().startsWith('strengths:')) {
        currentSection = 'strengths';
        String content = trimmed.substring(10).trim();
        if (content.isNotEmpty) {
          evaluation['strengths'].add(content);
        }
      } else if (trimmed.toLowerCase().startsWith('weaknesses:')) {
        currentSection = 'weaknesses';
        String content = trimmed.substring(11).trim();
        if (content.isNotEmpty) {
          evaluation['weaknesses'].add(content);
        }
      } else if (trimmed.toLowerCase().startsWith('suggestions:')) {
        currentSection = 'suggestions';
        String content = trimmed.substring(12).trim();
        if (content.isNotEmpty) {
          evaluation['suggestions'].add(content);
        }
      } else if (trimmed.toLowerCase().startsWith('overall:')) {
        evaluation['overall'] = trimmed.substring(8).trim();
        currentSection = '';
      } else if (trimmed.isNotEmpty && currentSection.isNotEmpty) {
        if (trimmed.startsWith('-') || trimmed.startsWith('•')) {
          trimmed = trimmed.substring(1).trim();
        }
        if (trimmed.isNotEmpty) {
          evaluation[currentSection].add(trimmed);
        }
      }
    }

    return evaluation;
  }

  Map<String, dynamic> _parseAnalysisFromResponse(String response) {
    Map<String, dynamic> analysis = {
      'overallPerformance': 'Analysis completed',
      'strengths': <String>[],
      'improvements': <String>[],
      'recommendations': <String>[],
      'nextSteps': <String>[],
    };

    List<String> lines = response.split('\n');
    String currentSection = '';

    for (String line in lines) {
      String trimmed = line.trim();

      if (trimmed.toLowerCase().contains('overall performance:')) {
        analysis['overallPerformance'] = trimmed.split(':').last.trim();
      } else if (trimmed.toLowerCase().contains('key strengths:')) {
        currentSection = 'strengths';
      } else if (trimmed.toLowerCase().contains('areas for improvement:')) {
        currentSection = 'improvements';
      } else if (trimmed.toLowerCase().contains('specific recommendations:')) {
        currentSection = 'recommendations';
      } else if (trimmed.toLowerCase().contains('next steps:')) {
        currentSection = 'nextSteps';
      } else if (trimmed.isNotEmpty && currentSection.isNotEmpty) {
        if (trimmed.startsWith('-') || trimmed.startsWith('•')) {
          trimmed = trimmed.substring(1).trim();
        }
        if (trimmed.isNotEmpty) {
          analysis[currentSection].add(trimmed);
        }
      }
    }

    return analysis;
  }

  // OpenAI fallback methods (if needed)
  Future<List<String>> _generateQuestionsWithOpenAI(
    String content,
    PracticeMode mode,
    int count,
  ) async {
    // Implement OpenAI API call if needed
    return _getFallbackQuestions(mode);
  }

  Future<Map<String, dynamic>> _evaluateAnswerWithOpenAI(
    String question,
    String answer,
    PracticeMode mode,
  ) async {
    // Implement OpenAI API call if needed
    return _getFallbackEvaluation();
  }

  // Fallback methods
  List<String> _getFallbackQuestions(PracticeMode mode) {
    if (mode == PracticeMode.interview) {
      return [
        "Tell me about yourself and your background.",
        "What are your greatest strengths?",
        "Describe a challenging situation you faced and how you handled it.",
        "Where do you see yourself in 5 years?",
        "Why are you interested in this position?",
      ];
    } else {
      return [
        "What is the main topic of your presentation?",
        "What are the key points you want to convey?",
        "How would you engage your audience?",
        "What questions might your audience ask?",
        "How would you conclude your presentation?",
      ];
    }
  }

  Map<String, dynamic> _getFallbackEvaluation() {
    return {
      'score': 6,
      'overall':
          'Câu trả lời có nền tảng tốt, tiếp tục luyện tập để cải thiện.',
      'strengths': [
        'Tham gia tích cực',
        'Nỗ lực kiên trì',
      ],
      'improvements': [
        'Độ tự tin khi nói',
        'Chi tiết trong trả lời',
      ],
      'suggestions': [
        'Luyện tập thường xuyên',
        'Ghi âm và tự nghe lại',
      ],
    };
  }

  Map<String, dynamic> _getFallbackAnalysis() {
    return {
      'overallPerformance': 'Phiên luyện tập hoàn thành tốt',
      'strengths': [
        'Tham gia tích cực',
        'Nỗ lực kiên trì',
      ],
      'improvements': [
        'Độ tự tin khi nói',
        'Chi tiết trong trả lời',
      ],
      'recommendations': [
        'Luyện tập thường xuyên',
        'Ghi âm và tự nghe lại',
      ],
      'nextSteps': [
        'Tập trung vào kỹ năng cụ thể',
        'Tìm kiếm phản hồi từ người khác',
      ],
    };
  }
}
