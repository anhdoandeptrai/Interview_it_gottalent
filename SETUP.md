# Hướng dẫn Setup Chi tiết

## Bước 1: Cấu hình Firebase

### 1.1. Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" (Thêm dự án)
3. Nhập tên project: "interview-practice-app"
4. Tắt Google Analytics nếu không cần thiết
5. Click "Create project"

### 1.2. Cấu hình Authentication
1. Trong Firebase Console, vào "Authentication"
2. Click tab "Sign-in method"
3. Enable "Email/Password"
4. Lưu cài đặt

### 1.3. Cấu hình Firestore Database
1. Vào "Firestore Database"
2. Click "Create database"
3. Chọn "Test mode" (cho development)
4. Chọn location gần nhất
5. Click "Done"

### 1.4. Cấu hình Storage
1. Vào "Storage" 
2. Click "Get started"
3. Chọn "Test mode"
4. Chọn location
5. Click "Done"

### 1.5. Thêm Android App
1. Trong Project Overview, click icon Android
2. Package name: `com.example.interview_app`
3. App nickname: "Interview Practice App"
4. Download `google-services.json`
5. Copy file vào `android/app/`

## Bước 2: Cấu hình FlutterFire

### 2.1. Cài đặt Tools
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Cài đặt FlutterFire CLI
flutter pub global activate flutterfire_cli

# Login Firebase
firebase login
```

### 2.2. Cấu hình Project
```bash
# Từ thư mục root của project
flutterfire configure

# Chọn Firebase project vừa tạo
# Chọn platforms: android, ios (hoặc theo nhu cầu)
# Tool sẽ tự tạo file firebase_options.dart
```

## Bước 3: Cấu hình Google Generative AI

### 3.1. Lấy API Key
1. Truy cập [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API key"
3. Copy API key

### 3.2. Cập nhật Code
Mở file `lib/main.dart` và thay thế:
```dart
PracticeProvider(
  geminiApiKey: 'YOUR_ACTUAL_API_KEY_HERE', // Paste API key ở đây
  openAIApiKey: null, // Hoặc OpenAI key nếu có
)
```

## Bước 4: Cấu hình Quyền (Permissions)

### 4.1. Android
File `android/app/src/main/AndroidManifest.xml` đã được cấu hình sẵn với:
- Camera permission
- Microphone permission
- Internet access
- Storage access

### 4.2. iOS (nếu cần)
Thêm vào `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to record practice sessions</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your speech</string>
```

## Bước 5: Test và Chạy

### 5.1. Kiểm tra Dependencies
```bash
flutter pub get
flutter doctor
```

### 5.2. Chạy App
```bash
# Chạy trên emulator hoặc device
flutter run

# Hoặc chạy debug mode
flutter run --debug
```

## Bước 6: Test Tính năng

### 6.1. Test Authentication
1. Mở app
2. Tạo tài khoản mới với email/password
3. Đăng nhập

### 6.2. Test PDF Upload
1. Chuẩn bị file PDF mẫu (CV hoặc slide)
2. Chọn chế độ luyện tập
3. Upload PDF
4. Kiểm tra AI có tạo câu hỏi không

### 6.3. Test Camera/Microphone
1. Bắt đầu phiên luyện tập
2. Kiểm tra camera preview
3. Test microphone recording
4. Kiểm tra face detection

## Troubleshooting

### Lỗi Firebase
```
Error: FirebaseOptions not configured
```
**Giải pháp**: Chạy lại `flutterfire configure`

### Lỗi API Key
```
Error: API key not valid
```
**Giải pháp**: Kiểm tra API key Google Generative AI

### Lỗi Permission
```
Camera/Microphone not working
```
**Giải pháp**: 
- Kiểm tra permissions trong AndroidManifest.xml
- Test trên device thật, không phải emulator
- Cấp quyền thủ công trong Settings > Apps > Interview App

### Lỗi PDF
```
Cannot extract text from PDF
```
**Giải pháp**: 
- Đảm bảo PDF không bị mã hóa
- Thử với PDF khác
- Kiểm tra file có text thật không phải scan image

## Production Setup (Tùy chọn)

### Bảo mật Firebase
1. Cập nhật Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /practice_sessions/{sessionId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

2. Cập nhật Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /pdfs/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /audio/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Tối ưu hóa
1. Enable R8 code shrinking (Android)
2. Optimize images và assets
3. Enable proguard
4. Setup CI/CD pipeline

## Liên hệ Support
- Email: support@example.com
- GitHub Issues: Create issue trên repository
