# Bottom Navigation Bar - Hướng dẫn sử dụng

## Tổng quan

Ứng dụng đã được cập nhật với **Bottom Navigation Bar** để điều hướng dễ dàng giữa các màn hình chính:

### 📱 Các trang chính

1. **🏠 Trang chủ** - Màn hình chính với các chức năng chính
2. **💪 Luyện tập** - Thiết lập và bắt đầu phiên luyện tập
3. **📊 Thống kê** - Xem thống kê và tiến độ học tập
4. **⚙️ Cài đặt** - Quản lý hồ sơ và các cài đặt ứng dụng

## 🔧 Các thành phần đã tạo

### Controllers

1. **MainNavigationController** (`lib/controllers/main_navigation_controller.dart`)
   - Quản lý trạng thái của navigation bar
   - Xử lý việc chuyển trang

2. **StatisticsController** (`lib/controllers/statistics_controller.dart`)
   - Load thống kê từ Firebase
   - Tính toán tổng số phiên, thời gian, điểm trung bình

3. **SettingsController** (`lib/controllers/settings_controller.dart`)
   - Quản lý các cài đặt ứng dụng
   - Lưu preferences với SharedPreferences
   - Xử lý logout

4. **ProfileController** (`lib/controllers/profile_controller.dart`)
   - Quản lý thông tin hồ sơ người dùng
   - Upload ảnh đại diện lên Firebase Storage
   - Cập nhật thông tin trong Firestore

### Screens

1. **MainNavigationScreen** (`lib/screens/main_navigation_screen.dart`)
   - Màn hình chính với bottom navigation bar
   - Quản lý 4 trang con

2. **StatisticsScreen** (`lib/screens/statistics/statistics_screen.dart`)
   - Hiển thị thống kê tổng quan
   - Biểu đồ tiến độ
   - Lịch sử gần đây

3. **SettingsScreen** (`lib/screens/settings/settings_screen.dart`)
   - Thông tin hồ sơ người dùng
   - Cài đặt thông báo, giao diện
   - Cài đặt luyện tập
   - Đăng xuất

4. **ProfileScreen** (`lib/screens/profile/profile_screen.dart`)
   - Chỉnh sửa thông tin cá nhân
   - Thay đổi ảnh đại diện
   - Cập nhật số điện thoại, giới thiệu

## 🚀 Cách sử dụng

### Navigation Flow

```
SplashScreen
    ↓
LoginScreen (nếu chưa đăng nhập)
    ↓
MainNavigationScreen
    ├─ Trang chủ
    ├─ Luyện tập
    ├─ Thống kê
    └─ Cài đặt
         └─ Hồ sơ (ProfileScreen)
```

### Thêm tính năng mới

#### 1. Thêm tab mới vào navigation bar

Cập nhật `MainNavigationScreen`:

```dart
final List<Widget> pages = [
  const ModernHomeScreen(),
  const ModernSetupScreen(mode: PracticeMode.interview),
  const StatisticsScreen(),
  const SettingsScreen(),
  const YourNewScreen(), // Thêm màn hình mới
];

items: const [
  // ... existing items
  BottomNavigationBarItem(
    icon: Icon(Icons.your_icon),
    label: 'Your Label',
  ),
]
```

#### 2. Thêm route mới

Cập nhật `app_routes.dart`:

```dart
static const String YOUR_ROUTE = '/your-route';
```

Cập nhật `app_pages.dart`:

```dart
GetPage(
  name: AppRoutes.YOUR_ROUTE,
  page: () => const YourScreen(),
),
```

## 📦 Dependencies đã thêm

- `shared_preferences: ^2.2.2` - Lưu trữ cài đặt cục bộ
- `image_picker: ^1.0.5` - Chọn ảnh từ thư viện

## 🔥 Tích hợp Firebase

### Firestore Collections

1. **users/{userId}**
   - `displayName`: Tên hiển thị
   - `email`: Email
   - `phone`: Số điện thoại
   - `bio`: Giới thiệu
   - `photoURL`: URL ảnh đại diện
   - `updatedAt`: Thời gian cập nhật

2. **users/{userId}/practice_sessions**
   - `type`: Loại luyện tập
   - `score`: Điểm số
   - `duration`: Thời gian (giây)
   - `createdAt`: Thời gian tạo

### Firebase Storage

- **profile_images/{userId}.jpg** - Ảnh đại diện người dùng

## ⚙️ Cài đặt có sẵn

1. **Thông báo** - Bật/tắt thông báo ứng dụng
2. **Chế độ tối** - Chuyển đổi giao diện sáng/tối
3. **Ngôn ngữ** - Chọn ngôn ngữ hiển thị
4. **Thời gian mặc định** - Thiết lập thời gian luyện tập mặc định (3, 5, 10, 15, 20, 30 phút)

## 🎨 UI/UX Features

- Material Design 3
- Smooth animations
- Loading states
- Error handling với Snackbar
- Responsive layout
- Dark theme support (sẵn sàng)

## 📝 Ghi chú

- Sau khi đăng nhập thành công, người dùng sẽ được chuyển đến `MainNavigationScreen`
- Khi đăng xuất, người dùng sẽ được chuyển về `LoginScreen`
- Tất cả các navigation sử dụng GetX để quản lý state và routing
- Bottom navigation bar luôn hiển thị trên các màn hình chính

## 🐛 Troubleshooting

### Lỗi navigation
- Kiểm tra xem route đã được đăng ký trong `app_pages.dart`
- Đảm bảo controller được initialize bằng `Get.put()` hoặc binding

### Lỗi Firebase
- Kiểm tra Firebase config trong `firebase_options.dart`
- Đảm bảo Firestore rules cho phép đọc/ghi data
- Kiểm tra Storage rules cho phép upload ảnh

### SharedPreferences không lưu
- Đảm bảo `await` khi gọi `prefs.setBool()`, `prefs.setInt()`, etc.
- Kiểm tra permission trên device

## 🔜 Tính năng có thể mở rộng

- [ ] Thêm biểu đồ chi tiết trong Statistics
- [ ] Dark mode toggle với theme switching
- [ ] Multi-language support
- [ ] Push notifications
- [ ] Offline mode với local storage
- [ ] Social sharing
- [ ] Achievement system
