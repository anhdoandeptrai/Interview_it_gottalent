# 🎯 Tính năng Tạo Câu Hỏi từ PDF bằng Gemini AI

## 📖 Tổng quan

Tính năng này cho phép người dùng upload file PDF (CV, tài liệu thuyết trình, mô tả công việc) và hệ thống sẽ tự động:
1. ✅ Trích xuất nội dung từ PDF
2. 🤖 Sử dụng Gemini AI để sinh câu hỏi phù hợp
3. 📝 Tạo phiên luyện tập với các câu hỏi được sinh ra
4. 🎤 Cho phép user luyện tập trả lời với camera và micro

## 🚀 Quy trình hoạt động

### 1. User Flow
```
User chọn chế độ (Phỏng vấn/Thuyết trình)
    ↓
Upload file PDF (CV hoặc tài liệu)
    ↓
Hệ thống validate và extract text từ PDF
    ↓
Gemini AI phân tích nội dung và tạo câu hỏi
    ↓
Hiển thị preview câu hỏi đã tạo
    ↓
User xem và bắt đầu luyện tập
    ↓
Trả lời từng câu hỏi với camera và micro
    ↓
Nhận đánh giá và phản hồi từ AI
```

### 2. Technical Flow

#### A. PDF Processing (`pdf_service.dart`)
```dart
// 1. Validate PDF
validatePdfFile(File pdfFile)
  - Kiểm tra file tồn tại
  - Kiểm tra kích thước (max 50MB)
  - Kiểm tra định dạng hợp lệ

// 2. Extract text
extractTextFromPdf(File pdfFile)
  - Sử dụng Syncfusion PDF package
  - Extract text từ tất cả pages
  - Clean và format text
  - Trả về: text, pageCount, wordCount
```

#### B. AI Question Generation (`ai_service.dart`)
```dart
generateQuestions({
  required String pdfContent,
  required PracticeMode mode,
  int questionCount = 5,
})

Process:
1. Truncate content nếu > 4000 chars (API limit)
2. Build prompt phù hợp với mode (interview/presentation)
3. Gọi Gemini API với prompt
4. Parse response thành danh sách câu hỏi
5. Validate và return câu hỏi
```

#### C. Session Creation (`practice_controller.dart`)
```dart
createSession({
  required PracticeMode mode,
  required File pdfFile,
})

Steps:
1. Validate PDF file
2. Extract text content
3. Upload PDF to Firebase Storage
4. Generate questions using AI
5. Create PracticeSession object
6. Save to local database
7. Sync to Firebase (optional)
8. Navigate to practice screen
```

## 📦 Dependencies

```yaml
dependencies:
  # PDF processing
  syncfusion_flutter_pdf: ^24.1.41
  
  # AI integration
  google_generative_ai: ^0.4.7
  
  # File handling
  file_picker: ^6.1.1
  
  # Firebase
  firebase_core: latest
  firebase_storage: latest
  cloud_firestore: latest
```

## 🔑 API Configuration

### Gemini API Key
File: `lib/controllers/practice_controller.dart`
```dart
void _initializeAI() {
  const geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  _aiService = AIService(geminiApiKey: geminiApiKey);
}
```

**Lấy API Key:**
1. Truy cập: https://makersuite.google.com/app/apikey
2. Tạo project mới hoặc chọn project có sẵn
3. Generate API key
4. Copy và paste vào code

## 🎨 UI Components

### 1. Setup Screen (`getx_modern_setup_screen.dart`)
- File picker với preview
- Loading indicator khi xử lý PDF
- Progress bar cho từng bước:
  - ✅ Kiểm tra file PDF
  - 📖 Trích xuất nội dung
  - 🤖 Sinh câu hỏi bằng AI
  - ✨ Hoàn tất

### 2. Questions Preview Dialog (`questions_preview_dialog.dart`)
- Hiển thị danh sách câu hỏi đã tạo
- Nút "Xem lại" để đóng dialog
- Nút "Bắt đầu luyện tập" để tiếp tục

### 3. Practice Screen (`getx_modern_practice_screen.dart`)
- Hiển thị câu hỏi hiện tại
- Progress bar
- Camera preview
- Recording controls

## 🔧 Customization

### 1. Số lượng câu hỏi
File: `practice_controller.dart`
```dart
final questions = await _aiService.generateQuestions(
  pdfContent: pdfResult['text'],
  mode: mode,
  questionCount: 5, // Thay đổi số này
);
```

### 2. Độ dài nội dung PDF
File: `ai_service.dart`
```dart
String processedContent = pdfContent;
if (pdfContent.length > 4000) { // Thay đổi số này
  processedContent = pdfContent.substring(0, 4000);
}
```

### 3. Prompt cho AI
File: `ai_service.dart` - Method `_buildQuestionGenerationPrompt()`
- Tùy chỉnh hướng dẫn cho AI
- Thay đổi format câu hỏi
- Điều chỉnh độ khó

## 🐛 Error Handling

### 1. PDF Errors
```dart
- File không tồn tại
- File quá lớn (> 50MB)
- File rỗng
- Định dạng không hợp lệ
- Không có text content
```

### 2. AI Errors
```dart
- API key invalid
- Network error
- API rate limit
- Empty response
→ Fallback to predefined questions
```

### 3. Storage Errors
```dart
- Upload failed
- Permission denied
→ Show error and retry
```

## 📊 Logging & Debugging

Tất cả operations đều có logging chi tiết:
```
📄 Starting PDF processing...
✅ PDF validation passed: 1234567 bytes
📖 Extracting text from PDF...
✅ Text extracted successfully:
   - Pages: 2
   - Words: 450
🤖 Generating questions with Gemini AI...
✅ Generated 5 questions
💾 Saving session to local database...
✅ Session saved locally
🎉 Session created successfully!
```

## 🧪 Testing

### Manual Testing Checklist:
- [ ] Upload PDF nhỏ (< 1MB)
- [ ] Upload PDF lớn (> 10MB) - expect error
- [ ] Upload file không phải PDF - expect error
- [ ] PDF không có text - expect error
- [ ] Check câu hỏi được tạo có liên quan đến nội dung
- [ ] Check câu hỏi bằng tiếng Việt
- [ ] Test với chế độ Phỏng vấn
- [ ] Test với chế độ Thuyết trình
- [ ] Test khi network offline - fallback questions

## 📈 Performance

- PDF processing: ~1-3 seconds
- AI question generation: ~3-5 seconds
- Upload to storage: ~2-4 seconds (depends on file size)
- **Total time: ~6-12 seconds**

## 🚀 Future Improvements

1. **Tối ưu prompt AI**
   - Fine-tune prompt cho từng loại nội dung
   - Thêm context về ngành nghề

2. **Cache questions**
   - Lưu câu hỏi đã tạo để tái sử dụng
   - Giảm số lần gọi API

3. **Multiple file formats**
   - Support DOC, DOCX
   - Support images (OCR)

4. **Question quality scoring**
   - Đánh giá chất lượng câu hỏi
   - Chỉ giữ câu hỏi tốt nhất

5. **User feedback loop**
   - Cho phép user rate câu hỏi
   - Cải thiện prompt dựa trên feedback

## 📞 Support

Nếu gặp vấn đề:
1. Check console logs
2. Verify API key
3. Check network connection
4. Verify PDF file format
5. Contact: anhdoandeptrai@github.com

---

**Created by:** Interview App Team  
**Last Updated:** January 2026  
**Version:** 1.0.0
