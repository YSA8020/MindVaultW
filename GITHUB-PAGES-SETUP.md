# 🌐 GitHub Pages Setup for mindvault.fit

This guide shows you how to enable GitHub Pages to make mindvault.fit live.

---

## 🚨 **IMPORTANT: File Structure Issue Detected**

Your main HTML files are currently in the `public/` folder, but GitHub Pages expects them in the root directory. You have two options:

### **Option 1: Move Files to Root (Recommended)**
### **Option 2: Change GitHub Pages Source**

---

## 🚀 **Option 1: Move Files to Root (Recommended)**

### **Step 1: Move HTML Files**

Run these commands in PowerShell:

```powershell
cd C:\Projects\MindvaultW

# Move all HTML files from public/ to root
Move-Item public\*.html .

# Move assets folder
Move-Item public\assets assets -Force

# Move js folder
Move-Item public\js js -Force
```

### **Step 2: Commit and Push**

```bash
git add .
git commit -m "Move files to root for GitHub Pages"
git push origin main
```

### **Step 3: Enable GitHub Pages**

1. **Go to your GitHub repository**
2. **Click "Settings" tab**
3. **Scroll to "Pages"** (left sidebar)
4. **Under "Source":**
   - Select **"Deploy from a branch"**
   - Branch: **main**
   - Folder: **/ (root)**
5. **Click "Save"**

### **Step 4: Configure Custom Domain**

1. **Still in Pages settings**
2. **Under "Custom domain":**
   - Enter: **mindvault.fit**
3. **Click "Save"**
4. **Wait for DNS check** (may take a few minutes)
5. **Check "Enforce HTTPS"** once DNS is verified

---

## 🔧 **Option 2: Keep Files in Public Folder**

### **Step 1: Update Repository Structure**

Create an `index.html` in root that redirects:

```html
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=public/index.html">
    <script>window.location.href = "public/index.html";</script>
</head>
<body>
    <p>Redirecting to <a href="public/index.html">MindVault</a>...</p>
</body>
</html>
```

### **Step 2: Or Use GitHub Pages Docs Folder**

1. **Move public folder contents to docs/**

```powershell
# Create docs folder if not exists
New-Item -ItemType Directory -Path docs -Force

# Move files
Move-Item public\* docs\
```

2. **In GitHub Pages settings:**
   - Folder: **/docs**

---

## 🌐 **DNS Configuration (Already Done)**

Your `CNAME` file is already set up correctly with `mindvault.fit`.

### **Verify GoDaddy DNS Settings:**

1. **Go to GoDaddy DNS Management**
2. **Verify these A records point to GitHub Pages:**
   ```
   Type: A
   Name: @
   Value: 185.199.108.153
   
   Type: A
   Name: @
   Value: 185.199.109.153
   
   Type: A
   Name: @
   Value: 185.199.110.153
   
   Type: A
   Name: @
   Value: 185.199.111.153
   ```

3. **Verify CNAME record for www:**
   ```
   Type: CNAME
   Name: www
   Value: YOUR_GITHUB_USERNAME.github.io
   ```

---

## ✅ **Quick Fix (Recommended Path)**

Here's the fastest way to get mindvault.fit working:

### **Step 1: Reorganize Files**

```powershell
cd C:\Projects\MindvaultW

# Move all HTML files from public/ to root
Move-Item public\*.html . -Force

# Move assets
if (Test-Path assets) { Remove-Item assets -Recurse -Force }
Move-Item public\assets assets -Force

# Move js folder
if (Test-Path js) { Remove-Item js -Recurse -Force }
Move-Item public\js js -Force
```

### **Step 2: Commit Changes**

```bash
git add .
git commit -m "Reorganize for GitHub Pages"
git push origin main
```

### **Step 3: Enable GitHub Pages**

1. Go to: `https://github.com/YOUR_USERNAME/MindvaultW/settings/pages`
2. Source: **Deploy from a branch**
3. Branch: **main**
4. Folder: **/ (root)**
5. Click **Save**

### **Step 4: Configure Custom Domain**

1. Custom domain: **mindvault.fit**
2. Click **Save**
3. Wait for DNS check
4. Enable **Enforce HTTPS**

### **Step 5: Wait for Deployment**

- GitHub Pages takes **2-10 minutes** to deploy
- Check status at: `https://github.com/YOUR_USERNAME/MindvaultW/actions`

### **Step 6: Test Your Site**

