import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/practice_session.dart';

class AIService {
  final String? _openAIApiKey;
  final String _geminiApiKey;

  // Danh sách model Gemini khả dụng (từ Google AI Studio)
  // Ref: https://ai.google.dev/gemini-api/docs/models/gemini
  // Updated: March 2026 - Using latest production models
  static const List<String> _availableModels = [
    'gemini-2.5-flash', // Recommended: Latest, fast, cost-effective
    'gemini-2.5-pro', // Advanced reasoning, most capable
    'gemini-2.0-flash', // Alternative fast option
  ];

  AIService({required String geminiApiKey, String? openAIApiKey})
      : _geminiApiKey = geminiApiKey,
        _openAIApiKey = openAIApiKey;

  // Generate questions based on PDF content and practice mode
  Future<List<String>> generateQuestions({
    required String pdfContent,
    required PracticeMode mode,
    int questionCount = 5,
  }) async {
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

    // Thử từng model cho đến khi thành công
    for (int i = 0; i < _availableModels.length; i++) {
      final modelName = _availableModels[i];
      try {
        print('📤 Trying model: $modelName...');

        final model = GenerativeModel(
          model: modelName,
          apiKey: _geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          ),
        );

        // Add timeout to prevent hanging
        final response =
            await model.generateContent([Content.text(prompt)]).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout after 30 seconds');
          },
        );

        String responseText = response.text ?? '';

        if (responseText.isEmpty) {
          throw Exception('Empty response from Gemini API');
        }

        print('📥 Received response from Gemini API ($modelName)');
        print(
            'Response preview: ${responseText.substring(0, responseText.length > 200 ? 200 : responseText.length)}...');

        final questions = _parseQuestionsFromResponse(responseText);

        if (questions.isEmpty) {
          print('❌ No questions parsed from AI response');
          throw Exception('Gemini AI không thể tạo câu hỏi từ nội dung PDF.');
        }

        // Ensure we have enough questions
        if (questions.length < questionCount) {
          print(
              '⚠️ Only got ${questions.length}/$questionCount questions, adding generic ones...');
          questions.addAll(_getFallbackQuestions(mode, pdfContent)
              .take(questionCount - questions.length));
        }

        print(
            '✅ Successfully generated ${questions.length} questions with $modelName');
        return questions.take(questionCount).toList();
      } catch (e) {
        final errorMsg = e.toString();
        print('❌ Error with model $modelName: $errorMsg');

        // Check if it's an API key issue
        if (errorMsg.contains('API key') ||
            errorMsg.contains('PERMISSION_DENIED') ||
            errorMsg.contains('API_KEY_INVALID')) {
          print(
              '🔑 API Key Error detected. Please verify your Gemini API key.');
          print('   Get a new key at: https://aistudio.google.com/apikey');
        }

        // Nếu là model cuối cùng
        if (i == _availableModels.length - 1) {
          // Fallback to OpenAI if available
          if (_openAIApiKey != null) {
            print('🔄 All Gemini models failed. Trying fallback to OpenAI...');
            try {
              return await _generateQuestionsWithOpenAI(
                pdfContent,
                mode,
                questionCount,
              );
            } catch (openAiError) {
              print('❌ OpenAI also failed: $openAiError');
            }
          }

          // Sử dụng fallback questions khi tất cả AI đều fail
          print('⚠️ All AI services failed. Using fallback questions...');
          print('💡 Tip: Check API key at https://aistudio.google.com/apikey');
          return _getFallbackQuestions(mode, pdfContent);
        }

        // Thử model tiếp theo
        print('⏭️ Trying next model...');
        await Future.delayed(const Duration(milliseconds: 500)); // Rate limit
      }
    }

    // Không bao giờ reach được đây, nhưng cần return để tránh lỗi compile
    return _getFallbackQuestions(mode, pdfContent);
  }

  // Generate fallback questions when AI fails
  List<String> _getFallbackQuestions(PracticeMode mode, String pdfContent) {
    print('📝 Generating fallback questions based on mode: ${mode.name}');

    if (mode == PracticeMode.interview) {
      return [
        'Hãy giới thiệu về bản thân và kinh nghiệm làm việc của bạn.',
        'Bạn có thể chia sẻ về dự án hoặc công việc nổi bật nhất mà bạn đã tham gia?',
        'Điểm mạnh và điểm yếu của bạn là gì? Bạn đang cải thiện điểm yếu như thế nào?',
        'Tại sao bạn muốn làm việc ở vị trí này và tại công ty này?',
        'Bạn mong muốn phát triển sự nghiệp như thế nào trong 3-5 năm tới?',
      ];
    } else {
      return [
        'Hãy giới thiệu tổng quan về chủ đề bạn sẽ thuyết trình.',
        'Bạn có thể giải thích chi tiết về ý chính thứ nhất trong tài liệu không?',
        'Những lợi ích hoặc ứng dụng thực tế của nội dung này là gì?',
        'Bạn có thể đưa ra ví dụ minh họa cho nội dung bạn trình bày?',
        'Kết luận và những điểm cần ghi nhớ quan trọng nhất là gì?',
      ];
    }
  }

  // Evaluate answer using AI
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String answer,
    required PracticeMode mode,
  }) async {
    String prompt = _buildEvaluationPrompt(question, answer, mode);

    // Thử từng model cho đến khi thành công
    for (final modelName in _availableModels) {
      try {
        print('📤 Evaluating answer with model: $modelName...');

        final model = GenerativeModel(
          model: modelName,
          apiKey: _geminiApiKey,
        );

        final response = await model.generateContent([Content.text(prompt)]);
        String responseText = response.text ?? '';

        final evaluation = _parseEvaluationFromResponse(responseText);
        print('✅ Answer evaluated successfully with $modelName');
        return evaluation;
      } catch (e) {
        print('❌ Error with model $modelName: $e');
        // Thử model tiếp theo
        continue;
      }
    }

    // Nếu tất cả model đều fail, thử OpenAI hoặc dùng fallback
    if (_openAIApiKey != null) {
      print('🔄 All Gemini models failed. Trying OpenAI...');
      return await _evaluateAnswerWithOpenAI(question, answer, mode);
    }

    print('⚠️ Using fallback evaluation');
    return _getFallbackEvaluation();
  }

  // Generate session analysis and recommendations
  Future<Map<String, dynamic>> generateSessionAnalysis({
    required List<Answer> answers,
    required SessionAnalytics analytics,
    required PracticeMode mode,
  }) async {
    String prompt = _buildAnalysisPrompt(answers, analytics, mode);

    // Thử từng model cho đến khi thành công
    for (final modelName in _availableModels) {
      try {
        print('📤 Generating session analysis with model: $modelName...');

        final model = GenerativeModel(
          model: modelName,
          apiKey: _geminiApiKey,
        );

        final response = await model.generateContent([Content.text(prompt)]);
        String responseText = response.text ?? '';

        final analysis = _parseAnalysisFromResponse(responseText);
        print('✅ Session analysis generated successfully with $modelName');
        return analysis;
      } catch (e) {
        print('❌ Error with model $modelName: $e');
        // Thử model tiếp theo
        continue;
      }
    }

    // Nếu tất cả model đều fail, dùng fallback
    print('⚠️ Using fallback analysis');
    return _getFallbackAnalysis();
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
