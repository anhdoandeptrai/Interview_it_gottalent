# 🔥 HƯỚNG DẪN KẾT NỐI FIREBASE - WEB ADMIN

## ✅ ĐÃ HOÀN THÀNH

Firebase config đã được tự động kết nối dựa trên mobile app!

---

## 📋 THÔNG TIN FIREBASE

**Project ID:** `interviewapp-36272`  
**Console:** https://console.firebase.google.com/project/interviewapp-36272

### Services đang sử dụng:
- ✅ **Authentication** - Email/Password
- ✅ **Firestore Database** - users, sessions, questions collections
- ✅ **Storage** - PDF files storage

---

## 🎯 BƯỚC 1: KIỂM TRA FILE .ENV

File `.env` đã được tạo tự động với config từ mobile app:

**Location:** `web_admin/.env`

```env
VITE_FIREBASE_API_KEY=AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0
VITE_FIREBASE_AUTH_DOMAIN=interviewapp-36272.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=interviewapp-36272
VITE_FIREBASE_STORAGE_BUCKET=interviewapp-36272.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=945431547501
VITE_FIREBASE_APP_ID=1:945431547501:web:da8005f9c3e6f598bb7964
```

✅ **Config đã chính xác, không cần chỉnh sửa!**

---

## 🚀 BƯỚC 2: CÀI ĐẶT VÀ CHẠY

### Cách 1: Setup nhanh (Khuyến nghị)
```powershell
# Chạy file này từ thư mục gốc
.\quick_setup_admin.bat
```

### Cách 2: Manual
```powershell
cd web_admin
npm install
npm run dev
```

**Server sẽ chạy tại:** http://localhost:3000

---

## 👤 BƯỚC 3: TẠO TÀI KHOẢN ADMIN

### Option 1: Dùng tài khoản mobile app có sẵn

1. **Mở Firebase Console:**
   - URL: https://console.firebase.google.com/project/interviewapp-36272
   - Đăng nhập với Google account

2. **Vào Firestore Database:**
   - Sidebar: Cloud Firestore > Data
   - Tìm collection: `users`

3. **Chọn user của bạn:**
   - Click vào document ID của user (thường là một chuỗi dài)
   - Document này chứa thông tin: email, name, createdAt...

4. **Thêm quyền admin:**
   - Click "Add field" (Thêm trường)
   - Field name: `role`
   - Type: `string`
   - Value: `admin`
   - Click "Add" (Thêm)

   **HOẶC**

   - Click "Add field"
   - Field name: `isAdmin`
   - Type: `boolean`
   - Value: `true`
   - Click "Add"

5. **Lưu thay đổi**

### Option 2: Tạo admin mới qua mobile app

1. Mở mobile app
2. Đăng ký tài khoản mới với email/password
3. Sau đó làm theo Option 1 để thêm quyền admin

---

## 🔐 BƯỚC 4: ĐĂNG NHẬP VÀO WEB ADMIN

1. **Mở trình duyệt:** http://localhost:3000
2. **Nhập thông tin:**
   - Email: [email đã set làm admin]
   - Password: [password của bạn]
3. **Click "Đăng nhập"**

✅ Nếu user có quyền admin → Vào được dashboard  
❌ Nếu không có quyền → Hiển thị lỗi "Not authorized"

---

## 📊 BƯỚC 5: KIỂM TRA KẾT NỐI

### Test các tính năng:

1. **Dashboard:**
   - Xem thống kê users, sessions, questions
   - Kiểm tra biểu đồ có hiển thị không

2. **Users Page:**
   - Xem danh sách users từ Firestore
   - Tìm kiếm users

3. **Questions Page:**
   - Thử thêm câu hỏi mới
   - Kiểm tra lưu vào Firestore

4. **Sessions Page:**
   - Xem lịch sử phiên luyện tập
   - Click vào chi tiết phiên

5. **Leaderboard:**
   - Xem bảng xếp hạng users

---

## 🔧 TROUBLESHOOTING

### ❌ Lỗi: "Firebase config not found"

**Nguyên nhân:** File .env không tồn tại hoặc không đúng format

**Giải pháp:**
```powershell
cd web_admin
# Kiểm tra file .env có tồn tại
Get-Item .env

# Nếu không có, copy từ template
copy .env.real .env
```

### ❌ Lỗi: "Not authorized" khi đăng nhập

**Nguyên nhân:** User chưa có quyền admin

