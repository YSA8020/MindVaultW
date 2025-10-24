# Deployment Guide for mindvault.fit

## Overview

This guide covers deploying MindVault to production using modern hosting platforms. **GitHub Pages is not recommended** for this Next.js application due to its limitations with server-side rendering and dynamic routes.

## Recommended Platforms

### 🚀 Option 1: Vercel (Recommended for Next.js)

**Why Vercel?**
- Built by the creators of Next.js
- Zero configuration needed
- Automatic deployments from GitHub
- Edge functions support
- Excellent performance
- Free SSL and CDN included
- 100GB bandwidth on free tier

#### Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

#### Step 2: Login to Vercel

```bash
vercel login
```

#### Step 3: Deploy

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod

# Or use npm script
npm run deploy:vercel
```

#### Step 4: Configure Environment Variables

1. Go to [vercel.com/dashboard](https://vercel.com/dashboard)
2. Select your project
3. Go to **Settings** → **Environment Variables**
4. Add the following:

```env
NEXT_PUBLIC_SUPABASE_URL=https://swacnbyayimigfzgzgvm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-V1ZZ3VLV2L
NODE_ENV=production
```

#### Step 5: Configure Custom Domain (mindvault.fit)

1. In Vercel dashboard, go to **Settings** → **Domains**
2. Click **Add Domain**
3. Enter `mindvault.fit`
4. Vercel will provide DNS records:

**DNS Configuration:**
```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME  
Name: www
Value: cname.vercel-dns.com
```

5. Add these records to your domain registrar
6. Wait for DNS propagation (5-60 minutes)
7. Vercel will automatically issue SSL certificate

#### Step 6: Automatic Deployments

1. Go to **Settings** → **Git**
2. Connect your GitHub repository
3. Enable **Automatic Deployments from main branch**

Now every push to `main` automatically deploys!

---

### 🌐 Option 2: Netlify

**Why Netlify?**
- Great for static and JAMstack sites
- Excellent Next.js plugin
- Generous free tier
- Easy custom domain setup
- Built-in form handling

#### Step 1: Install Netlify CLI

```bash
npm install -g netlify-cli
```

#### Step 2: Login to Netlify

```bash
netlify login
```

#### Step 3: Initialize Site

```bash
netlify init
```

Follow the prompts:
- **Create & configure a new site**
- Choose your team
- Site name: `mindvault` (or custom)
- Build command: `npm run build`
- Publish directory: `.next`

#### Step 4: Deploy

```bash
# Deploy to preview
netlify deploy

# Deploy to production
netlify deploy --prod

# Or use npm script
npm run deploy:netlify
```

#### Step 5: Configure Environment Variables

1. Go to [app.netlify.com](https://app.netlify.com)
2. Select your site
3. Go to **Site settings** → **Environment variables**
4. Add:

```env
NEXT_PUBLIC_SUPABASE_URL=https://swacnbyayimigfzgzgvm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-V1ZZ3VLV2L
NODE_ENV=production
```

#### Step 6: Configure Custom Domain

1. Go to **Domain settings** → **Custom domains**
2. Click **Add custom domain**
3. Enter `mindvault.fit`
4. Netlify will provide DNS records:

**DNS Configuration:**
```
Type: A
Name: @
Value: 75.2.60.5

Type: CNAME
Name: www
Value: your-site.netlify.app
```

5. Add to your domain registrar
6. Enable HTTPS (automatic with Let's Encrypt)

---

### ☁️ Option 3: Cloudflare Pages

**Why Cloudflare Pages?**
- Unlimited bandwidth
- Fast global CDN
- Free SSL
- Great DDoS protection

#### Step 1: Connect GitHub

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Select **Pages** → **Create a project**
3. Connect your GitHub account
4. Select your repository

#### Step 2: Configure Build

```
Build command: npm run build
Build output directory: .next
Root directory: /
Node version: 18
```

#### Step 3: Environment Variables

Add in build settings:
```env
NEXT_PUBLIC_SUPABASE_URL=your-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-key
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-V1ZZ3VLV2L
```

#### Step 4: Custom Domain

1. Go to **Custom domains**
2. Add `mindvault.fit`
3. Follow DNS instructions

---

## DNS Configuration for mindvault.fit

### Current Setup (Replace GitHub Pages)

If you currently have DNS pointing to GitHub Pages:

```
# OLD (Remove these)
Type: A
Name: @
Value: 185.199.108.153 (GitHub Pages IP)

