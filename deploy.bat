@echo off
REM MindVault Deployment Script for Windows
REM This script helps you deploy MindVault to production

echo 🚀 MindVault Deployment Script
echo ==============================

REM Check if we're in the right directory
if not exist "index.html" (
    echo ❌ Error: Please run this script from the MindVault project root directory
    pause
    exit /b 1
)

echo ✅ Found MindVault project files

REM Check if Supabase config exists
if not exist "js\supabase-config.js" (
    echo ❌ Error: Supabase configuration file not found
    echo Please create js\supabase-config.js with your Supabase credentials
    pause
    exit /b 1
)

echo ✅ Found Supabase configuration

REM Check if git is initialized
if not exist ".git" (
    echo 📦 Initializing Git repository...
    git init
    git add .
    git commit -m "Initial commit: MindVault project setup"
)

echo ✅ Git repository ready

REM Check if we have a remote origin
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo 🔗 Please add your GitHub repository as origin:
    echo git remote add origin https://github.com/yourusername/MindvaultW.git
    echo.
    echo Then run this script again
    pause
    exit /b 1
)

echo ✅ GitHub remote configured

REM Check for uncommitted changes
git diff-index --quiet HEAD --
if errorlevel 1 (
    echo 📝 Committing changes...
    git add .
    git commit -m "Update: Add Supabase backend integration and deployment setup"
)

echo ✅ All changes committed

REM Push to GitHub
echo 🚀 Deploying to GitHub...
git push origin main

if errorlevel 1 (
    echo ❌ Deployment failed. Please check your GitHub repository settings.
    pause
    exit /b 1
)

echo.
echo 🎉 Deployment successful!
echo.
echo Next steps:
echo 1. Go to your GitHub repository settings
echo 2. Navigate to Pages section
echo 3. Select 'GitHub Actions' as source
echo 4. Your site will be available at: https://yourusername.github.io/MindvaultW
echo.
echo 📊 Monitor deployment at: https://github.com/yourusername/MindvaultW/actions
echo.
echo 🧪 Test your deployment with: integration-test.html
echo.
pause
