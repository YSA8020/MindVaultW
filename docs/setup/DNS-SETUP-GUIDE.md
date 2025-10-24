# DNS Setup Guide for mindvault.fit

## Overview
This guide will help you configure your GoDaddy DNS settings to point your custom domain to GitHub Pages.

## DNS Records to Add in GoDaddy

### Step 1: Log into GoDaddy
1. Go to [godaddy.com](https://godaddy.com)
2. Sign in to your account
3. Go to "My Products" → "Domains"
4. Find `mindvault.fit` and click "Manage"

### Step 2: Access DNS Management
1. Click on "DNS" tab
2. You'll see the DNS management interface

### Step 3: Add A Records
Add these 4 A records (replace any existing A records):

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 185.199.108.153 | 1 Hour |
| A | @ | 185.199.109.153 | 1 Hour |
| A | @ | 185.199.110.153 | 1 Hour |
| A | @ | 185.199.111.153 | 1 Hour |

### Step 4: Add CNAME Record
Add this CNAME record:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | www | ysa8020.github.io | 1 Hour |

### Step 5: Remove Existing Records
- Delete any existing A records that don't match the ones above
- Delete any existing CNAME records for @ or www

## GitHub Pages Configuration

### Step 1: Enable Custom Domain
1. Go to your GitHub repository: https://github.com/YSA8020/MindVaultW
2. Click "Settings" tab
3. Scroll down to "Pages" section
4. Under "Custom domain", enter: `mindvault.fit`
5. Click "Save"

### Step 2: Enable HTTPS
1. After saving the custom domain, check "Enforce HTTPS"
2. This will enable SSL certificate for your domain

## Verification Steps

### Step 1: Wait for DNS Propagation
- DNS changes can take 24-48 hours to fully propagate
- Usually works within 1-2 hours

### Step 2: Test Your Domain
1. Visit `http://mindvault.fit` - should redirect to your GitHub Pages site
2. Visit `https://mindvault.fit` - should show your site with SSL
3. Visit `http://www.mindvault.fit` - should redirect to `mindvault.fit`

### Step 3: Check GitHub Pages Status
1. Go to repository Settings → Pages
2. You should see "Your site is published at https://mindvault.fit"

## Troubleshooting

### If Domain Doesn't Work:
1. **Check DNS propagation**: Use [whatsmydns.net](https://www.whatsmydns.net) to check if DNS has propagated
2. **Verify DNS records**: Make sure all 4 A records are correct
3. **Check GitHub Pages**: Ensure custom domain is set in repository settings
4. **Wait longer**: DNS can take up to 48 hours to fully propagate

### Common Issues:
- **"Site not found"**: DNS hasn't propagated yet, wait 1-2 hours
- **"Not secure"**: HTTPS enforcement might not be enabled
- **Redirect loops**: Check for conflicting DNS records

## Support
If you encounter issues:
1. Check GitHub Pages documentation
2. Verify DNS records are correct
3. Wait for DNS propagation
4. Contact support if needed

## Next Steps
Once your domain is working:
1. Test all pages on the custom domain
2. Update any hardcoded URLs in your code
3. Set up analytics tracking
4. Configure email notifications
