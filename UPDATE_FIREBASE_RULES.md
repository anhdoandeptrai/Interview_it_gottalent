# 🔥 CẬP NHẬT FIREBASE RULES

## ⚠️ QUAN TRỌNG - PHẢI LÀM!

Sau khi thêm hệ thống đăng ký admin, bạn **PHẢI** cập nhật Firebase Rules để hệ thống hoạt động đúng.

---

## 📋 FILES ĐÃ TẠO

1. **`firestore_admin_rules.rules`** - Firestore Database Rules
2. **`storage_admin_rules.rules`** - Firebase Storage Rules

---

## 🚀 CÁCH 1: CẬP NHẬT QUA FIREBASE CONSOLE (Khuyến nghị)

### A. Cập nhật Firestore Rules

1. **Mở Firebase Console:**
   ```
   https://console.firebase.google.com/project/interviewapp-36272
   ```

2. **Vào Firestore Database:**
   - Sidebar: **Firestore Database**
   - Tab: **Rules**

3. **Copy toàn bộ nội dung:**
   - Mở file: `firestore_admin_rules.rules`
   - Copy tất cả (Ctrl+A, Ctrl+C)

4. **Paste vào Firebase Console:**
   - Xóa rules cũ
   - Paste rules mới
   - Kiểm tra syntax (màu xanh = OK)

5. **Publish:**
   - Click nút **"Publish"**
   - Đợi vài giây để rules được deploy

✅ **Firestore Rules đã cập nhật!**

### B. Cập nhật Storage Rules

1. **Vào Storage:**
   - Sidebar: **Storage**
   - Tab: **Rules**

2. **Copy toàn bộ nội dung:**
   - Mở file: `storage_admin_rules.rules`
   - Copy tất cả

3. **Paste vào Firebase Console:**
   - Xóa rules cũ
   - Paste rules mới
   - Kiểm tra syntax

4. **Publish:**
   - Click nút **"Publish"**

✅ **Storage Rules đã cập nhật!**

---

## 🛠️ CÁCH 2: CẬP NHẬT QUA FIREBASE CLI

### Setup Firebase CLI (nếu chưa có):

```powershell
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập
firebase login

# Init project (trong thư mục gốc)
firebase init
```

### Deploy Rules:

```powershell
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules

# Hoặc deploy cả hai
firebase deploy --only firestore:rules,storage:rules
```

---

## 📝 RULES MỚI BẢO VỆ GÌ?

### Firestore Rules:

#### 1. **Admins Collection** (Mới)
- ✅ Cho phép tạo profile admin khi đăng ký
- ✅ Admin có thể đọc tất cả admin profiles
- ✅ Admin có thể update profile của mình
- ✅ Chỉ super admin mới delete được

#### 2. **Users Collection**
- ✅ Users đọc/ghi data của mình
- ✅ Admins đọc/ghi tất cả users
- ✅ Admins có thể xóa users

#### 3. **Practice Sessions**
- ✅ Users quản lý sessions của mình
- ✅ Admins xem tất cả sessions

#### 4. **Questions**
- ✅ Mọi người đọc được
- ✅ Chỉ admins mới tạo/sửa/xóa

#### 5. **Statistics, Leaderboard, Settings**
- ✅ Users đọc được
- ✅ Chỉ admins mới ghi được

### Storage Rules:

#### 1. **PDFs** (`/pdfs/{userId}/`)
- ✅ Users upload PDF của mình (max 10MB)
- ✅ Admins access tất cả PDFs
- ✅ Chỉ file PDF được phép

#### 2. **Audio** (`/audio/{userId}/{sessionId}/`)
- ✅ Users upload audio của mình (max 50MB)
- ✅ Admins access tất cả audio
- ✅ Chỉ file audio được phép

#### 3. **Videos** (`/videos/{userId}/{sessionId}/`)
- ✅ Users upload video của mình (max 100MB)
- ✅ Admins access tất cả videos

#### 4. **Avatars** (`/avatars/{userId}/`)
- ✅ Users upload avatar của mình (max 2MB)
- ✅ Mọi người xem được avatars
- ✅ Chỉ file image được phép

