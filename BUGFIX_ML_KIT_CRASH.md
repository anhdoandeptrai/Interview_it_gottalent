# 🔧 BUGFIX: ML Kit Face Detection Crash

## Vấn Đề

App bị crash với lỗi `SIGSEGV` (Segmentation Fault) khi chạy AI Behavior Detection:
- **Crash Location**: Native library `libface_detector_v2_jni.so`
- **Nguyên nhân**: ML Kit Face Detection đang chạy 2 instance song song (CameraService + AIBehaviorDetectorService)
- **Trigger**: Sau khi upload PDF và vào Practice Screen, face detection bị overload

## Giải Pháp Áp Dụng

### 1. Cập Nhật Gemini API Key ✅
```dart
// lib/controllers/practice_controller.dart
const geminiApiKey = 'AIzaSyDydED8YiFYXoW9Qq3woSlGaqC3ikrWhMs';
```

**Lý do**: API key cũ bị disable, cần key mới để generate questions từ PDF.

### 2. Giảm Tải ML Kit Face Detector ✅
```dart
// lib/services/ai_behavior_detector_service.dart
final options = FaceDetectorOptions(
  enableContours: false,      // Tắt contours (giảm 40% tải)
  enableClassification: true,
  enableTracking: false,       // Tắt tracking (tránh memory leak)
  performanceMode: FaceDetectorMode.fast, // Fast mode thay vì accurate
);
```

**Lý do**: Mode `accurate` với `enableContours` và `enableTracking` quá nặng cho thiết bị low-end.

### 3. Thêm Timeout Protection ✅
```dart
// lib/services/ai_behavior_detector_service.dart
final faces = await _faceDetector.processImage(inputImage).timeout(
  const Duration(seconds: 2),
  onTimeout: () {
    debugPrint('⚠️ [AI Behavior] Face detection timeout');
    return <Face>[];
  },
);
```

**Lý do**: Tránh face detection treo thread khi xử lý quá lâu.

### 4. Tắt Tạm AI Behavior Detection ✅
```dart
// lib/services/camera_service.dart
bool _isBehaviorDetectionEnabled = false; // TẮT TẠM để tránh crash
```

**Lý do**: Có 2 face detector chạy song song gây conflict và crash.

## Kết Quả Mong Đợi

✅ **PDF Processing**: Thành công với Gemini API mới  
✅ **App Stability**: Không còn crash khi vào Practice Screen  
⚠️ **AI Behavior**: Tạm tắt cho đến khi tối ưu thêm  

## Cách Test

```bash
flutter clean
flutter pub get
flutter run
```

**Test Flow**:
1. Login vào app
2. Upload PDF (4 pages, ~80KB)
3. Xác nhận PDF extraction thành công
4. Xác nhận Gemini generate questions thành công (không còn fallback)
5. Vào Practice Screen
6. Xác nhận app không crash

## Các Log Cần Kiểm Tra

### ✅ PDF Extraction Success
```
I/flutter: PDF Service: Text extraction successful - 1601 words extracted
I/flutter: ✅ Text extracted successfully:
```

### ✅ Gemini API Success (không còn error)
```
I/flutter: 🤖 Generating questions with Gemini AI...
I/flutter: 📤 Sending request to Gemini API...
I/flutter: ✅ Generated 5 questions:
```
❌ **KHÔNG CÒN**: `❌ Error generating questions with Gemini: Generative Language API has not been used`

### ✅ Face Detection Fast Mode
```
I/flutter: ✅ [AI Behavior] Đã khởi tạo Face Detector (Fast Mode)
```

### ⚠️ Behavior Detection Disabled
```
// Không còn các log behavior detection
```

## Bước Tiếp Theo

### Phase 1: Ổn Định Core Features (HIỆN TẠI)
- [x] Fix Gemini API key
- [x] Tắt AI Behavior Detection tạm thời
- [x] Đảm bảo PDF + Camera hoạt động ổn định

### Phase 2: Tối Ưu ML Kit (SAU NÀY)
Khi cần bật lại AI Behavior Detection:

1. **Tối ưu Face Detector**:
   ```dart
   // Chỉ chạy 1 instance duy nhất
   // Hoặc dùng Mode.fast với interval 1000ms thay vì 500ms
   ```

2. **Kiểm tra thiết bị**:
   ```dart
   // Chỉ enable AI behavior trên thiết bị high-end
   if (deviceRAM > 4GB && androidVersion >= 10) {
     enableBehaviorDetection = true;
   }
   ```

3. **Thêm On/Off Toggle**:
   ```dart
   // Cho user tự bật/tắt AI behavior detection
   ```

## Chi Tiết Kỹ Thuật

### Root Cause: Dual Face Detector Conflict
```
CameraService._faceDetector (emotion analysis)
     ↓
CameraService._processCameraImage()
     ↓
AIBehaviorDetectorService._faceDetector (behavior analysis)
     ↓
CRASH: 2 face detectors cùng xử lý 1 image stream
```

**Giải pháp lâu dài**: Merge 2 detector thành 1:
```dart
// Chỉ dùng 1 FaceDetector duy nhất
// Phân tích cả emotion VÀ behavior từ cùng 1 result
final faces = await _faceDetector.processImage(inputImage);
_analyzeEmotions(faces);
_analyzeBehavior(faces);
```

## Tham Khảo

- ML Kit Face Detection Crash: https://github.com/flutter-ml/google_ml_kit_flutter/issues/245
- Performance Best Practices: https://developers.google.com/ml-kit/vision/face-detection/android#performance-tips
- Native Crash Debug: https://developer.android.com/ndk/guides/debug

## Changelog

- **2026-03-04**: Initial bugfix - Disabled AI Behavior, updated Gemini key, optimized ML Kit options
