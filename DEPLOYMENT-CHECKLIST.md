# ✅ MindVault Deployment Checklist

## Quick Reference - Follow These Steps

### ✅ **Pre-Deployment** (Already Done!)
- [x] Code refactored to Next.js
- [x] Environment variables configured
- [x] Committed to Git
- [x] Pushed to GitHub

---

### 📋 **Deploy to Vercel** (Do This Now!)

#### **1. Create Vercel Account**
- [ ] Go to https://vercel.com
- [ ] Click "Sign Up"
- [ ] Choose "Continue with GitHub"
- [ ] Authorize Vercel

#### **2. Import Project**
- [ ] Click "Add New..." → "Project"
- [ ] Find "MindvaultW" repository
- [ ] Click "Import"

#### **3. Configure Build**
- [ ] Framework: Next.js (auto-detected)
- [ ] Root Directory: ./
- [ ] Build Command: npm run build
- [ ] Output Directory: .next

#### **4. Add Environment Variables**
Add these 3 variables:

- [ ] `NEXT_PUBLIC_SUPABASE_URL` = `https://swacnbyayimigfzgzgvm.supabase.co`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3YWNuYnlheWltaWdmemd6Z3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5MDMzNjcsImV4cCI6MjA3NTQ3OTM2N30.5AKdysWwZkB_YVGTQl3eDqhgfcpRio0hTnjFo6rloZA`
- [ ] `NEXT_PUBLIC_GA_MEASUREMENT_ID` = `G-V1ZZ3VLV2L`

#### **5. Deploy**
- [ ] Click "Deploy" button
- [ ] Wait 2-5 minutes for build
- [ ] See ✅ "Deployment Ready"
- [ ] Click "Visit" to test

---

### 🌐 **Configure Custom Domain**

#### **6. Add Domain in Vercel**
- [ ] Go to Settings → Domains
- [ ] Add `mindvault.fit`
- [ ] Add `www.mindvault.fit`
- [ ] Note the DNS records shown

#### **7. Update DNS** (At your domain registrar)

**A Record:**
- [ ] Type: A
- [ ] Name: @
- [ ] Value: 76.76.21.21

**CNAME Record:**
- [ ] Type: CNAME
- [ ] Name: www
- [ ] Value: cname.vercel-dns.com

- [ ] Save DNS changes

#### **8. Wait for DNS**
- [ ] Wait 5-30 minutes
- [ ] Check https://dnschecker.org/
- [ ] Verify in Vercel (Settings → Domains shows ✅)

#### **9. Verify HTTPS**
- [ ] Visit https://mindvault.fit
- [ ] See green padlock 🔒
- [ ] SSL certificate active

---

### 🧪 **Test Deployment**

- [ ] https://mindvault.fit loads
- [ ] https://www.mindvault.fit loads
- [ ] Landing page displays
- [ ] Navigation works
- [ ] Sign up page loads
- [ ] Login page loads
- [ ] Can create account
- [ ] Can login
- [ ] Dashboard loads
- [ ] Dark mode works
- [ ] No console errors (F12)
- [ ] Database connected
- [ ] Mood tracking works

---

### 🎉 **Launch**

- [ ] All tests passed
- [ ] Monitoring enabled
- [ ] Analytics configured
- [ ] Error tracking set up (optional)
- [ ] Team notified
- [ ] Documentation updated
- [ ] Announcement prepared

---

## 🚀 **You're Live!**

**Site URL:** https://mindvault.fit

**Auto-Deployments:** Every push to `main` = automatic deploy

**Next:** Monitor, test, gather feedback, iterate!

---

## 📞 **Quick Links**

- **Detailed Guide:** [DEPLOY-NOW.md](DEPLOY-NOW.md)
- **Vercel Dashboard:** https://vercel.com/dashboard
- **GitHub Repo:** https://github.com/YSA8020/MindvaultW
- **Supabase Dashboard:** https://supabase.com/dashboard
- **DNS Checker:** https://dnschecker.org/

---

*Estimated Time: 30-45 minutes*

