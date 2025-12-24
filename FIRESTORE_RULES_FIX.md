# Firebase Firestore Rules Fix

Cần cập nhật Firestore Rules trong Firebase Console:

## 🔥 Firestore Rules
1. Mở Firebase Console: https://console.firebase.google.com/project/interviewapp-36272/firestore/rules
2. Thay thế rules hiện tại bằng:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to read and write their own practice sessions
    match /practice_sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Temporary: Allow all authenticated users (REMOVE IN PRODUCTION)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **Publish**

## 📱 Storage Rules 
Cũng cần update Storage Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow all authenticated users (for testing)
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```