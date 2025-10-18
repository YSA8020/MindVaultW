# 🧪 MindVault Local Testing Guide

This guide shows you how to test MindVault locally without publishing it.

---

## 📋 Overview

You can test MindVault in three ways:
1. **Local File Testing** - Open HTML files directly in browser
2. **Local Server** - Run a local web server
3. **GitHub Pages Preview** - Use GitHub's preview feature

---

## 🚀 Method 1: Local File Testing (Simplest)

### Step 1: Open Files Directly

1. **Navigate to your project folder:**
   ```
   C:\Projects\MindvaultW
   ```

2. **Open `index.html` in your browser:**
   - Double-click `index.html`
   - Or right-click → Open with → Chrome/Firefox/Edge

3. **Test the pages:**
   - `index.html` - Landing page
   - `login.html` - Login page
   - `signup.html` - Signup page
   - `dashboard.html` - User dashboard
   - `counselor-dashboard.html` - Professional dashboard

### ⚠️ Limitations

- **CORS Issues:** Some features may not work due to browser security
- **No Backend:** Database features won't work without Supabase connection
- **File Protocol:** Some modern web features require HTTP/HTTPS

---

## 🌐 Method 2: Local Web Server (Recommended)

### Option A: Using Python (Built-in)

#### Step 1: Open Command Prompt or PowerShell

Press `Win + R`, type `cmd` or `powershell`, press Enter

#### Step 2: Navigate to Project Folder

```bash
cd C:\Projects\MindvaultW
```

#### Step 3: Start Python Server

**Python 3:**
```bash
python -m http.server 8000
```

**Python 2 (if Python 3 not available):**
```bash
python -m SimpleHTTPServer 8000
```

#### Step 4: Open in Browser

Open your browser and go to:
```
http://localhost:8000
```

#### Step 5: Test Pages

- `http://localhost:8000/index.html` - Landing page
- `http://localhost:8000/login.html` - Login page
- `http://localhost:8000/signup.html` - Signup page
- `http://localhost:8000/dashboard.html` - User dashboard

#### Step 6: Stop Server

Press `Ctrl + C` in the terminal to stop the server

---

### Option B: Using Node.js (if installed)

#### Step 1: Install http-server (if not installed)

```bash
npm install -g http-server
```

#### Step 2: Navigate to Project Folder

```bash
cd C:\Projects\MindvaultW
```

#### Step 3: Start Server

```bash
http-server -p 8000
```

#### Step 4: Open in Browser

```
http://localhost:8000
```

#### Step 5: Stop Server

Press `Ctrl + C` in the terminal

---

### Option C: Using VS Code Live Server Extension

#### Step 1: Install VS Code

Download from: https://code.visualstudio.com/

#### Step 2: Install Live Server Extension

1. Open VS Code
2. Click Extensions icon (or press `Ctrl + Shift + X`)
3. Search for "Live Server"
4. Click Install

#### Step 3: Open Project

1. In VS Code, click File → Open Folder
2. Select `C:\Projects\MindvaultW`
3. Click Select Folder

#### Step 4: Start Live Server

1. Right-click on `index.html`
2. Click "Open with Live Server"
3. Browser will open automatically at `http://127.0.0.1:5500`

#### Step 5: Auto-Reload

- Any changes you make will automatically reload in the browser
- Perfect for testing and development

---

## 🔧 Method 3: GitHub Pages Preview (Without Publishing)

### Step 1: Push to GitHub

```bash
cd C:\Projects\MindvaultW
git add .
git commit -m "Test version"
git push origin main
```

### Step 2: Enable GitHub Pages

1. Go to your GitHub repository
2. Click **Settings** tab
3. Scroll to **Pages** section (left sidebar)
4. Under **Source**, select **Deploy from a branch**
5. Select **main** branch
6. Select **/ (root)** folder
7. Click **Save**

### Step 3: Access Preview

GitHub will provide a URL like:
```
https://yourusername.github.io/MindvaultW/
```

**Note:** This makes it publicly accessible, but only if someone knows the exact URL.

---

## 🧪 Testing Checklist

### Basic Testing

- [ ] **Landing Page**
  - Open `index.html`
  - Check if page loads
  - Test email signup form
  - Click "Admin Access" link

