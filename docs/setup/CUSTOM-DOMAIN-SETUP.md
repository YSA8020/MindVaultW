# 🌐 Custom Domain Setup Guide for MindVault

This guide will help you configure the custom domain `mindvault.fit` for your GitHub Pages deployment.

---

## 🎯 Overview

Setting up a custom domain for GitHub Pages involves:
1. Configuring DNS records in your domain registrar (GoDaddy, Namecheap, etc.)
2. Adding the custom domain to your GitHub repository
3. Enabling HTTPS/SSL
4. Verifying the configuration

---

## 📋 Prerequisites

- Domain purchased (mindvault.fit)
- Access to domain registrar account
- GitHub repository with GitHub Pages enabled
- Repository admin access

---

## 🔧 Step-by-Step Setup

### Part 1: Configure DNS Records

#### For GoDaddy

1. **Log in to GoDaddy**
   - Go to [godaddy.com](https://godaddy.com)
   - Navigate to **My Products** → **Domains**
   - Find `mindvault.fit` and click **DNS**

2. **Add A Records for GitHub Pages**
   
   GitHub Pages requires specific IP addresses. Add these A records:

   ```
   Type: A
   Name: @
   Value: 185.199.108.153
   TTL: 600 seconds (10 minutes)
   
   Type: A
   Name: @
   Value: 185.199.109.153
   TTL: 600 seconds (10 minutes)
   
   Type: A
   Name: @
   Value: 185.199.110.153
   TTL: 600 seconds (10 minutes)
   
   Type: A
   Name: @
   Value: 185.199.111.153
   TTL: 600 seconds (10 minutes)
   ```

3. **Add CNAME Record for www**
   
   ```
   Type: CNAME
   Name: www
   Value: your-username.github.io
   TTL: 600 seconds (10 minutes)
   ```

4. **Remove conflicting records**
   - Delete any existing A records pointing to other IPs
   - Delete any existing CNAME records for the root domain (@)

5. **Save Changes**
   - Click **Save** after adding each record
   - Wait 10-15 minutes for DNS propagation

#### For Namecheap

1. **Log in to Namecheap**
   - Go to [namecheap.com](https://namecheap.com)
   - Navigate to **Domain List**
   - Find `mindvault.fit` and click **Manage**

2. **Go to Advanced DNS**
   - Click **Advanced DNS** tab
   - Scroll to **Host Records**

3. **Add A Records**
   
   ```
   Type: A Record
   Host: @
   Value: 185.199.108.153
   TTL: Automatic
   
   Type: A Record
   Host: @
   Value: 185.199.109.153
   TTL: Automatic
   
   Type: A Record
   Host: @
   Value: 185.199.110.153
   TTL: Automatic
   
   Type: A Record
   Host: @
   Value: 185.199.111.153
   TTL: Automatic
   ```

4. **Add CNAME Record**
   
   ```
   Type: CNAME Record
   Host: www
   Value: your-username.github.io
   TTL: Automatic
   ```

5. **Save Changes**
   - Click the checkmark to save each record
   - Wait for DNS propagation

#### For Other Registrars

The process is similar:
1. Find DNS management section
2. Add the four A records with GitHub Pages IPs
3. Add CNAME record for www subdomain
4. Save and wait for propagation

---

### Part 2: Configure GitHub Pages

#### Step 1: Add Custom Domain to Repository

1. **Go to Repository Settings**
   - Navigate to your repository on GitHub
   - Click **Settings** tab
   - Scroll to **Pages** section

2. **Add Custom Domain**
   - Under **Custom domain**, enter: `mindvault.fit`
   - Click **Save**

3. **Verify DNS Configuration**
   - GitHub will check your DNS records
   - You may see a warning initially (DNS propagation takes time)
   - Wait 10-60 minutes for DNS to propagate

#### Step 2: Enable HTTPS

1. **Wait for DNS Verification**
   - Once DNS is verified, GitHub will show a green checkmark
   - This may take up to 24 hours

2. **Enable Enforce HTTPS**
   - Check the **Enforce HTTPS** checkbox
   - GitHub will automatically provision an SSL certificate

3. **Verify SSL Certificate**
   - Visit `https://mindvault.fit`
   - You should see a secure padlock in the browser
   - No security warnings

#### Step 3: Update Repository Files

1. **Create CNAME File**
   
   Create a file named `CNAME` (no extension) in your repository root:
   
   ```
   mindvault.fit
   ```

2. **Update .nojekyll File**
   
   Ensure `.nojekyll` exists in your repository root (empty file).

3. **Commit and Push**
   
   ```bash
   git add CNAME .nojekyll
   git commit -m "Add custom domain configuration"
   git push origin main
   ```

---

### Part 3: Verify Configuration

#### Test DNS Records

Use online DNS checkers to verify your DNS configuration:

1. **MXToolbox DNS Lookup**
   - Go to [mxtoolbox.com/SuperTool.aspx](https://mxtoolbox.com/SuperTool.aspx)
   - Enter `mindvault.fit`
   - Select **A Record**
   - Click **MX Lookup**
   - Verify all four GitHub IPs are listed

2. **What's My DNS**
   - Go to [whatsmydns.net](https://whatsmydns.net)
   - Enter `mindvault.fit`
   - Select **A** record type
   - Check propagation globally

#### Test Domain Access

1. **Visit Your Domain**
   - Open browser
   - Navigate to `http://mindvault.fit`
   - Should redirect to `https://mindvault.fit`

2. **Test www Subdomain**
   - Navigate to `https://www.mindvault.fit`
   - Should work and redirect to `https://mindvault.fit`

3. **Check SSL Certificate**
   - Click the padlock icon in browser
   - Verify certificate is valid
   - Check expiration date

---

## 🔧 Advanced Configuration

### Redirect www to Non-www

To redirect `www.mindvault.fit` to `mindvault.fit`:

1. **Update CNAME File**
   
   ```
   mindvault.fit
   ```

2. **Add Redirect in HTML**
   
   Add this to your `index.html` `<head>` section:
   
   ```html
   <script>
       if (window.location.hostname === 'www.mindvault.fit') {
           window.location.href = 'https://mindvault.fit' + window.location.pathname;
       }
   </script>
   ```

### Custom 404 Page

Create a custom 404 page:

1. **Create 404.html**
   
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>404 - Page Not Found | MindVault</title>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
   </head>
   <body>
       <h1>404 - Page Not Found</h1>
       <p>The page you're looking for doesn't exist.</p>
       <a href="/">Go Home</a>
   </body>
   </html>
   ```

2. **Commit and Push**
   
   ```bash
   git add 404.html
   git commit -m "Add custom 404 page"
   git push origin main
   ```

### Email Configuration

For email services (SendGrid, Mailgun), you may need to add additional DNS records:

#### SPF Record
```
Type: TXT
Name: @
Value: v=spf1 include:_spf.mx.cloudflare.net ~all
```

#### DKIM Record
```
Type: TXT
Name: mail._domainkey
Value: (provided by your email service)
```

#### DMARC Record
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:dmarc@mindvault.fit
```

---

## 🛠️ Troubleshooting

### Issue: Domain not resolving

**Symptoms:**
- Browser shows "This site can't be reached"
- DNS lookup fails

**Solutions:**
1. Check DNS records are correct
2. Wait for DNS propagation (up to 48 hours)
3. Clear DNS cache:
   ```bash
   # Windows
   ipconfig /flushdns
   
   # Mac/Linux
   sudo dscacheutil -flushcache
   ```
4. Try different DNS servers (8.8.8.8, 1.1.1.1)

### Issue: SSL certificate not working

**Symptoms:**
- Browser shows "Not Secure"
- SSL certificate error

**Solutions:**
1. Ensure DNS is fully propagated
2. Check **Enforce HTTPS** is enabled in GitHub
3. Wait up to 24 hours for SSL provisioning
4. Clear browser cache and cookies
5. Try incognito/private browsing mode

### Issue: www subdomain not working

**Symptoms:**
- `www.mindvault.fit` doesn't load
- DNS error for www subdomain

**Solutions:**
1. Verify CNAME record for www is correct
2. Ensure it points to `your-username.github.io`
3. Wait for DNS propagation
4. Check GitHub Pages settings for www subdomain

### Issue: Mixed content warnings

**Symptoms:**
- Browser shows "Mixed content" warning
- Some resources load over HTTP instead of HTTPS

**Solutions:**
1. Update all URLs to use HTTPS
2. Use protocol-relative URLs (`//example.com`)
3. Check external resources (fonts, images, scripts)
4. Use browser DevTools to find HTTP resources

### Issue: GitHub Pages not updating

**Symptoms:**
- Changes not reflected on live site
- Old content still showing

**Solutions:**
1. Verify changes are pushed to main branch
2. Check GitHub Actions for build errors
3. Clear browser cache (Ctrl+Shift+R)
4. Wait 5-10 minutes for GitHub to rebuild
5. Check repository settings → Pages → Source branch

---

## 📊 DNS Propagation Time

DNS changes can take time to propagate globally:

| Timeframe | Status |
|-----------|--------|
| 0-10 minutes | Local changes visible |
| 10-30 minutes | Regional propagation |
| 30-60 minutes | Most locations updated |
| 1-24 hours | Full global propagation |
| Up to 48 hours | Maximum propagation time |

**Note:** Some DNS servers cache records for up to 48 hours (TTL). Be patient!

---

## 🔒 Security Best Practices

1. **Always Use HTTPS**
   - Enable **Enforce HTTPS** in GitHub Pages
   - Never serve content over HTTP
   - Use secure cookies and sessions

2. **Keep DNS Records Updated**
   - Monitor DNS records regularly
   - Update IPs if GitHub changes them
   - Use short TTL during changes (600 seconds)

3. **Enable DNSSEC**
   - Add DNSSEC to your domain
   - Prevents DNS spoofing
   - Available in most registrars

4. **Monitor SSL Certificate**
   - Check certificate expiration
   - GitHub auto-renews, but monitor anyway
   - Set up alerts for certificate issues

5. **Use Security Headers**
   - Add security headers to your site
   - Use GitHub Pages headers feature
   - Implement Content Security Policy

---

## 📈 Monitoring

### Check Domain Health

Use these tools to monitor your domain:

1. **Uptime Monitoring**
   - [UptimeRobot](https://uptimerobot.com)
   - [Pingdom](https://pingdom.com)
   - [StatusCake](https://statuscake.com)

2. **SSL Monitoring**
   - [SSL Labs](https://www.ssllabs.com/ssltest/)
   - Enter your domain for SSL analysis
   - Check certificate grade

3. **DNS Monitoring**
   - [DNS Checker](https://dnschecker.org)
   - Check global DNS propagation
   - Monitor record changes

---

## 🎉 Success Checklist

- [ ] DNS A records added (4 records)
- [ ] DNS CNAME record added (www)
- [ ] Custom domain added to GitHub Pages
- [ ] DNS verification successful (green checkmark)
- [ ] HTTPS enabled and enforced
- [ ] SSL certificate valid
- [ ] Domain accessible at https://mindvault.fit
- [ ] www subdomain working
- [ ] No security warnings
- [ ] Custom 404 page working
- [ ] Email DNS records added (if needed)
- [ ] DNS propagation complete globally
- [ ] Monitoring set up

---

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section
2. Verify DNS records with online tools
3. Check GitHub Pages documentation
4. Contact your domain registrar support
5. Check GitHub Community forums

---

## 🔗 Useful Links

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Custom Domain Setup](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [DNS Checker](https://dnschecker.org)
- [SSL Labs](https://www.ssllabs.com/ssltest/)
- [MXToolbox](https://mxtoolbox.com)

---

**Congratulations!** Your custom domain is now configured! 🎊

Visit your site at: **https://mindvault.fit**

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