Type: CNAME
Name: www
Value: yourusername.github.io
```

### New Setup (Vercel - Recommended)

```
# NEW (Add these)
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Where to Update DNS

Your DNS is managed by your domain registrar. Common registrars:

- **GoDaddy**: DNS Management → Records
- **Namecheap**: Advanced DNS
- **Cloudflare**: DNS Management
- **Google Domains**: DNS → Custom records

### Verification

After updating DNS, verify with:

```bash
# Check A record
nslookup mindvault.fit

# Check CNAME
nslookup www.mindvault.fit

# Or use online tool
# https://dnschecker.org/
```

---

## Deployment Comparison

| Feature | Vercel | Netlify | Cloudflare Pages | GitHub Pages |
|---------|--------|---------|------------------|--------------|
| Next.js SSR | ✅ Perfect | ✅ Good | ⚠️ Limited | ❌ No |
| Build Time | Fast | Fast | Fast | Slow |
| Bandwidth | 100GB free | 100GB free | Unlimited | 100GB |
| Custom Domain | ✅ Easy | ✅ Easy | ✅ Easy | ⚠️ Limited |
| SSL | ✅ Auto | ✅ Auto | ✅ Auto | ⚠️ Manual |
| Edge Functions | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| Preview Deploys | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| Private Repos | ✅ Yes | ✅ Yes | ✅ Yes | ❌ Paid |
| **Recommended** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ❌ Not suitable |

---

## Step-by-Step: Complete Deployment (Vercel)

### 1. Prepare Repository

```bash
# Ensure latest code is committed
git add .
git commit -m "Prepare for deployment"
git push origin main
```

### 2. Deploy to Vercel

```bash
# Login
vercel login

# Deploy
vercel --prod
```

### 3. Configure Environment

In Vercel dashboard:
- Add all `NEXT_PUBLIC_*` environment variables
- Ensure they're set for **Production** environment

### 4. Update DNS

In your domain registrar (e.g., GoDaddy, Namecheap):

1. Delete existing GitHub Pages records
2. Add Vercel A record:
   ```
   Type: A
   Name: @
   Value: 76.76.21.21
   TTL: Auto or 3600
   ```
3. Add Vercel CNAME:
   ```
   Type: CNAME
   Name: www
   Value: cname.vercel-dns.com
   TTL: Auto or 3600
   ```

### 5. Add Domain in Vercel

1. Go to **Settings** → **Domains**
2. Add `mindvault.fit`
3. Add `www.mindvault.fit`
4. Vercel will verify DNS automatically
5. SSL certificate issued automatically

### 6. Test Deployment

```bash
# Test your domain
curl https://mindvault.fit
curl https://www.mindvault.fit

# Or visit in browser
open https://mindvault.fit
```

### 7. Set Up Automatic Deployments

1. **Settings** → **Git** → **Connected Git Repository**
2. Enable **Production Branch**: `main`
3. Enable **Preview Deployments** for pull requests

Now:
- Push to `main` → Auto deploy to production
- Create PR → Auto deploy preview URL
- Merge PR → Auto deploy to production

---

## CI/CD with GitHub Actions (Optional)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run type check
        run: npm run type-check
      
      - name: Run linter
        run: npm run lint
      
      - name: Build
        run: npm run build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

---

## Environment Variables Checklist

Before deploying, ensure these are set in your hosting platform:

### Required
- [ ] `NEXT_PUBLIC_SUPABASE_URL`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`

### Optional
- [ ] `NEXT_PUBLIC_GA_MEASUREMENT_ID`
- [ ] `NEXT_PUBLIC_ENVIRONMENT`
- [ ] `NODE_ENV` (usually auto-set to `production`)

---

## Post-Deployment Checklist

After deployment:

- [ ] Site loads at `https://mindvault.fit`
- [ ] SSL certificate is active (green padlock)
- [ ] All pages accessible
- [ ] Can create account
- [ ] Can login
- [ ] Dashboard loads correctly
- [ ] Database connection works
- [ ] No console errors
- [ ] Mobile responsive
- [ ] Dark mode works
- [ ] Analytics tracking (if enabled)
- [ ] Forms submit correctly
- [ ] Images load properly
- [ ] SEO meta tags present

