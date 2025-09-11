# MindVault Website Deployment Guide

## Quick Start

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start development server**:
   ```bash
   npm run dev
   ```

3. **Open browser**: http://localhost:3000

## Deployment Options

### Option 1: Vercel (Recommended - Free)

1. **Create Vercel account**: https://vercel.com
2. **Connect GitHub repository**
3. **Deploy automatically** - Vercel will detect Next.js and configure everything

**Benefits**:
- ✅ Free hosting
- ✅ Automatic deployments
- ✅ Custom domain support
- ✅ SSL certificates
- ✅ Global CDN

### Option 2: Netlify (Free)

1. **Create Netlify account**: https://netlify.com
2. **Connect GitHub repository**
3. **Build settings**:
   - Build command: `npm run build`
   - Publish directory: `out`
4. **Deploy**

### Option 3: GitHub Pages (Free)

1. **Install gh-pages**: `npm install --save-dev gh-pages`
2. **Add to package.json**:
   ```json
   "scripts": {
     "deploy": "gh-pages -d out"
   }
   ```
3. **Build and deploy**: `npm run build && npm run deploy`

## Environment Variables

Create a `.env.local` file for any environment-specific settings:

```env
NEXT_PUBLIC_SITE_URL=https://your-domain.com
NEXT_PUBLIC_CONTACT_EMAIL=hello@mindvault.app
```

## Custom Domain Setup

### For Vercel:
1. Go to your project settings
2. Add your domain in "Domains" section
3. Update DNS records as instructed

### For Netlify:
1. Go to Domain settings
2. Add custom domain
3. Configure DNS records

## Analytics Setup

### Google Analytics
Add to `src/pages/_document.tsx`:
```tsx
<Script
  src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"
  strategy="afterInteractive"
/>
<Script id="google-analytics" strategy="afterInteractive">
  {`
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_MEASUREMENT_ID');
  `}
</Script>
```

## Contact Form Setup

The contact form is currently a demo. To make it functional:

1. **Use Formspree** (Free):
   - Sign up at https://formspree.io
   - Get your form endpoint
   - Update the form action in `index.tsx`

2. **Use Netlify Forms**:
   - Add `netlify` attribute to form
   - Forms will appear in Netlify dashboard

3. **Use EmailJS**:
   - Sign up at https://emailjs.com
   - Configure email service
   - Add JavaScript integration

## Performance Optimization

### Image Optimization
- Use Next.js Image component
- Optimize images with tools like TinyPNG
- Use WebP format when possible

### Bundle Analysis
```bash
npm install --save-dev @next/bundle-analyzer
```

### Lighthouse Score
- Aim for 90+ scores
- Use Next.js built-in optimizations
- Minimize third-party scripts

## Security Considerations

- Enable HTTPS (automatic with Vercel/Netlify)
- Use Content Security Policy headers
- Validate all form inputs
- Keep dependencies updated

## Monitoring

### Uptime Monitoring
- UptimeRobot (free)
- Pingdom
- StatusCake

### Error Tracking
- Sentry (free tier)
- LogRocket
- Bugsnag

## Backup Strategy

- Code: GitHub repository
- Content: Version control
- Assets: CDN backup
- Database: Regular exports (if applicable)

## Maintenance

### Regular Tasks
- Update dependencies monthly
- Monitor performance metrics
- Check for broken links
- Review analytics data
- Update content regularly

### Monitoring Checklist
- [ ] Website loads quickly
- [ ] All links work
- [ ] Contact form functions
- [ ] Mobile responsive
- [ ] SEO meta tags present
- [ ] Analytics tracking
- [ ] SSL certificate valid

## Troubleshooting

### Common Issues

**Build fails**:
- Check Node.js version (14+ required)
- Clear `.next` folder
- Reinstall dependencies

**Styling issues**:
- Verify Tailwind CSS is properly configured
- Check for conflicting CSS
- Clear browser cache

**Deployment issues**:
- Check build logs
- Verify environment variables
- Test locally first

## Support

For deployment issues:
- Check platform documentation
- Review build logs
- Contact platform support
- Join community forums

---

**Ready to deploy?** Choose Vercel for the easiest setup! 🚀
