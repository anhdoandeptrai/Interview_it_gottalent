# 🔥 Firebase Data Sync - Hướng dẫn đồng bộ dữ liệu

## Tổng quan

Hệ thống đã được cập nhật để **đồng bộ dữ liệu giữa các màn hình** và Firebase Firestore. Tất cả dữ liệu người dùng, thống kê, và cài đặt được lưu trữ và đồng bộ real-time.

## 📦 Service mới: SyncService

**File**: `lib/services/sync_service.dart`

### Chức năng chính:

1. **Practice Sessions** - Lưu và đồng bộ phiên luyện tập
2. **User Statistics** - Tính toán và cập nhật thống kê
3. **User Profile** - Quản lý thông tin cá nhân
4. **Settings** - Đồng bộ cài đặt giữa local và Firebase
5. **Real-time Updates** - Lắng nghe thay đổi dữ liệu

## 🗂️ Cấu trúc Firestore

### Collection: `users/{userId}`

```
users/{userId}/
├── displayName: string
├── email: string
├── photoURL: string (nullable)
├── phone: string (nullable)
├── bio: string (nullable)
├── statistics: {
│   ├── totalSessions: number
│   ├── totalMinutes: number
│   ├── averageScore: number
│   └── lastUpdated: timestamp
│ }
├── settings: {
│   ├── notificationsEnabled: boolean
│   ├── darkModeEnabled: boolean
│   └── defaultDuration: number
│ }
└── updatedAt: timestamp
```

### Subcollection: `users/{userId}/practice_sessions`

```
practice_sessions/{sessionId}/
├── id: string
├── userId: string
├── type: string (interview | presentation)
├── mode: string
├── score: number
├── duration: number (seconds)
├── startTime: timestamp
├── endTime: timestamp
├── pdfUrl: string (nullable)
├── recordingUrl: string (nullable)
├── feedback: string
├── questions: array
├── createdAt: timestamp
└── updatedAt: timestamp
```

## 🔄 Luồng đồng bộ dữ liệu

### 1. Khi lưu Practice Session

```dart
// Trong PracticeController
await _syncService.savePracticeSession(session);

// Flow:
// 1. Lưu vào users/{userId}/practice_sessions
// 2. Tự động cập nhật statistics trong user document
// 3. StatisticsController nhận real-time update
```

### 2. Khi cập nhật Profile

```dart
// Trong ProfileController
await _syncService.saveUserProfile(
  userId: user.uid,
  displayName: name,
  photoURL: photoUrl,
  phone: phone,
  bio: bio,
);

// Flow:
// 1. Lưu vào users/{userId}
// 2. Notify SettingsController để reload
// 3. UI tự động cập nhật
```

### 3. Khi thay đổi Settings

```dart
// Trong SettingsController
await _syncService.saveUserSettings(
  userId: userId,
  settings: {
    'notificationsEnabled': true,
    'darkModeEnabled': false,
    'defaultDuration': 5,
  },
);

// Flow:
// 1. Lưu local (SharedPreferences)
// 2. Sync lên Firebase
// 3. Các device khác có thể lấy về
```

## 📊 Real-time Statistics

### Tự động cập nhật khi có session mới

```dart
// StatisticsController tự động lắng nghe
_syncService.watchUserPracticeSessions(userId, limit: 10)
  .listen((sessions) {
    // Tự động cập nhật UI
    _processSessionsData(sessions);
  });
```

### Tính toán statistics

- **Total Sessions**: Đếm từ practice_sessions
- **Total Minutes**: Tổng duration / 60
- **Average Score**: Tổng score / số sessions
- **Recent Sessions**: 10 sessions gần nhất

## 🔧 Cách sử dụng trong code

### 1. Trong Controller

```dart
import '../services/sync_service.dart';

class MyController extends GetxController {
  final _syncService = SyncService();
  
  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    // Load statistics
    final stats = await _syncService.getUserStatistics(userId);
    
    // Load sessions
    final sessions = await _syncService.getUserPracticeSessions(
      userId, 
      limit: 10,
    );
    
    // Save new session
    await _syncService.savePracticeSession(session);
  }
}
```

### 2. Real-time Listening

```dart
StreamSubscription? _subscription;

void startListening() {
  _subscription = _syncService
    .watchUserPracticeSessions(userId, limit: 10)
    .listen((sessions) {
      // Update UI
    });
}

@override
void onClose() {
  _subscription?.cancel();
  super.onClose();
}
```

## 🔐 Firestore Security Rules

Cần cập nhật rules để cho phép user đọc/ghi data của mình:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Practice sessions subcollection
      match /practice_sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 📱 Controllers đã được cập nhật

### 1. StatisticsController
- ✅ Load statistics từ Firebase
- ✅ Real-time updates khi có session mới
- ✅ Tính toán metrics từ practice_sessions

### 2. SettingsController
- ✅ Sync settings giữa local và Firebase
- ✅ Load user profile từ Firebase
- ✅ Cập nhật khi profile thay đổi

### 3. ProfileController
- ✅ Save profile lên Firebase
- ✅ Upload ảnh lên Firebase Storage
- ✅ Notify SettingsController khi cập nhật

### 4. PracticeController
- ✅ Lưu session vào local storage (offline)
- ✅ Sync lên Firebase cho statistics
- ✅ Tự động cập nhật statistics

## 🚀 Tính năng Real-time

### Tự động đồng bộ
- Khi user A hoàn thành session trên device 1
- StatisticsScreen trên device 2 tự động cập nhật
- Không cần refresh thủ công

### Offline Support
- Session được lưu local trước (LocalFirebaseService)
- Sau đó sync lên Firebase
- Nếu offline, sẽ sync khi có internet lại

## 🧪 Testing

### Test sync service:

```dart
final syncService = SyncService();
final userId = 'test-user-id';

// Test save session
await syncService.savePracticeSession(testSession);

// Test get statistics
final stats = await syncService.getUserStatistics(userId);
print('Total sessions: ${stats?['totalSessions']}');

// Test get sessions
final sessions = await syncService.getUserPracticeSessions(userId);
print('Found ${sessions.length} sessions');
```

## ⚙️ Configuration

### 1. Cài đặt dependencies (đã có)
- ✅ cloud_firestore
- ✅ firebase_auth
- ✅ firebase_storage
- ✅ shared_preferences

### 2. Initialize Firebase (đã có trong main.dart)
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
```

## 🐛 Troubleshooting

### Lỗi: "Permission denied"
- Kiểm tra Firestore rules
- Đảm bảo user đã đăng nhập
- Verify userId match với auth.uid

### Lỗi: "Statistics không cập nhật"
- Check xem session có được lưu vào Firestore không
- Verify collection path đúng: `users/{userId}/practice_sessions`
- Kiểm tra StatisticsController có đang listen không

### Lỗi: "Settings không sync"
- Kiểm tra SharedPreferences có hoạt động không
- Verify Firebase connection
- Check userId có null không

## 📈 Performance

### Optimization
- Statistics được cache trong user document
- Chỉ load 10 sessions gần nhất
- Real-time updates chỉ cho active screens
- Local cache với SharedPreferences

### Best Practices
- ✅ Cancel stream subscriptions trong onClose()
- ✅ Sử dụng Rx variables cho reactive UI
- ✅ Error handling với try-catch
- ✅ Loading states cho UX tốt hơn

## 🔜 Tính năng mở rộng

- [ ] Batch writes cho multiple updates
- [ ] Pagination cho history
- [ ] Offline queue cho sync khi reconnect
- [ ] Cloud functions cho complex calculations
- [ ] Push notifications khi có milestone
- [ ] Export data to CSV/PDF
