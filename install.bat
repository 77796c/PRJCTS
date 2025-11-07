@echo off
REM Note Keeper App - Easy Setup Script for Windows
REM This script will set everything up automatically!

echo 🚀 Setting up Note Keeper App for ChatGPT...
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js is not installed.
    echo Please install Node.js from: https://nodejs.org/
    echo Download the LTS version (recommended for most users)
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo ✅ Node.js found: %NODE_VERSION%
echo.

REM Install dependencies
echo 📦 Installing dependencies...
call npm install --silent
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)
echo ✅ Dependencies installed
echo.

REM Build the app
echo 🔨 Building the app...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build the app
    pause
    exit /b 1
)
echo ✅ App built successfully
echo.

REM Get the current directory
set CURRENT_DIR=%CD%

echo 🎉 Setup complete!
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📝 NEXT STEPS - Copy this configuration:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo Add this to your ChatGPT MCP configuration:
echo.
echo {
echo   "note-keeper": {
echo     "command": "node",
echo     "args": ["%CURRENT_DIR%\dist\server.js"],
echo     "cwd": "%CURRENT_DIR%"
echo   }
echo }
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 📍 Your app is installed at: %CURRENT_DIR%
echo.
echo Need help? Check out EASY_SETUP.md for step-by-step instructions!
echo.
pause
