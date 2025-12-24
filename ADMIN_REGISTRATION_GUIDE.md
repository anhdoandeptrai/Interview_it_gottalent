# 🎯 ĐĂNG KÝ TÀI KHOẢN ADMIN

## ✅ HỆ THỐNG ĐĂNG KÝ ĐÃ SẴN SÀNG

Web Admin giờ có **hệ thống đăng ký riêng**, tách biệt hoàn toàn với mobile app!

---

## 🚀 CÁCH ĐĂNG KÝ ADMIN

### Bước 1: Lấy mã đăng ký Admin

**Mã mặc định:** `ADMIN2024`

⚠️ **Quan trọng:** Thay đổi mã này trong production!

**File:** `web_admin/src/pages/Register.jsx`  
**Dòng 19:** `const ADMIN_REGISTRATION_CODE = 'ADMIN2024';`

### Bước 2: Truy cập trang đăng ký

```
http://localhost:3000/register
```

### Bước 3: Điền thông tin

1. **Họ và tên:** Tên đầy đủ của bạn
2. **Email:** Email admin (VD: admin@company.com)
3. **Mật khẩu:** Ít nhất 6 ký tự
4. **Xác nhận mật khẩu:** Nhập lại mật khẩu
5. **Mã đăng ký Admin:** `ADMIN2024`

### Bước 4: Đăng nhập

Sau khi đăng ký thành công:
1. Tự động chuyển về trang login
2. Nhập email/password vừa đăng ký
3. Truy cập Dashboard

---

## 🔐 BẢO MẬT MÃ ĐĂNG KÝ

### Thay đổi mã bảo mật:

**File:** `web_admin/src/pages/Register.jsx`

```javascript
// Dòng 19 - Thay đổi mã này
const ADMIN_REGISTRATION_CODE = 'YOUR_SECRET_CODE_HERE';
```

**Ví dụ:**
```javascript
const ADMIN_REGISTRATION_CODE = 'MyCompany@2024#Secure!';
```

⚠️ **Lưu ý:**
- Dùng mã phức tạp, khó đoán
- KHÔNG share mã này công khai
- Thay đổi định kỳ
- Chỉ cung cấp cho người được tin cậy

---

## 📊 CẤU TRÚC DỮ LIỆU

### Collection `admins/`
Admin users được lưu riêng:
```javascript
{
  uid: "abc123...",
  name: "Nguyen Van A",
  email: "admin@example.com",
  role: "admin",
  isAdmin: true,
  createdAt: timestamp,
  createdBy: "self-registration"
}
```

### Collection `users/`
Duplicate record cho compatibility:
```javascript
{
  uid: "abc123...",
  name: "Nguyen Van A",
  email: "admin@example.com",
  role: "admin",
  isAdmin: true,
  userType: "admin",
  createdAt: timestamp
}
```

---

## 🎯 FLOW ĐĂNG KÝ

```
1. User điền form Register
   ↓
2. Validate mã Admin Code
   ↓
3. Tạo user trong Firebase Auth
   ↓
4. Tạo document trong collection "admins"
   ↓
5. Tạo document trong collection "users" (duplicate)
   ↓
6. Redirect về Login với success message
   ↓
7. User đăng nhập
   ↓
8. AuthContext check role admin
   ↓
9. Vào Dashboard
```

---

## 🔧 CUSTOMIZATION

### Thay đổi validation:

**File:** `web_admin/src/pages/Register.jsx`

```javascript
// Độ dài password tối thiểu
if (formData.password.length < 8) {  // Thay 6 thành 8
  setError('Mật khẩu phải có ít nhất 8 ký tự');
  return;
}

// Thêm regex cho password mạnh
const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
if (!strongPasswordRegex.test(formData.password)) {
  setError('Mật khẩu phải có chữ hoa, chữ thường, số và ký tự đặc biệt');
  return;
}
```

### Thêm trường custom:

```javascript
const [formData, setFormData] = useState({
  name: '',
  email: '',
  password: '',
  confirmPassword: '',
  adminCode: '',
  department: '',      // Thêm
  phoneNumber: ''      // Thêm
});
```

---

## ⚡ QUICK START

### 1. Chạy server (nếu chưa):
```powershell
cd web_admin
npm run dev
```

### 2. Mở trang đăng ký:
```
http://localhost:3000/register
```

### 3. Đăng ký với:
- Email: admin@test.com
- Password: admin123
- Mã admin: ADMIN2024

### 4. Đăng nhập:
```
http://localhost:3000/login
```

---

## 🔥 FIREBASE RULES CẬP NHẬT

Cần cập nhật rules cho collection `admins`:

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admins collection
    match /admins/{adminId} {
      // Allow create during registration (with valid auth)
      allow create: if request.auth != null;
      
      // Allow read/write for authenticated admins
      allow read, write: if request.auth != null && 
                            (get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin' ||
                             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // ... existing rules ...
  }
}
```

**Cập nhật:**
1. Vào Firebase Console
2. Firestore Database > Rules
3. Thêm rule cho collection `admins`
4. Publish

---

## ✅ CHECKLIST

- [x] Trang Register đã tạo
- [x] Route /register đã thêm vào App.jsx
- [x] Login page có link "Đăng ký Admin"
- [x] AuthContext check cả collection admins và users
- [x] Validation mã Admin Code
- [x] Success message sau khi đăng ký
- [ ] Thay đổi ADMIN_REGISTRATION_CODE
- [ ] Cập nhật Firebase Rules
- [ ] Test đăng ký và đăng nhập

---

## 🎉 HOÀN TẤT!

Giờ bạn có thể:
1. ✅ Đăng ký tài khoản admin độc lập
2. ✅ Không cần dùng mobile app
3. ✅ Quản lý admin riêng biệt
4. ✅ Bảo mật bằng mã đăng ký

**Bắt đầu:** http://localhost:3000/register

---

**Mã đăng ký mặc định:** `ADMIN2024`  
**Nhớ thay đổi trong production!** 🔒