- [ ] **Signup Page**
  - Open `signup.html`
  - Test user type selection
  - Test form validation
  - Test plan selection

- [ ] **Login Page**
  - Open `login.html`
  - Test form layout
  - Test dark mode toggle
  - Test social login buttons

- [ ] **Dashboard**
  - Open `dashboard.html`
  - Test mood check-in
  - Test feature cards
  - Test navigation

### Advanced Testing (Requires Supabase)

- [ ] **Database Connection**
  - Test user registration
  - Test user login
  - Test profile creation

- [ ] **Professional Features**
  - Test professional signup
  - Test professional onboarding
  - Test professional dashboard

- [ ] **Security Features**
  - Test rate limiting
  - Test failed login tracking
  - Test account lockout

---

## 🔐 Testing with Supabase (Full Functionality)

### Step 1: Set Up Supabase

1. Go to https://supabase.com
2. Create a free account
3. Create a new project
4. Wait for database to be ready

### Step 2: Get API Keys

1. In Supabase Dashboard, click **Settings** (gear icon)
2. Click **API**
3. Copy:
   - **Project URL**
   - **Anon/Public Key**
   - **Service Role Key** (keep secret!)

### Step 3: Update Configuration

1. Open `js/supabase-config.js`
2. Update with your Supabase credentials:

```javascript
const SUPABASE_URL = 'YOUR_PROJECT_URL';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

### Step 4: Run Database Setup

1. In Supabase Dashboard, click **SQL Editor**
2. Click **New Query**
3. Copy contents of `COMPLETE-SETUP-INCREMENTAL.sql`
4. Paste into SQL Editor
5. Click **Run**
6. Wait for success message

### Step 5: Test Locally

1. Start local server (Method 2)
2. Open `http://localhost:8000`
3. Test all features

---

## 🐛 Troubleshooting

### Issue: "CORS Error"

**Solution:** Use local web server (Method 2) instead of opening files directly

### Issue: "Database Connection Failed"

**Solution:** 
1. Check Supabase credentials in `js/supabase-config.js`
2. Verify Supabase project is active
3. Check browser console for errors

### Issue: "Page Not Found"

**Solution:**
1. Make sure you're in the correct directory
2. Check file names match exactly
3. Try refreshing the page

### Issue: "Port Already in Use"

**Solution:**
1. Stop the existing server (`Ctrl + C`)
2. Or use a different port:
   ```bash
   python -m http.server 8080
   ```

### Issue: "Module Not Found"

**Solution:**
1. Check all JavaScript files are in `js/` folder
2. Verify file names match in HTML
3. Clear browser cache

---

## 📱 Testing on Mobile

### Option 1: Local Network Access

1. Find your computer's local IP:
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.1.100)

2. Start local server:
   ```bash
   python -m http.server 8000
   ```

3. On your phone, open:
   ```
   http://192.168.1.100:8000
   ```
   (Replace with your actual IP)

### Option 2: Use ngrok (Advanced)

1. Install ngrok: https://ngrok.com/download
2. Start local server:
   ```bash
   python -m http.server 8000
   ```

3. In another terminal:
   ```bash
   ngrok http 8000
   ```

4. Copy the ngrok URL (e.g., `https://abc123.ngrok.io`)
5. Open on any device

---

## 🎨 Testing Different Features

### Test User Registration

1. Open `signup.html`
2. Select "I'm Seeking Support"
3. Fill in the form:
   - First Name: Test
   - Last Name: User
   - Email: test@example.com
   - Password: Test123!
4. Select a plan
5. Click "Start 14-Day Free Trial"
6. Check if redirects to dashboard

### Test Professional Registration

1. Open `signup.html`
2. Select "I'm a Professional"
3. Fill in the form:
   - First Name: Dr. Jane
   - Last Name: Smith
   - Email: jane@example.com
   - Password: Test123!
   - License Type: Licensed Professional Counselor (LPC)
   - License Number: LPC-12345
   - Years of Experience: 5-10 years
4. Select Professional plan
5. Click "Start 14-Day Free Trial"
6. Check if shows vetting message

### Test Login

