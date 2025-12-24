import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔄 Đang khởi tạo Firebase...');

    // Test Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase đã kết nối thành công!');
    print('📱 Project ID: ${Firebase.app().options.projectId}');
    print('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 10)}...');
    print('📦 Storage Bucket: ${Firebase.app().options.storageBucket}');

    // Test Firebase Auth
    print('\n🔄 Đang test Firebase Auth...');
    FirebaseAuth auth = FirebaseAuth.instance;
    print(
      '✅ Firebase Auth khả dụng: ${auth.currentUser == null ? "Chưa đăng nhập" : "Đã đăng nhập"}',
    );

    // Test Firestore
    print('\n🔄 Đang test Firestore...');
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Thử đọc một collection test
    try {
      await firestore.collection('test').limit(1).get();
      print('✅ Firestore kết nối thành công!');
    } catch (e) {
      print('⚠️  Firestore cần cấu hình rules: $e');
    }

    print('\n🎉 Tất cả services Firebase đã sẵn sàng!');
    print('📝 Bạn có thể chạy ứng dụng chính bằng: flutter run');
  } catch (e) {
    print('❌ Lỗi kết nối Firebase: $e');
    print('💡 Kiểm tra lại file firebase_options.dart và google-services.json');
  }
}
