@echo off
echo ========================================
echo   MindVault Local Testing Server
echo ========================================
echo.
echo Starting local web server...
echo.
echo Open your browser and go to:
echo   http://localhost:8000
echo.
echo Press Ctrl+C to stop the server
echo.
echo ========================================
echo.

cd /d "%~dp0"

REM Try Python 3 first
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo Using Python...
    python -m http.server 8000
) else (
    echo Python not found. Please install Python 3.x
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

