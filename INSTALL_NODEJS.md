# 📦 HƯỚNG DẪN CÀI ĐẶT NODE.JS

## ⚠️ YÊU CẦU

Web Admin cần **Node.js 18+** để chạy.

---

## 🚀 CÁCH 1: TẢI VÀ CÀI ĐẶT (Khuyến nghị)

### Bước 1: Tải Node.js
1. Truy cập: https://nodejs.org/
2. Tải phiên bản **LTS (Long Term Support)** - khuyến nghị
   - Hoặc phiên bản **Current** nếu muốn features mới nhất

### Bước 2: Cài đặt
1. Chạy file `.msi` vừa tải về
2. Click "Next" > "Next" > "Install"
3. **Quan trọng:** Tick vào "Automatically install necessary tools"
4. Đợi cài đặt hoàn tất
5. Restart PowerShell/Terminal

### Bước 3: Verify cài đặt
Mở PowerShell mới và chạy:
```powershell
node --version
npm --version
```

**Kết quả mong đợi:**
```
v20.x.x  (hoặc v18.x.x)
10.x.x
```

---

## 🎯 CÁCH 2: Dùng Winget (Windows 11)

```powershell
# Mở PowerShell as Administrator
winget install OpenJS.NodeJS.LTS

# Restart PowerShell sau khi cài xong
```

---

## 🎯 CÁCH 3: Dùng Chocolatey

```powershell
# Nếu đã có Chocolatey
choco install nodejs-lts

# Restart PowerShell
```

---

## ✅ SAU KHI CÀI ĐẶT NODE.JS

### 1. Restart PowerShell
Đóng và mở lại PowerShell/Terminal

### 2. Verify lại
```powershell
node --version
npm --version
```

### 3. Chạy setup web admin

**Option A - Quick Setup (Tự động):**
```powershell
# Từ thư mục gốc dự án
.\quick_setup_admin.bat
```

**Option B - Manual:**
```powershell
cd web_admin
npm install
npm run dev
```

### 4. Mở trình duyệt
```
http://localhost:3000
```

---

## 🔧 TROUBLESHOOTING

### ❌ Lỗi: "npm command not found" sau khi cài

**Giải pháp:**
1. Restart máy tính (hoặc ít nhất restart PowerShell)
2. Kiểm tra PATH environment variable:
   ```powershell
   $env:Path -split ';' | Select-String node
   ```
3. Nếu không có, thêm thủ công:
   - Search Windows: "Environment Variables"
   - Edit "Path" variable
   - Thêm: `C:\Program Files\nodejs\`

### ❌ Lỗi: "Permission denied"

**Giải pháp:**
```powershell
# Chạy PowerShell as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### ❌ Lỗi: Node version quá cũ

**Giải pháp:**
- Gỡ Node.js cũ: Settings > Apps > Uninstall
- Tải và cài phiên bản mới nhất từ nodejs.org

---

## 📋 CHECKLIST

Hoàn thành các bước sau:

- [ ] Đã tải Node.js LTS từ nodejs.org
- [ ] Đã cài đặt Node.js
- [ ] Đã restart PowerShell/Terminal
- [ ] `node --version` hiển thị v18+ hoặc v20+
- [ ] `npm --version` hiển thị version number
- [ ] Sẵn sàng chạy `npm install`

---

## 🎯 TIẾP THEO

Sau khi cài Node.js thành công:

1. **Đọc hướng dẫn Firebase:**
   ```
   FIREBASE_CONNECTION_GUIDE.md
   ```

2. **Chạy quick setup:**
   ```powershell
   .\quick_setup_admin.bat
   ```

3. **Hoặc setup thủ công:**
   ```powershell
   cd web_admin
   npm install
   npm run dev
   ```

---

## 📞 HỖ TRỢ

**Download Node.js:** https://nodejs.org/  
**Node.js Documentation:** https://nodejs.org/docs/  
**NPM Documentation:** https://docs.npmjs.com/

---

**Chúc bạn cài đặt thành công! 🎉**
