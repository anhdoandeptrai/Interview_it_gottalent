@echo off
echo ========================================
echo  QUICK SETUP - WEB ADMIN (With Firebase Config)
echo ========================================
echo.

cd web_admin

echo [1/3] Installing dependencies...
call npm install
if errorlevel 1 (
    echo ERROR: Failed to install!
    pause
    exit /b 1
)

echo.
echo [2/3] Setting up Firebase config...
if not exist ".env" (
    copy .env.real .env
    echo Firebase config copied!
) else (
    echo .env already exists, skipping...
)

echo.
echo [3/3] Setup complete!
echo.
echo ========================================
echo  READY TO START!
echo ========================================
echo.
echo IMPORTANT: Create admin user in Firestore:
echo   1. Register account in mobile app
echo   2. Go to Firebase Console ^> Firestore
echo   3. Find your user in 'users' collection
echo   4. Add field: role = "admin"
echo.
echo Starting development server...
echo.
timeout /t 3
npm run dev
