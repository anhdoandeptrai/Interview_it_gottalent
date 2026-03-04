import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/practice_session.dart';

class AIService {
  late final GenerativeModel _model;
  final String? _openAIApiKey;

  AIService({required String geminiApiKey, String? openAIApiKey})
      : _openAIApiKey = openAIApiKey {
    // Sử dụng gemini-1.5-flash (stable version - no beta/latest suffix)
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
  }

  // Generate questions based on PDF content and practice mode
  Future<List<String>> generateQuestions({
    required String pdfContent,
    required PracticeMode mode,
    int questionCount = 5,
  }) async {
    try {
      print(
          '🤖 AI Service: Generating $questionCount questions for ${mode.name} mode');

      // Limit content length to avoid API limits
      String processedContent = pdfContent;
      if (pdfContent.length > 4000) {
        processedContent = pdfContent.substring(0, 4000);
        print('⚠️ Content truncated to 4000 characters for API limit');
      }

      String prompt = _buildQuestionGenerationPrompt(
        processedContent,
        mode,
        questionCount,
      );

      print('📤 Sending request to Gemini API...');
      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? '';

      print('📥 Received response from Gemini API');
      print(
          'Response preview: ${responseText.substring(0, responseText.length > 200 ? 200 : responseText.length)}...');

      final questions = _parseQuestionsFromResponse(responseText);

      if (questions.isEmpty) {
        print('❌ No questions parsed from AI response');
        throw Exception(
            'Gemini AI không thể tạo câu hỏi từ nội dung PDF. Vui lòng thử lại hoặc sử dụng file PDF khác.');
      }

      print('✅ Successfully generated ${questions.length} questions');
      return questions;
    } catch (e) {
      print('❌ Error generating questions with Gemini: $e');

      // Fallback to OpenAI if available
      if (_openAIApiKey != null) {
        print('🔄 Trying fallback to OpenAI...');
        return await _generateQuestionsWithOpenAI(
          pdfContent,
          mode,
          questionCount,
        );
      }

      // Throw error - không dùng fallback nữa
      throw Exception(
          'Không thể tạo câu hỏi từ Gemini AI: ${e.toString()}. Vui lòng kiểm tra kết nối internet và thử lại.');
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

NHIỆM VỤ: Dựa trên nội dung sau đây, hãy tạo $count câu hỏi chất lượng cao cho buổi luyện tập $modeDescription bằng tiếng Việt.

NỘI DUNG:
$content

YÊU CẦU BẮT BUỘC:
1. Tất cả câu hỏi phải bằng tiếng Việt 100%
2. Câu hỏi phải liên quan trực tiếp đến nội dung được cung cấp
3. Mỗi câu hỏi phải rõ ràng, cụ thể và dễ hiểu
4. Độ dài mỗi câu hỏi: 10-30 từ
5. Tránh câu hỏi quá chung chung hoặc quá đơn giản

${mode == PracticeMode.interview ? '''
HƯỚNG DẪN CHO PHỎNG VẤN:
- Tập trung vào kinh nghiệm và kỹ năng trong nội dung
- Hỏi về cách xử lý tình huống thực tế
- Đánh giá khả năng áp dụng kiến thức vào công việc
- Khai thác điểm mạnh và tiềm năng phát triển
- Kiểm tra sự hiểu biết về lĩnh vực chuyên môn

VÍ DỤ CÂU HỎI TỐT:
- "Bạn có thể chia sẻ về [kỹ năng cụ thể] được đề cập trong CV không?"
- "Trong dự án [tên dự án], bạn đã đối mặt với thách thức nào và giải quyết như thế nào?"
- "Với kinh nghiệm về [lĩnh vực], bạn sẽ đóng góp gì cho vị trí này?"''' : '''
HƯỚNG DẪN CHO THUYẾT TRÌNH:
- Yêu cầu giải thích các khái niệm chính trong tài liệu
- Hỏi về ứng dụng thực tế của nội dung
- Kiểm tra khả năng truyền đạt và phân tích
- Đánh giá sự hiểu biết sâu về chủ đề
- Khuyến khích thảo luận và đưa ra quan điểm

VÍ DỤ CÂU HỎI TỐT:
- "Bạn có thể giải thích về [khái niệm chính] được trình bày không?"
- "Ứng dụng thực tế của [nội dung] trong công việc là gì?"
- "So sánh [điểm A] và [điểm B], bạn nhận thấy điểm nào quan trọng hơn?"'''}

ĐỊNH DẠNG TRẢ LỜI:
Trả về ĐÚNG $count câu hỏi, mỗi câu trên một dòng riêng, đánh số thứ tự:

1. [Câu hỏi thứ nhất]
2. [Câu hỏi thứ hai]
3. [Câu hỏi thứ ba]
...

CHÚ Ý: KHÔNG thêm giải thích, ghi chú hay văn bản nào khác ngoài $count câu hỏi được đánh số.
''';
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

    // Try to parse JSON format first (if AI returns structured data)
    try {
      // Remove markdown code blocks if present
      String cleanResponse =
          response.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parse different formats
      if (cleanResponse.startsWith('[') && cleanResponse.endsWith(']')) {
        // JSON array format
        final decoded = jsonDecode(cleanResponse) as List;
        questions = decoded.map((q) => q.toString()).toList();
      }
    } catch (e) {
      // Not JSON, continue with text parsing
    }

    // If JSON parsing failed or returned empty, try text parsing
    if (questions.isEmpty) {
      List<String> lines = response.split('\n');

      for (String line in lines) {
        String trimmed = line.trim();

        // Skip empty lines and headers
        if (trimmed.isEmpty ||
            trimmed.toLowerCase().contains('câu hỏi') ||
            trimmed.toLowerCase().startsWith('questions:')) {
          continue;
        }

        // Check if line looks like a question
        bool looksLikeQuestion = false;

        // Pattern 1: Numbered questions (1. , 1) , Question 1:)
        if (RegExp(r'^\d+[\.\):]').hasMatch(trimmed)) {
          looksLikeQuestion = true;
          trimmed = trimmed.replaceFirst(RegExp(r'^\d+[\.\):]\s*'), '');
        }

        // Pattern 2: Bullet points (-, *, •)
        if (RegExp(r'^[\-\*•]').hasMatch(trimmed)) {
          looksLikeQuestion = true;
          trimmed = trimmed.replaceFirst(RegExp(r'^[\-\*•]\s*'), '');
        }

        // Pattern 3: Question prefix (Q:, Question:)
        if (RegExp(r'^(Q|Question|Câu hỏi)\s*[:]\s*', caseSensitive: false)
            .hasMatch(trimmed)) {
          looksLikeQuestion = true;
          trimmed = trimmed.replaceFirst(
              RegExp(r'^(Q|Question|Câu hỏi)\s*[:]\s*', caseSensitive: false),
              '');
        }

        // Pattern 4: Contains question mark
        if (trimmed.contains('?')) {
          looksLikeQuestion = true;
        }

        // Clean up and validate
        trimmed = trimmed.trim();

        if (looksLikeQuestion && trimmed.isNotEmpty && trimmed.length > 10) {
          // Ensure question ends with proper punctuation
          if (!trimmed.endsWith('?') && !trimmed.endsWith('.')) {
            trimmed += '?';
          }
          questions.add(trimmed);
        }
      }
    }

    print('📋 Parsed ${questions.length} questions from response');

    // Limit to requested count + 2 (for quality selection)
    return questions.take(7).toList();
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
    // Throw error - OpenAI not implemented
    throw Exception(
        'OpenAI integration chưa được triển khai. Chỉ hỗ trợ Gemini AI.');
  }

  Future<Map<String, dynamic>> _evaluateAnswerWithOpenAI(
    String question,
    String answer,
    PracticeMode mode,
  ) async {
    // Implement OpenAI API call if needed
    return _getFallbackEvaluation();
  }

  // Fallback methods removed - all questions must come from Gemini AI

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
