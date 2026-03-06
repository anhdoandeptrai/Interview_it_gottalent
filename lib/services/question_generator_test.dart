import 'ai_service.dart';
import '../models/practice_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Test file để kiểm tra tính năng tạo câu hỏi từ text
/// Run: flutter run lib/services/question_generator_test.dart

void main() async {
  print('🧪 Testing Question Generator with Gemini AI\n');

  // Load .env file
  await dotenv.load(fileName: ".env");
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'];

  if (geminiApiKey == null || geminiApiKey.isEmpty) {
    print('❌ GEMINI_API_KEY not found in .env file');
    print('   Create .env file with: GEMINI_API_KEY=your_key_here');
    return;
  }

  final aiService = AIService(geminiApiKey: geminiApiKey);

  // Sample PDF content for testing
  const sampleContent = '''
THÔNG TIN CÁ NHÂN
Họ và tên: Nguyễn Văn A
Vị trí ứng tuyển: Senior Frontend Developer
Email: nguyenvana@email.com
Điện thoại: 0123456789

KINH NGHIỆM LÀM VIỆC

1. Frontend Developer - ABC Tech Company (2020 - 2023)
- Phát triển ứng dụng web sử dụng React.js và Next.js
- Tối ưu hiệu suất và SEO cho website
- Làm việc với team 5 người, áp dụng Agile/Scrum
- Tích hợp API RESTful và GraphQL
- Xây dựng component library tái sử dụng

2. Junior Developer - XYZ Startup (2018 - 2020)
- Phát triển landing pages và admin dashboard
- Học và áp dụng Vue.js, TypeScript
- Responsive design cho mobile và tablet

KỸ NĂNG
- Frontend: React, Next.js, Vue.js, TypeScript, TailwindCSS
- Backend: Node.js, Express, MongoDB
- Tools: Git, Docker, CI/CD
- Soft skills: Teamwork, Problem-solving, Communication

HỌC VẤN
- Đại học Bách Khoa - Khoa Công Nghệ Thông Tin (2014-2018)
- GPA: 3.5/4.0
''';

  print('📄 Sample Content:');
  print(sampleContent.substring(0, 200) + '...\n');

  // Test Interview Mode
  print('=' * 60);
  print('TEST 1: INTERVIEW MODE');
  print('=' * 60);
  try {
    print('🤖 Generating interview questions...\n');
    final interviewQuestions = await aiService.generateQuestions(
      pdfContent: sampleContent,
      mode: PracticeMode.interview,
      questionCount: 5,
    );

    print('✅ Generated ${interviewQuestions.length} interview questions:\n');
    for (var i = 0; i < interviewQuestions.length; i++) {
      print('${i + 1}. ${interviewQuestions[i]}');
    }
    print('');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // Test Presentation Mode
  print('=' * 60);
  print('TEST 2: PRESENTATION MODE');
  print('=' * 60);
  try {
    print('🤖 Generating presentation questions...\n');
    final presentationQuestions = await aiService.generateQuestions(
      pdfContent: sampleContent,
      mode: PracticeMode.presentation,
      questionCount: 5,
    );

    print(
        '✅ Generated ${presentationQuestions.length} presentation questions:\n');
    for (var i = 0; i < presentationQuestions.length; i++) {
      print('${i + 1}. ${presentationQuestions[i]}');
    }
    print('');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  print('=' * 60);
  print('✨ Test completed!');
  print('=' * 60);
}
