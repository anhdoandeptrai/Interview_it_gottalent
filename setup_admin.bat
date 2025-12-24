@echo off
echo ========================================
echo  INTERVIEW ADMIN PANEL - SETUP
echo ========================================
echo.

cd web_admin

echo [1/4] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)
echo OK - Node.js found

echo.
echo [2/4] Installing dependencies...
call npm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)
echo OK - Dependencies installed

echo.
echo [3/4] Checking environment file...
if not exist ".env" (
    echo WARNING: .env file not found
    echo Creating from template...
    copy .env.example .env
    echo.
    echo IMPORTANT: Please edit .env file and add your Firebase config!
    echo.
    pause
)

echo.
echo [4/4] Setup complete!
echo.
echo ========================================
echo  NEXT STEPS:
echo ========================================
echo 1. Edit web_admin\.env with your Firebase config
echo 2. Create admin user in Firestore (role: "admin")
echo 3. Run: npm run dev
echo.
echo Press any key to open .env file...
pause >nul
notepad .env

echo.
echo To start the admin panel, run:
echo   cd web_admin
echo   npm run dev
echo.
pause
