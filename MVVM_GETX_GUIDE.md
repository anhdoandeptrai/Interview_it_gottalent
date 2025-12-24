# 🏗️ KIẾN TRÚC MVVM + GETX

## 📋 Tổng quan

Ứng dụng Interview Practice đã được chuyển đổi từ Provider pattern sang **MVVM (Model-View-ViewModel)** với **GetX** để quản lý state, dependency injection và routing.

## 🏛️ Cấu trúc Kiến trúc

### 📁 Cấu trúc Thư mục

```
lib/
├── controllers/          # Business Logic Controllers
│   ├── app_controller.dart
│   ├── auth_controller.dart
│   └── practice_controller.dart
├── viewmodels/          # View-specific Logic
│   ├── base_viewmodel.dart
│   ├── auth_viewmodel.dart
│   └── practice_viewmodel.dart
├── models/              # Data Models
│   ├── user_model.dart
│   └── practice_session.dart
├── services/            # Data & API Services
│   ├── auth_service.dart
│   ├── ai_service.dart
│   └── local_firebase_service.dart
├── screens/             # UI Views
│   ├── auth/
│   ├── home/
│   └── practice/
├── widgets/             # Reusable UI Components
├── routes/              # Navigation & Routing
│   ├── app_routes.dart
│   └── app_pages.dart
├── bindings/            # Dependency Injection
│   └── app_bindings.dart
└── theme/               # UI Theme & Styling
```

## 🔄 Luồng Dữ liệu MVVM

```
View (UI) ↔ ViewModel ↔ Controller ↔ Service ↔ Model
```

### 🎯 Vai trò từng lớp:

#### 🖥️ **View (Screens/Widgets)**
- Chỉ chứa UI logic
- Không chứa business logic
- Observe ViewModel để update UI
- Gửi user actions đến ViewModel

#### 🎭 **ViewModel** 
- Xử lý presentation logic
- Form validation và UI state
- Transform data cho View
- Gọi Controller methods

#### 🎮 **Controller**
- Quản lý business logic chính
- State management với Reactive variables
- Gọi Services để xử lý data
- Xử lý navigation

#### 🛠️ **Service**
- Data access layer
- API calls, Database operations
- Pure business logic
- Không biết về UI

#### 📊 **Model**
- Data structures
- Serialization/Deserialization
- Business entities

## 🚀 Cách sử dụng GetX

### 1️⃣ **State Management**

```dart
// Controller
class AuthController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  void setLoading(bool value) {
    _isLoading.value = value;
  }
}

// View
Obx(() => controller.isLoading 
  ? CircularProgressIndicator()
  : ElevatedButton(...)
)
```

### 2️⃣ **Dependency Injection**

```dart
// Binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeController>(() => PracticeController());
  }
}

// Sử dụng trong Controller
final practiceController = Get.find<PracticeController>();
```

### 3️⃣ **Navigation**

```dart
// Chuyển trang
Get.toNamed(AppRoutes.PRACTICE_SETUP, arguments: mode);

// Thay thế trang
Get.offNamed(AppRoutes.HOME);

// Xóa tất cả và chuyển trang
Get.offAllNamed(AppRoutes.LOGIN);
```

### 4️⃣ **Reactive Programming**

```dart
// ViewModel binding với Controller
ever(controller.isSessionInProgressRx, (bool isInProgress) {
  _isSessionActive.value = isInProgress;
});
```

## 🔧 Setup và Sử dụng

### 1️⃣ **Dependencies cần thiết**

```yaml
dependencies:
  get: ^4.6.6  # State management + DI + Navigation
  # Loại bỏ provider: ^6.1.2
```

### 2️⃣ **Khởi tạo trong main.dart**

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Thay MaterialApp
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}
```

### 3️⃣ **Tạo Controller mới**

```dart
class NewController extends GetxController {
  // Observable variables
  final RxString _data = ''.obs;
  
  // Getters
  String get data => _data.value;
  
  // Methods
  void updateData(String value) {
    _data.value = value;
  }
  
  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // Initialize logic
  }
  
  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }
}
```

### 4️⃣ **Tạo ViewModel mới**

```dart
class NewViewModel extends BaseViewModel {
  final NewController _controller = Get.find<NewController>();
  
  // Local UI state
  final RxBool _isFormValid = false.obs;
  
  // Getters
  bool get isFormValid => _isFormValid.value;
  
  // Methods
  Future<void> submitForm() async {
    await runBusyFuture(
      _controller.submitData(),
      errorMessage: 'Submission failed',
    );
  }
}
```

### 5️⃣ **Sử dụng trong View**

```dart
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewViewModel>(
      init: NewViewModel(),
      builder: (viewModel) {
        return Scaffold(
          body: Column(
            children: [
              // Loading state
              Obx(() => viewModel.isBusy 
                ? CircularProgressIndicator()
                : Container()
              ),
              
              // Error handling
              Obx(() => viewModel.hasError
                ? Text(viewModel.errorMessage)
                : Container()
              ),
              
              // Form
              ElevatedButton(
                onPressed: viewModel.submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## 🎯 Ưu điểm của MVVM + GetX

### ✅ **Ưu điểm**

1. **Tách biệt rõ ràng**: UI, Business Logic, Data được tách biệt hoàn toàn
2. **Reactive**: Auto-update UI khi data thay đổi
3. **Testable**: Dễ dàng test từng layer riêng biệt
4. **Performance**: GetX có performance tốt hơn Provider
5. **Less Boilerplate**: Ít code boilerplate hơn Provider
6. **Memory Management**: Tự động dispose resources
7. **Built-in Navigation**: Không cần Navigator context

### ⚠️ **Lưu ý**

1. **Learning Curve**: Cần học cách sử dụng GetX
2. **Dependency**: Phụ thuộc vào GetX package
3. **Debugging**: Có thể khó debug reactive flows

## 🔄 Migration Guide

### Từ Provider sang GetX:

1. **Thay thế ChangeNotifier → GetxController**
2. **Thay thế Consumer → Obx/GetBuilder**
3. **Thay thế Provider.of → Get.find**
4. **Thay thế Navigator → Get.to/Get.off**
5. **Thêm .obs cho reactive variables**
6. **Tạo Bindings cho dependency injection**

## 📚 Tài liệu tham khảo

- [GetX Documentation](https://github.com/jonataslaw/getx)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
- [Flutter Architecture Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

---

**© 2025 Interview Practice App - MVVM + GetX Architecture**