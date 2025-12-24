# 🚀 SETUP WEB ADMIN - HƯỚNG DẪN ĐẦY ĐỦ TỪ A-Z

## 📋 MỤC LỤC

1. [Chuẩn bị](#1-chuẩn-bị)
2. [Cài đặt Node.js](#2-cài-đặt-nodejs)
3. [Kết nối Firebase](#3-kết-nối-firebase)
4. [Cài đặt Web Admin](#4-cài-đặt-web-admin)
5. [Tạo Admin User](#5-tạo-admin-user)
6. [Chạy và Test](#6-chạy-và-test)

---

## 1. CHUẨN BỊ

### ✅ Những gì bạn cần:

- [x] Windows 10/11
- [x] Kết nối internet
- [x] Firebase project (đã có: **interviewapp-36272**)
- [x] Trình duyệt (Chrome, Firefox, Edge)
- [ ] Node.js 18+ (sẽ cài ở bước 2)
- [ ] Tài khoản đã đăng ký trong mobile app

### ⏱️ Thời gian ước tính: 10-15 phút

---

## 2. CÀI ĐẶT NODE.JS

### 📥 Tải và cài đặt:

1. **Truy cập:** https://nodejs.org/
2. **Tải:** Phiên bản **LTS** (Recommended)
3. **Cài đặt:** Chạy file `.msi` và làm theo hướng dẫn
4. **Restart:** Đóng và mở lại PowerShell

### ✅ Kiểm tra:

```powershell
node --version
npm --version
```

**Kết quả mong đợi:**
```
v20.x.x
10.x.x
```

❌ **Nếu lỗi:** Xem chi tiết tại `INSTALL_NODEJS.md`

---

## 3. KẾT NỐI FIREBASE

### ✅ Firebase đã được cấu hình sẵn!

**Project:** interviewapp-36272  
**File config:** `web_admin/.env` (đã tạo sẵn)

### 🔐 Cập nhật Firebase Rules (Quan trọng!)

#### 3.1. Firestore Rules

1. Vào: https://console.firebase.google.com/project/interviewapp-36272
2. Sidebar: **Firestore Database** > **Rules**
3. Copy và paste rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Allow admin to access everything
    match /{document=**} {
      allow read, write: if request.auth != null && 
                            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Sessions
    match /practice_sessions/{sessionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                               (resource.data.userId == request.auth.uid ||
                                get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Questions
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

4. Click **Publish**

#### 3.2. Storage Rules

1. Sidebar: **Storage** > **Rules**
2. Copy và paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User files
    match /pdfs/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /audio/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin access all
    match /{allPaths=**} {
      allow read, write: if request.auth != null && 
                            firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

3. Click **Publish**

#### 3.3. Authentication Domain

1. Sidebar: **Authentication** > **Settings** > **Authorized domains**
2. Đảm bảo có: `localhost`
3. Nếu chưa có, click **Add domain** và thêm `localhost`

✅ **Firebase đã sẵn sàng!**

❓ **Chi tiết:** Xem `FIREBASE_CONNECTION_GUIDE.md`

---

## 4. CÀI ĐẶT WEB ADMIN

### 🚀 CÁCH NHANH NHẤT - Chạy 1 lệnh:

Từ thư mục gốc `Interview_it_gottalent`:

```powershell
.\quick_setup_admin.bat
```

Script sẽ tự động:
- ✅ Cài đặt dependencies
- ✅ Copy Firebase config
- ✅ Khởi động server

**Xong!** Mở http://localhost:3000

---

### 🛠️ CÁCH THỦ CÔNG:

```powershell
# Bước 1: Di chuyển vào thư mục
cd web_admin

# Bước 2: Cài đặt dependencies (mất 2-3 phút)
npm install

# Bước 3: Chạy development server
npm run dev
```

**Output mong đợi:**
```
  VITE v5.0.0  ready in 500 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

✅ **Server đang chạy!**

---

## 5. TẠO ADMIN USER

### 📝 Cách 1: Dùng tài khoản mobile app có sẵn (Khuyến nghị)

1. **Mở Firebase Console:**
   ```
   https://console.firebase.google.com/project/interviewapp-36272
   ```

2. **Vào Firestore Database:**
   - Sidebar: **Firestore Database**
   - Tab: **Data**

3. **Tìm collection `users`:**
   - Click vào collection `users`
   - Sẽ thấy danh sách user documents

4. **Chọn user của bạn:**
   - Click vào document ID (chuỗi dài như: `abc123xyz...`)
   - Xem field `email` để xác nhận đúng user

5. **Thêm quyền admin:**
   - Click **"Add field"** (nút + ở góc dưới)
   - **Field:** `role`
   - **Type:** string
   - **Value:** `admin`
   - Click **"Add"**

6. **Xác nhận:**
   - Document giờ có field: `role: "admin"`
   - Lưu tự động

### 📝 Cách 2: Tạo user mới

1. Mở mobile app Interview Practice
2. Đăng ký tài khoản mới với email/password
3. Làm theo Cách 1 để set role admin

✅ **Admin user đã sẵn sàng!**

---

## 6. CHẠY VÀ TEST

### 🌐 Mở Web Admin

**URL:** http://localhost:3000

### 🔐 Đăng nhập

1. **Email:** [email bạn đã set admin]
2. **Password:** [password của bạn]
3. Click **"Đăng nhập"**

✅ **Thành công:** Vào được Dashboard  
❌ **Thất bại:** Xem phần Troubleshooting bên dưới

---

### ✅ Test các tính năng:

#### 1. Dashboard (/)
- [x] Xem 4 thẻ thống kê (Users, Sessions, Questions, Avg Score)
- [x] Xem biểu đồ hoạt động 7 ngày
- [x] Xem biểu đồ phân bố mode
- [x] Xem feed hoạt động gần đây

#### 2. Users (/users)
- [x] Xem danh sách users
- [x] Tìm kiếm user theo tên/email
- [x] Click vào user để xem chi tiết
- [x] Xem thống kê cá nhân

#### 3. Questions (/questions)
- [x] Xem danh sách câu hỏi
- [x] Thêm câu hỏi mới (click "Thêm câu hỏi")
- [x] Sửa câu hỏi (click icon bút chì)
- [x] Xóa câu hỏi (click icon thùng rác)
- [x] Tìm kiếm và lọc

#### 4. Sessions (/sessions)
- [x] Xem lịch sử phiên luyện tập
- [x] Lọc theo mode và ngày
- [x] Click "Xem chi tiết" một phiên
- [x] Xem câu hỏi, câu trả lời, điểm số

#### 5. Leaderboard (/leaderboard)
- [x] Xem top 3 podium
- [x] Xem bảng xếp hạng đầy đủ
- [x] Lọc theo thời gian (tuần/tháng/năm)
- [x] Lọc theo mode

#### 6. Settings (/settings)
- [x] Xem/sửa cài đặt hệ thống
- [x] Toggle các tính năng
- [x] Lưu thay đổi

---

## 🔧 TROUBLESHOOTING

### ❌ "npm command not found"

**Nguyên nhân:** Node.js chưa cài hoặc chưa restart terminal

**Giải pháp:**
1. Cài Node.js từ https://nodejs.org/
2. Restart PowerShell
3. Chạy `node --version` để verify

📖 **Chi tiết:** `INSTALL_NODEJS.md`

---

### ❌ "Not authorized" khi đăng nhập

**Nguyên nhân:** User chưa có quyền admin

**Giải pháp:**
1. Vào Firebase Console > Firestore
2. Tìm user trong collection `users`
3. Thêm field: `role: "admin"`
4. Logout và login lại web admin

---

### ❌ "Failed to fetch" / Network errors

**Nguyên nhân:** Firebase Rules chặn request

**Giải pháp:**
1. Cập nhật Firestore Rules (xem Bước 3.1)
2. Cập nhật Storage Rules (xem Bước 3.2)
3. Kiểm tra authorized domains (xem Bước 3.3)

---

### ❌ "Module not found" errors

**Giải pháp:**
```powershell
cd web_admin
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json -ErrorAction SilentlyContinue
npm install
```

---

### ❌ Port 3000 đã được sử dụng

**Giải pháp:**
```powershell
# Vite sẽ tự động chọn port khác (3001, 3002...)
# Xem console output để biết port đang dùng
```

---

### ❌ Firebase config errors

**Giải pháp:**
```powershell
# Kiểm tra file .env
cd web_admin
Get-Content .env

# Nếu không có, copy từ template
copy .env.real .env
```

---

### ❌ Dashboard không hiển thị dữ liệu

**Nguyên nhân:** Chưa có dữ liệu trong Firestore

**Giải pháp:**
1. Mở mobile app và tạo vài phiên luyện tập
2. Thêm vài câu hỏi trong web admin
3. Refresh dashboard

---

## 📚 TÀI LIỆU THAM KHẢO

### Quick Guides:
- 📄 `START_HERE.md` - Bắt đầu nhanh
- 🔥 `FIREBASE_CONNECTION_GUIDE.md` - Kết nối Firebase chi tiết
- 📦 `INSTALL_NODEJS.md` - Cài đặt Node.js

### Full Documentation:
- 📖 `web_admin/README.md` - Tổng quan dự án
- 📊 `HUONG_DAN_WEB_ADMIN.md` - Hướng dẫn sử dụng đầy đủ
- 🔍 `WEB_ADMIN_COMPLETION_REPORT.md` - Báo cáo kỹ thuật

### Scripts:
- ⚡ `quick_setup_admin.bat` - Setup + Run tự động
- 🔧 `setup_admin.bat` - Setup từng bước
- ▶️ `run_admin.bat` - Chỉ chạy server

---

## ✅ CHECKLIST HOÀN THÀNH

Đánh dấu khi hoàn thành:

### Chuẩn bị:
- [ ] Node.js đã cài (v18+)
- [ ] Firebase project đã có (interviewapp-36272)
- [ ] Đã có tài khoản trong mobile app

### Cài đặt:
- [ ] File `.env` đã tồn tại trong `web_admin/`
- [ ] Firebase Rules đã cập nhật (Firestore + Storage)
- [ ] `npm install` chạy thành công
- [ ] Dev server đang chạy (localhost:3000)

### Admin Setup:
- [ ] Đã set field `role: "admin"` trong Firestore
- [ ] Đăng nhập thành công vào web admin
- [ ] Dashboard hiển thị dữ liệu

### Testing:
- [ ] Test Dashboard - OK
- [ ] Test Users page - OK
- [ ] Test Questions page - OK
- [ ] Test Sessions page - OK
- [ ] Test Leaderboard - OK
- [ ] Test Settings - OK

---

## 🎉 HOÀN TẤT!

Nếu tất cả checklist đều ✅, bạn đã setup thành công!

**Bắt đầu sử dụng:** http://localhost:3000

---

## 📞 CẦN TRỢ GIÚP?

### Kiểm tra:
1. ✅ Node.js đã cài chưa: `node --version`
2. ✅ File .env có trong web_admin/ chưa
3. ✅ User có role admin chưa (Firestore)
4. ✅ Firebase Rules đã cập nhật chưa
5. ✅ Console log có lỗi gì (F12)

### Đọc thêm:
- `FIREBASE_CONNECTION_GUIDE.md` - Vấn đề Firebase
- `INSTALL_NODEJS.md` - Vấn đề Node.js
- `HUONG_DAN_WEB_ADMIN.md` - Hướng dẫn sử dụng

---

**Tech Stack:**
- ⚛️ React 18 + Vite
- 🔥 Firebase (Auth, Firestore, Storage)
- 🎨 Tailwind CSS
- 📊 Recharts

**Chúc bạn thành công! 🚀**
