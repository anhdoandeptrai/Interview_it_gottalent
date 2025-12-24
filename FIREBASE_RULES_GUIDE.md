# Firebase Rules Deployment Guide

## 📋 Overview
This guide helps you deploy complete Firebase Security Rules for both Firestore and Storage.

## 🔥 Firestore Rules

### Step 1: Open Firestore Rules Console
1. Go to [Firebase Console](https://console.firebase.google.com/project/interviewapp-36272/firestore/rules)
2. Navigate to **Firestore Database** > **Rules**

### Step 2: Replace Current Rules
Copy the content from `firestore_rules_complete.rules` and paste it into the Firebase Console.

**Key Features:**
- ✅ User data isolation (users can only access their own data)
- ✅ Practice session ownership validation
- ✅ Data structure validation
- ✅ Size limits and security checks
- ✅ Development mode (temporary open access)

### Step 3: Production Deployment
When ready for production:
1. **Remove or comment out** the temporary rule:
   ```javascript
   // REMOVE THIS SECTION IN PRODUCTION
   match /{document=**} {
     allow read, write: if request.auth != null;
   }
   ```

2. **Test thoroughly** with the restricted rules

## 📁 Storage Rules

### Step 1: Open Storage Rules Console
1. Go to [Firebase Console](https://console.firebase.google.com/project/interviewapp-36272/storage/rules)
2. Navigate to **Storage** > **Rules**

### Step 2: Replace Current Rules
Copy the content from `storage_rules_complete.rules` and paste it into the Firebase Console.

**Key Features:**
- ✅ File type validation (PDF, audio, images)
- ✅ File size limits (PDF: 50MB, Audio: 100MB, Images: 10MB)
- ✅ User-specific folder access
- ✅ Content type verification
- ✅ Development mode (temporary open access)

### Step 3: Production Deployment
When ready for production:
1. **Remove or comment out** the temporary rule:
   ```javascript
   // REMOVE THIS SECTION IN PRODUCTION
   match /{allPaths=**} {
     allow read, write: if request.auth != null;
   }
   ```

## 🚀 Deployment Steps

### For Development (Current):
1. Use the rules as-is with temporary open access
2. Test all app functionality
3. Monitor Firebase Console for rule violations

### For Production:
1. Remove temporary open access rules
2. Test with restricted access
3. Implement admin authentication if needed
4. Add custom claims for role-based access
5. Monitor and adjust rules based on usage

## 🔒 Security Best Practices

### Firestore:
- ✅ Users can only access their own documents
- ✅ Data validation on creation/updates
- ✅ Timestamp validation
- ✅ Field requirements enforcement

### Storage:
- ✅ File type restrictions
- ✅ File size limits
- ✅ User-specific folders
- ✅ Content type verification

## 🛠️ Testing Rules

### Test Commands:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Test Firestore rules locally
firebase emulators:start --only firestore

# Test Storage rules locally
firebase emulators:start --only storage
```

### Test Cases:
1. **User Registration**: Test user document creation
2. **Practice Session**: Test session creation/read/update/delete
3. **PDF Upload**: Test file upload with various sizes/types
4. **Audio Upload**: Test audio file upload
5. **Cross-user Access**: Verify users cannot access other users' data

## 📊 Monitoring

After deployment, monitor:
1. **Firebase Console > Usage**: Check for rule violations
2. **Firebase Console > Rules**: Review rule execution logs
3. **App Performance**: Ensure rules don't impact performance
4. **User Reports**: Monitor for access issues

## 🔄 Updates

When updating rules:
1. Test in Firebase Emulator first
2. Deploy to staging environment
3. Monitor for 24 hours
4. Deploy to production
5. Keep rollback plan ready

## 🆘 Troubleshooting

### Common Issues:
1. **Permission Denied**: Check user authentication
2. **File Upload Failed**: Verify file type and size limits
3. **Data Access Failed**: Check user ownership
4. **Rules Syntax Error**: Validate rules in Firebase Console

### Debug Tools:
- Firebase Console Rules Simulator
- Firebase Emulator Suite
- Browser Console (for detailed error messages)
- Firebase CLI debug logs

## 📞 Support

If you encounter issues:
1. Check Firebase Console error logs
2. Test with Firebase Emulator
3. Review Firebase documentation
4. Check Stack Overflow for similar issues