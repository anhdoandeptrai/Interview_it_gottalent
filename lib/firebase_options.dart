// File này cần được cấu hình với Firebase project thực tế
// Vui lòng làm theo hướng dẫn sau để thiết lập Firebase:

// 1. Tạo project Firebase tại https://console.firebase.google.com
// 2. Cài đặt Firebase CLI: npm install -g firebase-tools
// 3. Chạy lệnh: flutter pub global activate flutterfire_cli
// 4. Chạy lệnh: flutterfire configure
// 5. Chọn project Firebase và platform (iOS, Android)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example configuration - thay thế bằng cấu hình thực tế của bạn
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Cấu hình Firebase thực tế dựa trên google-services.json
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0',
    appId: '1:945431547501:web:da8005f9c3e6f598bb7964',
    messagingSenderId: '945431547501',
    projectId: 'interviewapp-36272',
    authDomain: 'interviewapp-36272.firebaseapp.com',
    storageBucket: 'interviewapp-36272.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0',
    appId: '1:945431547501:android:da8005f9c3e6f598bb7964',
    messagingSenderId: '945431547501',
    projectId: 'interviewapp-36272',
    storageBucket: 'interviewapp-36272.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0',
    appId: '1:945431547501:ios:da8005f9c3e6f598bb7964',
    messagingSenderId: '945431547501',
    projectId: 'interviewapp-36272',
    storageBucket: 'interviewapp-36272.firebasestorage.app',
    iosBundleId: 'com.example.interview_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0',
    appId: '1:945431547501:macos:da8005f9c3e6f598bb7964',
    messagingSenderId: '945431547501',
    projectId: 'interviewapp-36272',
    storageBucket: 'interviewapp-36272.firebasestorage.app',
    iosBundleId: 'com.example.interview_app',
  );
}
