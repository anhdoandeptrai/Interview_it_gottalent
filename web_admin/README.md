# Interview App Admin Panel

Web quản trị cho ứng dụng luyện tập phỏng vấn và thuyết trình.

## Tính năng

### 📊 Dashboard
- Thống kê tổng quan: Users, Sessions, Questions
- Biểu đồ hoạt động theo thời gian
- Top performers trong tháng

### 👥 Quản lý Users
- Danh sách người dùng
- Xem chi tiết profile
- Lịch sử luyện tập
- Thống kê cá nhân

### 📝 Ngân hàng câu hỏi
- Quản lý câu hỏi phỏng vấn
- Quản lý câu hỏi thuyết trình
- Tạo mới, chỉnh sửa, xóa câu hỏi
- Phân loại theo category và độ khó

### 📜 Lịch sử phỏng vấn
- Xem tất cả phiên luyện tập
- Filter theo user, mode, ngày
- Chi tiết phiên: câu hỏi, câu trả lời, điểm số
- Export dữ liệu

### 🏆 Bảng xếp hạng
- Top users theo điểm số
- Leaderboard theo tháng/quý/năm
- So sánh theo mode (Interview/Presentation)

### 📈 Thống kê & Báo cáo
- Biểu đồ xu hướng
- Phân tích hiệu suất
- Export reports

## Cài đặt

```bash
# Cài đặt dependencies
npm install

# Chạy development server
npm run dev

# Build production
npm run build

# Preview production build
npm run preview
```

## Cấu trúc dự án

```
web_admin/
├── src/
│   ├── components/         # React components
│   ├── pages/             # Pages/Views
│   ├── services/          # Firebase services
│   ├── hooks/             # Custom React hooks
│   ├── utils/             # Utilities
│   ├── config/            # Configuration
│   ├── App.jsx            # Main App component
│   └── main.jsx           # Entry point
├── public/                # Static assets
├── index.html
├── package.json
├── vite.config.js
└── tailwind.config.js
```

## Firebase Configuration

Tạo file `.env` trong thư mục root với nội dung:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_auth_domain
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_storage_bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

## Quyền Admin

Để cấp quyền admin cho user, chạy script sau trong Firebase Console:

```javascript
// Set custom claims
admin.auth().setCustomUserClaims(uid, { admin: true })
```

## Tech Stack

- **React 18** - UI Framework
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Firebase** - Backend & Database
- **React Router** - Navigation
- **Recharts** - Charts & Graphs
- **Lucide React** - Icons

## License

Private - Interview App Team