1. Open `login.html`
2. Enter credentials:
   - Email: test@example.com
   - Password: Test123!
3. Click "Sign In"
4. Check if redirects to dashboard

### Test Dashboard

1. After login, you should see the dashboard
2. Test mood check-in:
   - Click on a mood (Sad, Neutral, Happy)
   - Check if it highlights
3. Test feature cards:
   - Click on "Anonymous Sharing"
   - Click on "Counselor Matching"
   - Click on "Peer Support"

### Test Professional Dashboard

1. Complete professional registration
2. After verification, login
3. You should see professional dashboard
4. Test features:
   - View client list
   - Create session
   - View analytics

---

## 🔒 Security Testing

### Test Rate Limiting

1. Open `login.html`
2. Enter wrong password 5 times
3. On 6th attempt, check if account is locked
4. Wait 30 minutes or check lockout message

### Test Failed Login Tracking

1. Open `login.html`
2. Enter wrong password
3. Check browser console for logged attempts
4. Check if IP address is logged

### Test Account Lockout

1. Try to login with wrong password 5 times
2. Check if error message appears
3. Check if countdown timer shows
4. Wait for unlock or check message

---

## 📊 Performance Testing

### Check Page Load Time

1. Open browser DevTools (`F12`)
2. Go to **Network** tab
3. Refresh page
4. Check load time (should be < 2 seconds)

### Check Console Errors

1. Open browser DevTools (`F12`)
2. Go to **Console** tab
3. Refresh page
4. Check for any red errors
5. Fix any issues found

### Check Responsive Design

1. Open browser DevTools (`F12`)
2. Click **Toggle Device Toolbar** (or press `Ctrl + Shift + M`)
3. Test different devices:
   - Mobile (375px)
   - Tablet (768px)
   - Desktop (1920px)
4. Check if layout adapts correctly

---

## 🎯 Quick Start Commands

### Start Local Server (Python)

```bash
cd C:\Projects\MindvaultW
python -m http.server 8000
```

Then open: `http://localhost:8000`

### Start Local Server (Node.js)

```bash
cd C:\Projects\MindvaultW
http-server -p 8000
```

Then open: `http://localhost:8000`

### Stop Server

Press `Ctrl + C` in the terminal

---

## ✅ Testing Checklist

### Before Testing

- [ ] Project folder exists
- [ ] All HTML files present
- [ ] JavaScript files in `js/` folder
- [ ] Assets in `assets/` folder
- [ ] Supabase configured (if testing database)

### During Testing

- [ ] Landing page loads
- [ ] Navigation works
- [ ] Forms validate correctly
- [ ] Buttons trigger actions
- [ ] No console errors
- [ ] Responsive on mobile
- [ ] Dark mode works

### After Testing

- [ ] All features tested
- [ ] Issues documented
- [ ] Bugs fixed
- [ ] Ready for deployment

---

## 📝 Testing Notes

### What Works Without Backend

- ✅ Page layouts
- ✅ Navigation
- ✅ Form validation
- ✅ UI interactions
- ✅ Dark mode
- ✅ Responsive design
- ✅ Animations

### What Requires Backend

- ❌ User registration
- ❌ User login
- ❌ Database operations
- ❌ File uploads
- ❌ Real-time features
- ❌ Email notifications

---

## 🚀 Next Steps

After local testing:

1. **Fix any issues** found during testing
2. **Test with Supabase** for full functionality
3. **Run through testing checklist** (200 test cases)
4. **Deploy to GitHub Pages** when ready
5. **Configure custom domain** for production

---

## 💡 Pro Tips

1. **Use Browser DevTools** - Press `F12` to debug issues
2. **Test in Multiple Browsers** - Chrome, Firefox, Safari, Edge
3. **Test on Mobile** - Use local network or ngrok
4. **Clear Cache** - Press `Ctrl + Shift + Delete`
5. **Check Console** - Look for errors in Console tab
6. **Test Dark Mode** - Click theme toggle button
7. **Test Responsive** - Resize browser window
8. **Test Forms** - Try submitting with empty fields
9. **Test Navigation** - Click all links
10. **Document Issues** - Keep track of bugs found

---

**Happy Testing! 🧪**

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

