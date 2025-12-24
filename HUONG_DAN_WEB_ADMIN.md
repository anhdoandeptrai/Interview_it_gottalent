# HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG WEB ADMIN

## 📋 YÊU CẦU HỆ THỐNG

- Node.js 18 trở lên
- NPM hoặc Yarn
- Trình duyệt hiện đại (Chrome, Firefox, Edge, Safari)
- Firebase project (đã có sẵn cho mobile app)

## 🚀 CÀI ĐẶT NHANH

### Cách 1: Dùng file setup tự động (Windows)

1. **Chạy file setup:**
   ```
   Double-click file: setup_admin.bat
   ```

2. **Script sẽ tự động:**
   - Kiểm tra Node.js
   - Cài đặt dependencies
   - Tạo file .env từ template
   - Mở file .env để bạn chỉnh sửa

3. **Điền thông tin Firebase vào .env:**
   ```env
   VITE_FIREBASE_API_KEY=AIzaSy...
   VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=your-project
   VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=123456789
   VITE_FIREBASE_APP_ID=1:123456789:web:abc...
   ```

4. **Chạy admin panel:**
   ```
   Double-click file: run_admin.bat
   ```

### Cách 2: Cài đặt thủ công

1. **Mở PowerShell/CMD trong thư mục dự án**

2. **Di chuyển vào thư mục web_admin:**
   ```powershell
   cd web_admin
   ```

3. **Cài đặt dependencies:**
   ```powershell
   npm install
   ```

4. **Tạo file .env:**
   ```powershell
   copy .env.example .env
   ```

5. **Chỉnh sửa .env với thông tin Firebase của bạn**

6. **Chạy development server:**
   ```powershell
   npm run dev
   ```

7. **Mở trình duyệt:** `http://localhost:3000`

## 🔑 LẤY THÔNG TIN FIREBASE

### Bước 1: Vào Firebase Console
- Truy cập: https://console.firebase.google.com/
- Chọn project của bạn

### Bước 2: Lấy config
1. Click vào biểu tượng **⚙️ (Settings)**
2. Chọn **Project settings**
3. Kéo xuống **Your apps**
4. Nếu chưa có web app, click **Add app** > chọn **Web** (</>) 
5. Copy các giá trị từ `firebaseConfig` object

### Ví dụ Firebase config:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXX",           // → VITE_FIREBASE_API_KEY
  authDomain: "project.firebaseapp.com",       // → VITE_FIREBASE_AUTH_DOMAIN
  projectId: "project-id",                      // → VITE_FIREBASE_PROJECT_ID
  storageBucket: "project.appspot.com",        // → VITE_FIREBASE_STORAGE_BUCKET
  messagingSenderId: "123456789",              // → VITE_FIREBASE_MESSAGING_SENDER_ID
  appId: "1:123456789:web:abcdef123456"       // → VITE_FIREBASE_APP_ID
};
```

## 👤 TẠO TÀI KHOẢN ADMIN

Admin panel **CHỈ** cho phép user có quyền admin đăng nhập.

### Cách 1: Thông qua Firestore Console

1. **Đăng ký tài khoản trong mobile app** (hoặc dùng account có sẵn)

2. **Vào Firebase Console > Firestore Database**

3. **Tìm collection `users`**

4. **Chọn document của user bạn muốn làm admin**

5. **Thêm/sửa field:**
   - Cách 1: Thêm field `role` với value `"admin"`
   - Cách 2: Thêm field `isAdmin` với value `true`

6. **Save changes**

### Ví dụ User Document:
```
users/
  └─ userId123/
      ├─ email: "admin@example.com"
      ├─ name: "Admin User"
      ├─ role: "admin"              ← Thêm dòng này
      └─ createdAt: timestamp
```

HOẶC

```
users/
  └─ userId123/
      ├─ email: "admin@example.com"
      ├─ name: "Admin User"
      ├─ isAdmin: true              ← Thêm dòng này
      └─ createdAt: timestamp
```

## 🖥️ SỬ DỤNG WEB ADMIN

### Đăng nhập
1. Mở `http://localhost:3000`
2. Nhập email và password của tài khoản admin
3. Click "Đăng nhập"

### Các chức năng chính

#### 📊 Dashboard
- Xem tổng quan thống kê
- Biểu đồ hoạt động 7 ngày
- Biểu đồ phân bố chế độ
- Hoạt động gần đây

#### 👥 Quản lý Users
- **Danh sách:** Xem tất cả users
- **Tìm kiếm:** Tìm theo tên/email
- **Lọc:** Theo role (admin/user)
- **Chi tiết:** Click vào user để xem thông tin đầy đủ
- **Xóa:** Xóa user không cần thiết

