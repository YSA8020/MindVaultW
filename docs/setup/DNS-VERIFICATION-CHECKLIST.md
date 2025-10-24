# DNS Verification Checklist for mindvault.fit

## ⚠️ Current Issue
**Error**: Domain does not resolve to the GitHub Pages server (NotServedByPagesError)

## 🔍 Step-by-Step DNS Verification

### **Part 1: GoDaddy DNS Settings**

#### 1.1 Access GoDaddy DNS Management
1. Go to [godaddy.com](https://godaddy.com)
2. Sign in to your account
3. Click "My Products" → "Domains"
4. Find `mindvault.fit` and click "DNS"

#### 1.2 Check Current DNS Records
**What you should see:**

| Type | Name | Value | TTL | Action |
|------|------|-------|-----|--------|
| A | @ | 185.199.108.153 | 600s | ✅ Keep |
| A | @ | 185.199.109.153 | 600s | ✅ Keep |
| A | @ | 185.199.110.153 | 600s | ✅ Keep |
| A | @ | 185.199.111.153 | 600s | ✅ Keep |
| CNAME | www | ysa8020.github.io | 600s | ✅ Keep |

#### 1.3 Remove Conflicting Records
**Delete these if they exist:**
- ❌ Any A records with different IP addresses
- ❌ Any CNAME records for @ (apex domain)
- ❌ Any CNAME records for www pointing elsewhere
- ❌ Any GoDaddy parking/coming soon records

#### 1.4 Add Missing Records
If any records are missing, add them using the table above.

### **Part 2: GitHub Pages Settings**

#### 2.1 Access GitHub Pages Settings
1. Go to: https://github.com/YSA8020/MindVaultW/settings/pages
2. Scroll to "Custom domain" section

#### 2.2 Verify Custom Domain Configuration
**What you should see:**
- Custom domain field should show: `mindvault.fit`
- "Enforce HTTPS" checkbox (may be disabled until DNS propagates)
- DNS check status

#### 2.3 If DNS Check Fails
**Temporary Fix:**
1. Click "Remove" next to the custom domain
2. Click "Save"
3. Wait 5 minutes
4. Re-enter `mindvault.fit` in the custom domain field
5. Click "Save"

### **Part 3: Verify DNS Propagation**

#### 3.1 Check DNS Propagation Status
Use these tools to verify DNS propagation:

**Tool 1: DNS Checker**
- Visit: https://dnschecker.org/
- Enter: `mindvault.fit`
- Select: A record
- Check if all 4 GitHub Pages IPs appear

**Tool 2: What's My DNS**
- Visit: https://www.whatsmydns.net/
- Enter: `mindvault.fit`
- Select: A record
- Check propagation status

**Tool 3: Command Line (Windows PowerShell)**
```powershell
nslookup mindvault.fit
```

**Expected Output:**
```
Name:    mindvault.fit
Addresses:  185.199.108.153
          185.199.109.153
          185.199.110.153
          185.199.111.153
```

#### 3.2 Check CNAME Record
```powershell
nslookup www.mindvault.fit
```

**Expected Output:**
```
Name:    www.mindvault.fit
Addresses:  [GitHub Pages IPs]
```

### **Part 4: Common Issues and Solutions**

#### Issue 1: DNS Not Propagating
**Solution:**
- Wait 24-48 hours for full propagation
- Clear browser cache
- Try accessing from different network
- Use incognito/private browsing mode

#### Issue 2: GoDaddy Parking Page Showing
**Solution:**
1. In GoDaddy DNS settings, find any "Parked" or "Coming Soon" records
2. Delete them
3. Wait for DNS to update

#### Issue 3: Multiple A Records
**Solution:**
- Keep ONLY the 4 GitHub Pages IP addresses
- Delete any other A records

#### Issue 4: CNAME on Apex Domain
**Solution:**
- GoDaddy doesn't allow CNAME on @ (apex domain)
- Use A records instead (already configured above)

### **Part 5: Verification Checklist**

Use this checklist to verify everything is correct:

- [ ] GoDaddy has exactly 4 A records pointing to GitHub Pages IPs
- [ ] GoDaddy has 1 CNAME record for www pointing to ysa8020.github.io
- [ ] No conflicting DNS records exist
- [ ] GitHub Pages has mindvault.fit configured as custom domain
- [ ] DNS propagation shows correct IPs (check 2-3 tools)
- [ ] CNAME file exists in repository (already created)
- [ ] No GoDaddy parking/coming soon page active

### **Part 6: Testing Your Domain**

#### 6.1 Test Domain Access
Once DNS propagates, test these URLs:

1. **Main domain**: https://mindvault.fit
2. **WWW subdomain**: https://www.mindvault.fit
3. **GitHub Pages**: https://ysa8020.github.io/MindVaultW/

**Expected Results:**
- All three URLs should show your MindVault site
- HTTPS should work automatically
- No redirect loops

#### 6.2 Test Specific Pages
- https://mindvault.fit/index.html
- https://mindvault.fit/signup.html
- https://mindvault.fit/login.html

### **Part 7: Troubleshooting Commands**

#### Check Current DNS Records
```powershell
# Check A records
nslookup -type=A mindvault.fit

# Check CNAME records
nslookup -type=CNAME www.mindvault.fit

# Check all records
nslookup -type=ANY mindvault.fit
```

#### Check GitHub Pages Status
```powershell
# Test if GitHub Pages is responding
curl -I https://ysa8020.github.io/MindVaultW/

# Test custom domain
curl -I https://mindvault.fit
```

### **Part 8: Timeline Expectations**

| Time | Status | Action |
|------|--------|--------|
| 0-1 hour | DNS changes propagating | Wait |
| 1-4 hours | Partial propagation | Test with DNS checker tools |
| 4-24 hours | Full propagation | Test domain access |
| 24-48 hours | Complete propagation | Verify HTTPS certificate |

### **Part 9: If Issues Persist**

#### Contact Support
1. **GoDaddy Support**
   - Phone: (480) 505-8877
   - Email: support@godaddy.com
   - Chat: Available on godaddy.com

2. **GitHub Support**
   - Visit: https://support.github.com/
   - Email: support@github.com

3. **Check GitHub Status**
   - Visit: https://www.githubstatus.com/

### **Part 10: Quick Reference**

**GitHub Pages IP Addresses:**
```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

**GitHub Pages CNAME:**
```
ysa8020.github.io
```

**Your Custom Domain:**
```
mindvault.fit
```

## ✅ Next Steps

1. **Verify GoDaddy DNS settings** using Part 1
2. **Verify GitHub Pages settings** using Part 2
3. **Check DNS propagation** using Part 3
4. **Wait for propagation** (24-48 hours)
5. **Test your domain** using Part 6

## 📞 Need Help?

If you're still experiencing issues after following this checklist:
1. Take screenshots of your GoDaddy DNS settings
2. Take screenshots of your GitHub Pages settings
3. Share the results from DNS checker tools
4. Contact support with the information

---

**Last Updated**: $(date)
**Domain**: mindvault.fit
**Repository**: YSA8020/MindVaultW
