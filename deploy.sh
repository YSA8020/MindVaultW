#!/bin/bash
# MindVault Deployment Script
# This script helps you deploy MindVault to production

echo "🚀 MindVault Deployment Script"
echo "=============================="

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    echo "❌ Error: Please run this script from the MindVault project root directory"
    exit 1
fi

echo "✅ Found MindVault project files"

# Check if Supabase config exists
if [ ! -f "js/supabase-config.js" ]; then
    echo "❌ Error: Supabase configuration file not found"
    echo "Please create js/supabase-config.js with your Supabase credentials"
    exit 1
fi

echo "✅ Found Supabase configuration"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: MindVault project setup"
fi

echo "✅ Git repository ready"

# Check if we have a remote origin
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Please add your GitHub repository as origin:"
    echo "git remote add origin https://github.com/yourusername/MindvaultW.git"
    echo ""
    echo "Then run this script again"
    exit 1
fi

echo "✅ GitHub remote configured"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "📝 Committing changes..."
    git add .
    git commit -m "Update: Add Supabase backend integration and deployment setup"
fi

echo "✅ All changes committed"

# Push to GitHub
echo "🚀 Deploying to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Deployment successful!"
    echo ""
    echo "Next steps:"
    echo "1. Go to your GitHub repository settings"
    echo "2. Navigate to Pages section"
    echo "3. Select 'GitHub Actions' as source"
    echo "4. Your site will be available at: https://yourusername.github.io/MindvaultW"
    echo ""
    echo "📊 Monitor deployment at: https://github.com/yourusername/MindvaultW/actions"
    echo ""
    echo "🧪 Test your deployment with: integration-test.html"
else
    echo "❌ Deployment failed. Please check your GitHub repository settings."
    exit 1
fi
