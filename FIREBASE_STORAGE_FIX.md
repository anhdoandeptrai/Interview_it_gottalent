# Hướng dẫn Sửa lỗi Firebase Storage Upload

## 🚨 Nguyên nhân lỗi
```
StorageException: Object does not exist at location. Code: -13010 HttpResult: 404
Firebase error: "Not Found"
```

## ✅ Giải pháp

### Bước 1: Cập nhật Firebase Storage Rules
1. Mở [Firebase Console](https://console.firebase.google.com)
2. Chọn project "interviewapp-36272"
3. Vào **Storage** > **Rules**
4. Thay thế rules hiện tại bằng:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow anyone to read and write to all paths
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Bước 2: Publish Rules
1. Click **Publish** để lưu rules mới
2. Đợi vài giây để rules có hiệu lực

### Bước 3: Test lại
Sau khi update rules, thử upload PDF lại trong app.

## 🔒 Rules Production (sau khi test xong)
Khi app hoạt động ổn, thay thế bằng rules bảo mật hơn:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User-specific PDF uploads
    match /pdfs/{userId}/{sessionId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User-specific audio uploads  
    match /audio/{userId}/{sessionId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Default deny
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## 📋 Checklist Debug
- ✅ PDF extraction thành công (1276 words)
- ✅ File validation passed (124,799 bytes)
- ✅ Firebase authentication hoạt động
- ❌ Firebase Storage upload bị block bởi rules
- 📝 Cần update Storage Rules

## 🔧 Lệnh Test Thêm
Sau khi sửa rules, check logs:
```bash
# Trong terminal Flutter
flutter logs
```

Sẽ thấy:
```
✅ Upload progress: 100%
✅ Upload completed successfully  
✅ Download URL obtained
```
