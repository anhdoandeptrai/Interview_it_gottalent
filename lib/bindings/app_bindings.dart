import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/practice_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put permanent controllers with error handling
    try {
      Get.put<AppController>(AppController(), permanent: true);
      print('AppController initialized successfully');
    } catch (e) {
      print('Error initializing AppController: $e');
    }

    try {
      Get.put<AuthController>(AuthController(), permanent: true);
      print('AuthController initialized successfully');
    } catch (e) {
      print('Error initializing AuthController: $e');
    }
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure PracticeController is available for home screen
    if (!Get.isRegistered<PracticeController>()) {
      Get.put<PracticeController>(PracticeController());
    }
  }
}

class PracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PracticeController>(PracticeController());
  }
}