**Giải pháp:**
1. Vào Firebase Console
2. Firestore > users collection
3. Tìm user và thêm field `role: "admin"`
4. Logout và login lại

### ❌ Lỗi: "Failed to fetch" / Network error

**Nguyên nhân:** Firebase Rules chặn request

**Giải pháp - Cập nhật Firestore Rules:**

1. Vào Firebase Console > Firestore Database > Rules
2. Thay bằng rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Allow admin to access all collections
    match /{document=**} {
      allow read, write: if request.auth != null && 
                            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow authenticated users to read/write their sessions
    match /practice_sessions/{sessionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                               (resource.data.userId == request.auth.uid ||
                                get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Questions - admin only
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

3. Click "Publish"

**Giải pháp - Cập nhật Storage Rules:**

1. Vào Firebase Console > Storage > Rules
2. Thay bằng:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload/download their files
    match /pdfs/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /audio/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow admin to access all files
    match /{allPaths=**} {
      allow read, write: if request.auth != null && 
                            firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

3. Click "Publish"

### ❌ Lỗi: CORS error

**Nguyên nhân:** Firebase chưa cho phép domain

**Giải pháp:**
1. Vào Firebase Console > Authentication > Settings
2. Tab "Authorized domains"
3. Thêm: `localhost`
4. Save

### ❌ Lỗi: "Module not found"

**Giải pháp:**
```powershell
cd web_admin
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json
npm install
```

---

## 🎯 CẤU TRÚC FIRESTORE (Reference)

### Collections cần thiết:

```
firestore/
├── users/
│   └── {userId}
│       ├── email: string
│       ├── name: string
│       ├── role: string ("admin" hoặc "user")
│       ├── isAdmin: boolean (optional)
│       └── createdAt: timestamp
│
├── practice_sessions/
│   └── {sessionId}
│       ├── userId: string
│       ├── mode: string ("interview" hoặc "presentation")
│       ├── questions: array
│       ├── answers: array
│       ├── scores: object
│       ├── feedback: object
│       ├── pdfUrl: string
│       ├── createdAt: timestamp
│       └── duration: number
│
└── questions/
    └── {questionId}
        ├── question: string
        ├── mode: string
        ├── category: string
        ├── difficulty: string
        ├── suggestedAnswer: string
        └── createdAt: timestamp
```

---

## 🔍 KIỂM TRA NHANH

### Verify Firebase connection:

```powershell
# Mở DevTools trong browser (F12)
# Console tab sẽ show:
```

✅ **Thành công:**
```
Firebase initialized successfully
Auth state: [user object]
```

❌ **Thất bại:**
```
Firebase config error: ...
```

### Test queries:

Mở Console trong DevTools và chạy:

```javascript
// Test read users
firebase.firestore().collection('users').get()
  .then(snap => console.log('Users:', snap.size))
  .catch(err => console.error('Error:', err));
```

---

## 📚 TÀI LIỆU THAM KHẢO

### Firebase Docs:
- **Console:** https://console.firebase.google.com/
- **Firestore:** https://firebase.google.com/docs/firestore
- **Authentication:** https://firebase.google.com/docs/auth
- **Storage:** https://firebase.google.com/docs/storage

### Web Admin Docs:
- **Quick Start:** `START_HERE.md`
- **Full Guide:** `HUONG_DAN_WEB_ADMIN.md`
- **Tech Report:** `WEB_ADMIN_COMPLETION_REPORT.md`

---

## ✅ CHECKLIST KẾT NỐI

Hoàn thành các bước sau:

- [x] File `.env` đã tạo với Firebase config
- [ ] Đã chạy `npm install` trong `web_admin/`
- [ ] Dev server đang chạy (`npm run dev`)
- [ ] Đã tạo tài khoản admin trong Firestore
- [ ] Đã set field `role: "admin"` cho user
- [ ] Đã cập nhật Firestore Rules
- [ ] Đã cập nhật Storage Rules
- [ ] Có thể đăng nhập vào http://localhost:3000
- [ ] Dashboard hiển thị dữ liệu
- [ ] Tất cả pages hoạt động bình thường

---

## 🎉 HOÀN TẤT!

Nếu tất cả checklist đều ✅, Firebase đã kết nối thành công!

**Bắt đầu sử dụng:** http://localhost:3000

**Cần trợ giúp?** Xem file `HUONG_DAN_WEB_ADMIN.md`

---

**Last updated:** December 24, 2025  
**Firebase Project:** interviewapp-36272  
**Web Admin Version:** 1.0.0
