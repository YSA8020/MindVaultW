# Migration from GitHub Pages to Vercel/Netlify

## Why Migrate?

GitHub Pages has the following limitations for this project:

1. **No Server-Side Rendering** - Next.js SSR features won't work
2. **Static Only** - No API routes or dynamic functionality
3. **Private Repo Restrictions** - Requires public repository for free tier
4. **No Environment Variables** - Can't securely store API keys
5. **Limited Build Options** - No custom build configurations
6. **No Preview Deployments** - Can't test before going live

## Migration Checklist

### ☑️ Pre-Migration

- [x] Project refactored to Next.js
- [x] Removed GitHub Pages configuration (`CNAME`, `deploy.sh`, `deploy.bat`)
- [x] Removed `gh-pages` dependency
- [x] Created `vercel.json` configuration
- [x] Created `netlify.toml` configuration
- [x] Updated `package.json` scripts
- [ ] Choose new hosting platform (Vercel recommended)

### ☑️ During Migration

- [ ] Deploy to new platform
- [ ] Configure environment variables
- [ ] Test deployment works
- [ ] Update DNS records
- [ ] Verify custom domain works
- [ ] Enable SSL/HTTPS

### ☑️ Post-Migration

- [ ] Remove GitHub Pages from repository settings
- [ ] Delete old deployments
- [ ] Update documentation
- [ ] Test all functionality
- [ ] Monitor for issues

## Quick Migration Steps

### Option 1: Migrate to Vercel (Recommended)

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Login
vercel login

# 3. Deploy
vercel --prod

# 4. In Vercel dashboard:
#    - Add environment variables
#    - Add custom domain: mindvault.fit
#    - Wait for DNS propagation

# 5. Update DNS at your registrar:
#    A record: @ → 76.76.21.21
#    CNAME: www → cname.vercel-dns.com
```

### Option 2: Migrate to Netlify

```bash
# 1. Install Netlify CLI
npm install -g netlify-cli

# 2. Login
netlify login

# 3. Initialize
netlify init

# 4. Deploy
netlify deploy --prod

# 5. In Netlify dashboard:
#    - Add environment variables
#    - Add custom domain: mindvault.fit
#    - Update DNS records as instructed
```

## DNS Changes Required

### Current (GitHub Pages - Remove)

```
Type: A
Name: @
Value: 185.199.108.153
       185.199.109.153
       185.199.110.153
       185.199.111.153

Type: CNAME
Name: www
Value: yourusername.github.io
```

### New (Vercel - Add)

```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### New (Netlify - Alternative)

```
Type: A
Name: @
Value: 75.2.60.5

Type: CNAME
Name: www
Value: your-site.netlify.app
```

## DNS Propagation

After updating DNS:
- **Wait time:** 5 minutes to 48 hours (typically 15-30 minutes)
- **Check status:** https://dnschecker.org/
- **Clear cache:** Use incognito mode to test

## Environment Variables to Set

On your new platform (Vercel/Netlify), add:

```env
NEXT_PUBLIC_SUPABASE_URL=https://swacnbyayimigfzgzgvm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-V1ZZ3VLV2L
NODE_ENV=production
```

## Cleanup Old GitHub Pages Setup

### 1. In Repository Settings

1. Go to **Settings** → **Pages**
2. Set source to **None**
3. Remove custom domain

### 2. Delete Old Branch (if using gh-pages)

```bash
# Delete locally
git branch -D gh-pages

# Delete remotely
git push origin --delete gh-pages
```

### 3. Remove Old Files (Already Done)

- ✅ Deleted `CNAME`
- ✅ Deleted `deploy.sh`
- ✅ Deleted `deploy.bat`
- ✅ Removed `gh-pages` from package.json

## Verification Steps

After migration, verify:

1. **Site Loads**
   ```bash
   curl https://mindvault.fit
   ```

2. **SSL Active**
   - Visit https://mindvault.fit
   - Check for green padlock

3. **All Routes Work**
   - Test `/login`
   - Test `/signup`
   - Test `/dashboard`

4. **Environment Variables**
   - Database connection works
   - No console errors

5. **Performance**
   ```bash
   npx lighthouse https://mindvault.fit
   ```

## Rollback Plan

If migration fails:

1. **Restore DNS to GitHub Pages**
   ```
   A record: @ → 185.199.108.153
   CNAME: www → yourusername.github.io
   ```

2. **Restore CNAME file**
   ```bash
   echo "mindvault.fit" > CNAME
   ```

3. **Redeploy to GitHub Pages**
   ```bash
   npm install gh-pages
   # Add back deploy script
   npm run deploy
   ```

## Benefits After Migration

✅ **Server-Side Rendering** - Full Next.js functionality
✅ **API Routes** - Backend endpoints supported
✅ **Environment Variables** - Secure credential storage
✅ **Preview Deployments** - Test before production
✅ **Automatic HTTPS** - SSL certificates included
✅ **Better Performance** - Edge network optimization
✅ **Private Repository** - No need to make repo public
✅ **Zero Config** - Automatic Next.js detection
✅ **Built-in Monitoring** - Real-time logs and analytics

## Timeline

**Estimated Migration Time:**
- Setup: 15 minutes
- DNS Propagation: 15-60 minutes
- Testing: 30 minutes
- **Total: ~2 hours**

## Common Issues & Solutions

### Issue: Site not loading after DNS change

**Solution:**
- Wait for DNS propagation (up to 48 hours)
- Clear browser cache
- Try different browser/incognito mode
- Check DNS with: `nslookup mindvault.fit`

### Issue: Environment variables not working

**Solution:**
- Verify they're set in platform dashboard
- Check variable names are exact
- Ensure they start with `NEXT_PUBLIC_`
- Redeploy after adding variables

### Issue: 404 errors on routes

**Solution:**
- Ensure using Vercel/Netlify (not static export)
- Check `next.config.js` doesn't have `output: 'export'`
- Verify redirects are configured

## Support Resources

- **Vercel Docs:** https://vercel.com/docs
- **Netlify Docs:** https://docs.netlify.com
- **DNS Help:** https://dnschecker.org
- **SSL Check:** https://www.ssllabs.com/ssltest/

## Migration Complete Checklist

- [ ] Old deployment stopped
- [ ] New platform configured
- [ ] Environment variables set
- [ ] DNS records updated
- [ ] Custom domain verified
- [ ] SSL certificate active
- [ ] Site loads correctly
- [ ] All features tested
- [ ] Monitoring enabled
- [ ] Documentation updated
- [ ] Team notified
- [ ] Old resources cleaned up

---

**Status:** Ready to migrate from GitHub Pages to Vercel/Netlify

**Recommended Platform:** Vercel (best for Next.js)

**Estimated Downtime:** < 5 minutes (during DNS switch)

---

*See [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) for detailed instructions*

