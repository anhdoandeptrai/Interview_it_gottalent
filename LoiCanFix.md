# Loi Can Fix

Ngay tao: 2026-03-27
Nguon du lieu: ket qua chay `flutter analyze`, `flutter test`, `web_admin npm run build`, `web_admin npm run lint`.

## 1) Loi can fix ngay (blocking)

1. Flutter test dang fail 2/2.
- File: `test/app_startup_test.dart`
- Van de: test startup fail do app trong test chua khoi tao Firebase.
- Log: `[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`

2. Splash screen bi overflow trong widget test.
- File: `lib/screens/splash_screen.dart` (vung layout quanh dong 458)
- Van de: `RenderFlex overflowed by 2.0 pixels on the bottom`.
- Tac dong: test startup fail, UI co nguy co vo layout tren kich thuoc man hinh nho.

3. Widget test mac dinh khong con phu hop app hien tai.
- File: `test/widget_test.dart`
- Van de: van kiem tra counter + icon `+`, nhung app khong con UI counter.
- Log: `Expected: exactly one matching candidate ... Found 0 widgets with text "0"`.

4. AI Behavior Detection dang bi tat de tranh crash.
- File: `lib/services/camera_service.dart`
- Dau hieu: nhieu doan comment `TAT FACE DETECTION`, `TAT AI BEHAVIOR DETECTOR`.
- File: `lib/screens/practice/getx_modern_practice_screen.dart`
- Dau hieu: import behavior badge bi tat va ghi chu `TAT AI BEHAVIOR DETECTION DE TRANH CRASH`.
- Tac dong: tinh nang AI behavior trong practice chua thuc su hoat dong end-to-end.

5. Xu ly cau tra loi sau ghi am chua implement.
- File: `lib/controllers/practice_controller.dart`
- Ham: `_processAnswer(List<EmotionData> emotionData)`
- Van de: chi co placeholder comment, chua xu ly danh gia AI, luu ket qua, cap nhat score.

## 2) Van de can fix som (high)

1. Cac canh bao lint/analyze rat nhieu (508 issues).
- Nhom loi pho bien:
  - `avoid_print` trong production code.
  - `deprecated_member_use` (`withOpacity`, mot so API cu).
  - mot so warning style/structure khac.
- Tac dong: giam do on dinh CI va kho bao tri.

2. Cau hinh lint cua web_admin chua hoan chinh.
- File: `web_admin/package.json` co script `lint`.
- Van de: chay `npm run lint` fail do thieu file config ESLint.

3. Theme dark mode toggle chua ap dung thuc te.
- File: `lib/controllers/settings_controller.dart`
- Van de: con `TODO: Update app theme`.

4. Mot home screen phu con TODO dieu huong.
- File: `lib/screens/home/simple_home_screen.dart`
- Van de: floating action button moi thong bao `coming soon`.

## 3) Tinh nang da xac nhan chay duoc

1. Luong PDF -> tao cau hoi -> tao session da co wiring day du trong ViewModel/Controller/Service.
- Files:
  - `lib/viewmodels/practice_viewmodel.dart`
  - `lib/controllers/practice_controller.dart`
  - `lib/services/ai_service.dart`
  - `lib/widgets/questions_preview_dialog.dart`

2. Web admin build production thanh cong.
- Lenh pass: `npm run build` trong `web_admin`.

## 4) De xuat thu tu fix

1. Fix test infrastructure: mock/init Firebase cho test + cap nhat `widget_test.dart` theo app hien tai.
2. Fix overflow splash screen de test pass on dinh.
3. Bat lai AI behavior detection theo tung buoc an toan (camera stream, detector, UI badge), xu ly triet de nguyen nhan crash.
4. Implement `_processAnswer()` de hoan tat luong danh gia cau tra loi.
5. Don canh bao lint quan trong va bo sung ESLint config cho `web_admin`.

## 5) Ket qua command da chay

- `flutter analyze`: fail quality gate voi 508 issues.
- `flutter test`: fail 2 tests.
- `web_admin npm run build`: pass.
- `web_admin npm run lint`: fail (missing eslint config).