#### 5. **Admin Files** (`/admin/`)
- ✅ Chỉ admins mới access được

---

## ✅ KIỂM TRA RULES ĐÃ CẬP NHẬT

### Test Firestore:

1. **Vào Firebase Console > Firestore Database > Rules**
2. Click tab **"Rules Playground"**
3. Test với các scenarios:

**Test 1: Admin tạo profile**
```
Location: /admins/abc123
Action: create
Auth: Authenticated (your-email@example.com)
```
→ Should **ALLOW**

**Test 2: User thường đọc admin profile**
```
Location: /admins/abc123
Action: read
Auth: Authenticated (user@example.com) - without admin role
```
→ Should **DENY**

**Test 3: Admin đọc all users**
```
Location: /users
Action: list
Auth: Authenticated with admin role
```
→ Should **ALLOW**

### Test Storage:

1. **Thử upload PDF từ web admin**
2. **Kiểm tra Console log** - không có lỗi permission
3. **Thử đọc PDF đã upload**

---

## 🔴 NẾU GẶP LỖI

### Lỗi: "Permission denied"

**Nguyên nhân:** Rules chưa được publish hoặc sai format

**Giải pháp:**
1. Kiểm tra lại syntax trong Console
2. Re-publish rules
3. Đợi 1-2 phút để rules propagate
4. Refresh trang web admin
5. Clear cache và login lại

### Lỗi: "Missing or insufficient permissions"

**Nguyên nhân:** User chưa có role admin trong Firestore

**Giải pháp:**
1. Vào Firestore > admins hoặc users collection
2. Tìm document của user
3. Đảm bảo có field: `role: "admin"`
4. Logout và login lại

### Lỗi: "Function get() requires a path"

**Nguyên nhân:** Rules syntax error

**Giải pháp:**
1. Copy lại rules từ file gốc
2. Không sửa đổi paths
3. Paste chính xác vào Console

---

## 📊 SO SÁNH RULES CŨ VS MỚI

### Trước (Rules cũ):
```javascript
// Chỉ check collection "users"
allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
```

### Sau (Rules mới):
```javascript
// Check cả "admins" VÀ "users"
allow read: if get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin' ||
               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
```

**Lý do:** Hỗ trợ cả admin users (web admin) và mobile users

---

## 🎯 CHECKLIST CẬP NHẬT

- [ ] Đã copy nội dung `firestore_admin_rules.rules`
- [ ] Đã paste vào Firebase Console > Firestore > Rules
- [ ] Đã publish Firestore rules
- [ ] Đã copy nội dung `storage_admin_rules.rules`
- [ ] Đã paste vào Firebase Console > Storage > Rules
- [ ] Đã publish Storage rules
- [ ] Đã test đăng ký admin
- [ ] Đã test đăng nhập admin
- [ ] Đã test upload file
- [ ] Không có lỗi permission trong Console

---

## 🚨 PRODUCTION CHECKLIST

Trước khi deploy production:

- [ ] Đã thay đổi `ADMIN_REGISTRATION_CODE` trong Register.jsx
- [ ] Rules đã được test kỹ
- [ ] Đã backup rules cũ
- [ ] Đã review tất cả permissions
- [ ] Đã test với nhiều test cases
- [ ] Đã document mã admin code ở nơi an toàn

---

## 📞 CẦN TRỢ GIÚP?

### Tài liệu tham khảo:
- Firebase Rules: https://firebase.google.com/docs/firestore/security/get-started
- Rules Testing: https://firebase.google.com/docs/rules/unit-tests

### Debug:
1. Mở DevTools (F12)
2. Tab Console
3. Xem error logs
4. Tab Network > Xem response từ Firebase

---

## ✅ HOÀN TẤT!

Sau khi cập nhật rules:

1. **Test đăng ký:** http://localhost:3000/register
2. **Test đăng nhập:** http://localhost:3000/login
3. **Test dashboard:** http://localhost:3000/dashboard

**Rules phải được cập nhật để hệ thống hoạt động!** 🔥