#### 📝 Ngân hàng câu hỏi
- **Thêm mới:** Click "Thêm câu hỏi"
- **Chỉnh sửa:** Click icon bút chì
- **Xóa:** Click icon thùng rác
- **Lọc:** Theo mode (Interview/Presentation) và category
- **Tìm kiếm:** Tìm nội dung câu hỏi

**Categories có sẵn:**
- Technical (Kỹ thuật)
- Behavioral (Hành vi)
- Situational (Tình huống)
- Presentation (Thuyết trình)
- General (Tổng quát)

**Difficulty levels:**
- Easy (Dễ)
- Medium (Trung bình)
- Hard (Khó)

#### 📋 Lịch sử phỏng vấn
- **Xem tất cả:** Danh sách các phiên luyện tập
- **Lọc:** Theo mode và ngày
- **Chi tiết:** Click "Xem chi tiết" để xem:
  - Thông tin phiên
  - Các câu hỏi đã trả lời
  - Điểm số và phân tích
  - Feedback AI
  - File PDF đã tải lên

#### 🏆 Bảng xếp hạng
- **Top 3:** Hiển thị podium
- **Full ranking:** Bảng xếp hạng đầy đủ
- **Lọc theo thời gian:**
  - Tuần này
  - Tháng này
  - Năm này
  - Toàn thời gian
- **Lọc theo mode:** Interview/Presentation/Tất cả

#### ⚙️ Cài đặt
- Cấu hình hệ thống
- Chế độ bảo trì
- Quản lý đăng ký
- Thông báo
- Sao lưu dữ liệu

## 🔧 TROUBLESHOOTING

### Lỗi: "Module not found"
```powershell
# Xóa node_modules và cài lại
Remove-Item -Recurse -Force node_modules
npm install
```

### Lỗi: "Firebase config not found"
- Kiểm tra file `.env` đã tồn tại chưa
- Kiểm tra tất cả biến `VITE_FIREBASE_*` đã điền chưa
- Restart dev server: Ctrl+C rồi `npm run dev`

### Lỗi: "Not authorized" khi đăng nhập
- Kiểm tra user có field `role: "admin"` hoặc `isAdmin: true` chưa
- Xem Firebase Console > Authentication > Users để xác nhận

### Lỗi: Port 3000 đã được sử dụng
```powershell
# Thay đổi port trong vite.config.js
# Hoặc dừng process đang chạy port 3000
```

### Lỗi: CORS / Firebase permissions
- Kiểm tra Firebase Rules
- Đảm bảo Authentication đã enable
- Kiểm tra network tab trong DevTools

## 📦 BUILD PRODUCTION

### Build static files:
```powershell
cd web_admin
npm run build
```

Output: `web_admin/dist/`

### Preview production build:
```powershell
npm run preview
```

### Deploy lên hosting:

**Firebase Hosting:**
```powershell
firebase init hosting
# Chọn thư mục: dist
# Configure as single-page app: Yes
firebase deploy --only hosting
```

**Netlify:**
- Kéo thả folder `dist` vào https://app.netlify.com/drop

**Vercel:**
```powershell
npm install -g vercel
vercel --prod
```

## 📱 RESPONSIVE DESIGN

- **Desktop (>1024px):** Full sidebar navigation
- **Tablet (768-1024px):** Collapsed sidebar
- **Mobile (<768px):** Hamburger menu

## 🔒 BẢO MẬT

✅ **Đã áp dụng:**
- Firebase Authentication
- Role-based access control
- Protected routes
- Auto logout cho non-admin
- Environment variables cho sensitive data

⚠️ **Lưu ý:**
- KHÔNG commit file `.env` lên Git
- Giữ bí mật Firebase config
- Chỉ cấp quyền admin cho người tin cậy
- Thường xuyên review Firebase Security Rules

## 📚 TÀI LIỆU THAM KHẢO

- [React Documentation](https://react.dev/)
- [Vite Guide](https://vitejs.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [React Router](https://reactrouter.com/)

## 💡 TIPS

1. **Dev mode hot reload:** Thay đổi code tự động refresh
2. **Console logs:** Mở DevTools (F12) để xem logs
3. **Network tab:** Debug API calls và Firebase requests
4. **React DevTools:** Install extension để debug components
5. **Format code:** Dùng Prettier extension trong VS Code

## 🆘 HỖ TRỢ

Nếu gặp vấn đề:

1. ✅ Kiểm tra file `.env` đã đúng chưa
2. ✅ Kiểm tra user có quyền admin chưa
3. ✅ Xem Console log có lỗi gì
4. ✅ Xem Network tab để debug API
5. ✅ Restart dev server
6. ✅ Xóa cache browser (Ctrl+Shift+Del)
7. ✅ Reinstall dependencies

## 📞 CONTACT

Email: support@example.com

---

**Chúc bạn sử dụng vui vẻ! 🎉**