---

## Rollback Strategy

If deployment fails:

### Vercel
```bash
# List deployments
vercel ls

# Rollback to previous
vercel rollback [deployment-url]
```

### Netlify
1. Go to **Deploys**
2. Find working deployment
3. Click **Publish deploy**

### Manual
```bash
# Revert commit
git revert HEAD
git push origin main
# Platform auto-deploys previous version
```

---

## Monitoring & Logs

### Vercel
- **Logs**: Vercel Dashboard → Project → Logs
- **Analytics**: Built-in analytics available
- **Monitoring**: Real-time function logs

### Netlify
- **Logs**: Site Dashboard → Deploys → Deploy log
- **Analytics**: Netlify Analytics (paid add-on)
- **Functions**: Function logs in dashboard

---

## Performance Optimization

After deployment:

### 1. Check Speed
```bash
# Use Lighthouse
npx lighthouse https://mindvault.fit --view

# Or use WebPageTest
# https://www.webpagetest.org/
```

### 2. Enable Caching
Already configured in `vercel.json` and `netlify.toml`

### 3. Image Optimization
Next.js automatically optimizes images on Vercel

### 4. Enable Compression
Automatic on all platforms

---

## Troubleshooting

### Issue: Domain not resolving

**Solution:**
```bash
# Check DNS propagation
nslookup mindvault.fit

# Wait 5-60 minutes for DNS to propagate
# Clear browser cache
# Try incognito mode
```

### Issue: Environment variables not working

**Solution:**
1. Verify vars are set in platform dashboard
2. Check they're enabled for Production
3. Redeploy after adding vars
4. Ensure vars start with `NEXT_PUBLIC_`

### Issue: Build fails

**Solution:**
```bash
# Test build locally
npm run build

# Check build logs in platform
# Fix TypeScript errors
npm run type-check

# Fix linter errors
npm run lint
```

### Issue: 404 on routes

**Solution:**
- Ensure Next.js is in SSR mode (not static export)
- Check `next.config.js` doesn't have `output: 'export'`
- Verify platform supports Next.js dynamic routes

---

## Cost Estimation

### Vercel (Hobby Tier - Free)
- ✅ 100GB bandwidth
- ✅ Unlimited API requests
- ✅ Automatic SSL
- ✅ DDoS protection
- 📈 Pro tier: $20/month (if needed)

### Netlify (Free Tier)
- ✅ 100GB bandwidth  
- ✅ 300 build minutes/month
- ✅ Unlimited sites
- 📈 Pro tier: $19/month (if needed)

### Cloudflare Pages (Free)
- ✅ Unlimited bandwidth
- ✅ Unlimited requests
- ✅ 500 builds/month
- 📈 No paid tier needed

**Recommendation:** Start with Vercel free tier. Upgrade only if you exceed limits.

---

## Next Steps

1. ✅ **Choose Platform**: We recommend Vercel
2. ✅ **Deploy**: Follow steps above
3. ✅ **Update DNS**: Point mindvault.fit to new host
4. ✅ **Test**: Verify everything works
5. ✅ **Monitor**: Set up error tracking
6. ✅ **Optimize**: Run Lighthouse tests

---

## Support

Need help?
- **Vercel**: [vercel.com/support](https://vercel.com/support)
- **Netlify**: [netlify.com/support](https://netlify.com/support)
- **Documentation**: Check platform docs

---

## Summary

**Old Setup (GitHub Pages):**
- ❌ Limited to static sites
- ❌ No SSR support
- ❌ Requires public repository
- ❌ Manual SSL setup
- ❌ No preview deployments

**New Setup (Vercel/Netlify):**
- ✅ Full Next.js support
- ✅ SSR and API routes
- ✅ Works with private repos
- ✅ Automatic SSL
- ✅ Preview deployments
- ✅ Better performance
- ✅ Easier to manage

**Your site will be live at:** `https://mindvault.fit` 🚀

---

*Last Updated: October 2025*

