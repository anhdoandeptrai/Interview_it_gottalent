# Ứng dụng Luyện tập Kỹ năng Thuyết trình và Phỏng vấn

## Mô tả

Ứng dụng Flutter giúp người dùng luyện tập và cải thiện kỹ năng thuyết trình và phỏng vấn thông qua AI và phân tích thời gian thực.

## Tính năng chính

### 🔐 Xác thực người dùng
- Đăng ký/Đăng nhập bằng Firebase Authentication
- Quản lý hồ sơ người dùng

### 📝 Chế độ luyện tập
- **Phỏng vấn**: Upload CV/Resume (PDF) để AI tạo câu hỏi phỏng vấn
- **Thuyết trình**: Upload slide (PDF) để AI tạo câu hỏi thuyết trình

### 🤖 Trí tuệ nhân tạo
- Phân tích nội dung PDF
- Sinh câu hỏi tự động phù hợp với nội dung
- Đánh giá câu trả lời và đưa ra feedback

### 🎥 Luyện tập trực tiếp
- Camera preview để tự quan sát
- Thu âm giọng nói với speech-to-text
- Phân tích gương mặt và cảm xúc thời gian thực
- Phát hiện eye contact và biểu cảm

### 📊 Phân tích chi tiết
- Thống kê tốc độ nói, độ rõ ràng
- Biểu đồ cảm xúc theo thời gian
- Đánh giá eye contact ratio
- Báo cáo điểm mạnh, điểm yếu và gợi ý cải thiện

### 💾 Lưu trữ dữ liệu
- Lưu trữ phiên luyện tập trên Firebase Firestore
- Lịch sử luyện tập với khả năng xem lại
- Thống kê tiến bộ theo thời gian

## Công nghệ sử dụng

### Frontend
- **Flutter**: Framework UI đa nền tảng
- **Provider**: Quản lý state
- **Camera**: Truy cập camera thiết bị
- **Speech-to-Text**: Chuyển đổi giọng nói thành văn bản

### Backend & Cloud Services
- **Firebase Core**: Khởi tạo Firebase
- **Firebase Auth**: Xác thực người dùng
- **Cloud Firestore**: Cơ sở dữ liệu NoSQL
- **Firebase Storage**: Lưu trữ file PDF và audio

### AI & Machine Learning
- **Google Generative AI**: Tạo câu hỏi và đánh giá câu trả lời
- **Google ML Kit Face Detection**: Phân tích gương mặt và cảm xúc
- **Syncfusion PDF**: Trích xuất văn bản từ PDF

### UI & Data Visualization
- **FL Chart**: Biểu đồ và thống kê
- **File Picker**: Chọn file PDF
- **Permission Handler**: Quản lý quyền truy cập

## Cài đặt và Chạy

### Yêu cầu
- Flutter SDK >= 3.8.1
- Dart SDK
- Android Studio hoặc VS Code
- Tài khoản Firebase
- API key cho Google Generative AI

### Bước 1: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 2: Cấu hình Firebase

1. Tạo project Firebase tại [Firebase Console](https://console.firebase.google.com)
2. Cài đặt Firebase CLI:
```bash
npm install -g firebase-tools
```

3. Cài đặt FlutterFire CLI:
```bash
flutter pub global activate flutterfire_cli
```

4. Cấu hình Firebase cho project:
```bash
flutterfire configure
```

5. Cập nhật file `lib/firebase_options.dart` với cấu hình thực tế

### Bước 3: Cấu hình Google AI

1. Lấy API key từ [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Cập nhật API key trong `lib/main.dart`:
```dart
PracticeProvider(
  geminiApiKey: 'YOUR_ACTUAL_GEMINI_API_KEY', // Thay bằng API key thực
  openAIApiKey: 'YOUR_OPENAI_API_KEY', // Tùy chọn
)
```

### Bước 4: Cấu hình quyền

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to record practice sessions</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your speech</string>
```

### Bước 5: Chạy ứng dụng
```bash
flutter run
```

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   └── practice_session.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── practice_provider.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── camera_service.dart
│   ├── speech_service.dart
│   ├── pdf_service.dart
│   └── firebase_service.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── practice/
│       ├── setup_screen.dart
│       ├── practice_screen.dart
│       └── result_screen.dart
├── widgets/                  # Reusable widgets
└── utils/                    # Utilities
```

## Luồng hoạt động

1. **Đăng nhập**: Người dùng đăng ký/đăng nhập bằng email
2. **Chọn chế độ**: Phỏng vấn hoặc Thuyết trình
3. **Upload PDF**: Tải lên CV (phỏng vấn) hoặc slide (thuyết trình)
4. **AI xử lý**: Hệ thống phân tích PDF và sinh câu hỏi
5. **Luyện tập**: Camera mở, hiển thị câu hỏi, ghi âm trả lời
6. **Phân tích real-time**: Phát hiện gương mặt, cảm xúc, eye contact
7. **Kết quả**: Báo cáo chi tiết với điểm số và đánh giá
8. **Lưu trữ**: Dữ liệu được lưu vào Firebase để xem lại

## Lưu ý quan trọng

1. **API Keys**: Cần cấu hình API keys thực tế trước khi chạy
2. **Firebase**: Phải thiết lập Firebase project và cấu hình
3. **Permissions**: Cần quyền camera và microphone
4. **Testing**: Test trên thiết bị thật để camera/mic hoạt động

## License

MIT License