Visit: `https://mindvault.fit`

---

## 🔍 **Troubleshooting**

### **Issue: "Site not found"**

**Solutions:**
1. Wait 5-10 minutes for deployment
2. Check if GitHub Pages is enabled
3. Verify files are in correct location
4. Clear browser cache (Ctrl + Shift + Delete)

### **Issue: "DNS check failed"**

**Solutions:**
1. Verify DNS records in GoDaddy
2. Wait 24-48 hours for DNS propagation
3. Check with: https://www.whatsmydns.net/
4. Temporarily remove custom domain, then re-add

### **Issue: "404 Page Not Found"**

**Solutions:**
1. Ensure `index.html` is in root (or configured folder)
2. Check GitHub Pages source folder setting
3. Verify file names are correct (case-sensitive)
4. Create `.nojekyll` file in root

### **Issue: "HTTPS not working"**

**Solutions:**
1. Wait for DNS verification to complete
2. Uncheck and recheck "Enforce HTTPS"
3. Wait 24 hours for SSL certificate generation
4. Check if DNS records are correct

### **Issue: "Custom domain not working"**

**Solutions:**
1. Remove custom domain
2. Wait 5 minutes
3. Re-add custom domain
4. Save and wait for DNS check

---

## 📁 **Current File Structure**

### **What You Have Now:**
```
MindvaultW/
├── public/
│   ├── index.html
│   ├── login.html
│   ├── signup.html
│   ├── dashboard.html
│   └── ... (all other HTML files)
├── CNAME (correct: mindvault.fit)
└── ... (other files)
```

### **What GitHub Pages Needs:**
```
MindvaultW/
├── index.html (← needs to be here)
├── login.html
├── signup.html
├── dashboard.html
├── assets/
├── js/
├── CNAME
└── ... (other files)
```

---

## 🎯 **Quick Commands**

### **1. Move Files from Public to Root:**

```powershell
cd C:\Projects\MindvaultW
Get-ChildItem public\*.html | Move-Item -Destination . -Force
Move-Item public\assets . -Force
Move-Item public\js . -Force
```

### **2. Commit and Push:**

```bash
git add .
git commit -m "Move files to root for GitHub Pages"
git push origin main
```

### **3. Check Deployment Status:**

Visit: `https://github.com/YOUR_USERNAME/MindvaultW/actions`

---

## 📊 **Deployment Checklist**

- [ ] Files are in root directory (or configured folder)
- [ ] CNAME file exists with `mindvault.fit`
- [ ] `.nojekyll` file exists (if using folders starting with _)
- [ ] GitHub Pages is enabled
- [ ] Source is set to main branch
- [ ] Folder is set to / (root) or /docs
- [ ] Custom domain is configured
- [ ] DNS records are correct in GoDaddy
- [ ] Waited 5-10 minutes for deployment
- [ ] Checked deployment status in Actions tab
- [ ] Tested site at mindvault.fit

---

## 🔒 **Enable HTTPS**

1. **After DNS verification completes:**
2. **Check "Enforce HTTPS" box**
3. **Wait up to 24 hours** for SSL certificate
4. **Site will auto-redirect** HTTP to HTTPS

---

## 📝 **DNS Configuration Reference**

### **GoDaddy DNS Settings:**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 185.199.108.153 | 600 |
| A | @ | 185.199.109.153 | 600 |
| A | @ | 185.199.110.153 | 600 |
| A | @ | 185.199.111.153 | 600 |
| CNAME | www | YOUR_USERNAME.github.io | 3600 |

---

## ✅ **Verification Steps**

### **1. Check GitHub Pages Status:**
```
https://github.com/YOUR_USERNAME/MindvaultW/settings/pages
```

### **2. Check Deployment:**
```
https://github.com/YOUR_USERNAME/MindvaultW/deployments
```

### **3. Check Actions:**
```
https://github.com/YOUR_USERNAME/MindvaultW/actions
```

### **4. Test DNS:**
```
https://www.whatsmydns.net/#A/mindvault.fit
```

### **5. Visit Site:**
```
https://mindvault.fit
```

---

## 🎉 **Success!**

Once everything is configured:

1. **Your site will be live** at `https://mindvault.fit`
2. **HTTPS will be enabled** automatically
3. **Updates push automatically** when you commit to main
4. **GitHub Pages is free** for public repositories

---

**Need help? Check the troubleshooting section or let me know!** 🚀

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*



