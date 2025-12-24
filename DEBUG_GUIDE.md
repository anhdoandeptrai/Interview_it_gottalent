# Debug Guide - PDF Upload Issue Resolution

## Overview
This guide helps debug the "failed to create session: exception failed to upload pdf file" error.

## Improvements Made

### 1. Enhanced PDF Service (`lib/services/pdf_service.dart`)
- ✅ Added comprehensive PDF validation
- ✅ Enhanced error handling with detailed messages
- ✅ File size and format validation
- ✅ Text content validation
- ✅ Better text extraction with word count

### 2. Improved Firebase Service (`lib/services/firebase_service.dart`)
- ✅ Added detailed upload progress monitoring
- ✅ Enhanced error handling for Firebase Storage
- ✅ File metadata setting
- ✅ Better exception handling

### 3. Enhanced Practice Provider (`lib/providers/practice_provider.dart`)
- ✅ Multi-step validation process
- ✅ Better error messages for users
- ✅ Integration with improved services
- ✅ Comprehensive logging

### 4. Error Handler Utility (`lib/utils/error_handler.dart`)
- ✅ User-friendly error messages
- ✅ Error categorization
- ✅ Consistent error handling across app

### 5. Firebase Storage Rules (`firebase_storage_rules.rules`)
- ✅ Proper security configuration
- ✅ User-specific access control

## Testing Steps

### Step 1: Basic File Validation
1. Open the app
2. Try to upload a PDF file
3. Check the console logs for detailed error messages
4. Look for these specific validation messages:
   - "PDF file validation passed"
   - "Text extraction successful"
   - "Firebase upload progress"

### Step 2: File Format Testing
Test with different file types:
- ✅ Valid PDF with text content
- ❌ Empty PDF file
- ❌ Corrupted PDF file
- ❌ Non-PDF file with .pdf extension
- ❌ File larger than 50MB

### Step 3: Firebase Connection Testing
1. Check internet connection
2. Verify Firebase project configuration
3. Check Firebase Storage rules in Firebase Console
4. Verify API keys in `.env` file

### Step 4: Error Message Verification
The app should now show specific error messages for:
- File doesn't exist
- File too large (>50MB)
- Empty file
- Invalid PDF format
- No text content found
- Firebase upload failure
- AI service failure

## Common Error Scenarios & Solutions

### Error: "PDF file does not exist"
**Solution:** File was moved or deleted after selection
- Re-select the file
- Check file permissions

### Error: "PDF file is too large"
**Solution:** File exceeds 50MB limit
- Use a smaller PDF file
- Compress the PDF

### Error: "Invalid PDF format or corrupted file"
**Solution:** File is not a valid PDF
- Use a different PDF file
- Try re-saving the original document as PDF

### Error: "No text found in PDF file"
**Solution:** PDF contains only images or is scanned without OCR
- Use a PDF with selectable text
- Convert scanned PDF using OCR software

### Error: "Firebase upload failed"
**Solution:** Network or Firebase configuration issue
- Check internet connection
- Verify Firebase Storage rules
- Check Firebase project settings

### Error: "Failed to generate questions"
**Solution:** AI service unavailable
- Check internet connection
- Verify Gemini API key in `.env`
- Try again after a few moments

## Debug Information to Collect

When testing, look for these log messages:

```
Practice Provider: Starting session creation...
Practice Provider: File validation passed - Size: X bytes
PDF Service: Starting text extraction from /path/to/file
PDF Service: PDF validation passed, file size: X bytes
PDF Service: PDF document loaded, page count: X
PDF Service: Text extraction successful - X words extracted
Firebase Service: Starting PDF upload...
Firebase Service: Upload progress: X%
Firebase Service: Upload completed successfully
```

## Firebase Storage Rules Setup

Make sure your Firebase Storage rules allow authenticated users to upload:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /pdfs/{userId}/{sessionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /audio/{userId}/{sessionId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Temporary testing rules - remove in production
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Next Steps

1. **Test the upload** with a small, valid PDF file
2. **Monitor console logs** for detailed error information
3. **Share specific error messages** if issues persist
4. **Check Firebase Console** for any storage errors
5. **Verify API configuration** in `.env` file

## Environment Setup Verification

Ensure your `.env` file contains:
```
GEMINI_API_KEY=your_actual_api_key_here
```

And Firebase is properly configured with:
- Firebase Storage enabled
- Proper security rules
- Valid google-services.json file

## Support Information

If issues persist after following this guide:
1. Collect console log output
2. Note the specific error message shown to user
3. Verify file details (size, format, content)
4. Check Firebase Console for error logs
5. Share detailed error information for further assistance
