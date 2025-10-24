# ⚙️ Production Environment Setup Guide

This guide will help you configure your production environment for MindVault.

---

## 🎯 Overview

Setting up a production environment involves:
1. Environment variables configuration
2. API keys and secrets management
3. Database connection settings
4. Third-party service integrations
5. Security hardening
6. Performance optimization

---

## 📋 Prerequisites

- Supabase project deployed
- GitHub repository set up
- Domain configured (mindvault.fit)
- Email service account (SendGrid/Mailgun)
- Backup storage configured

---

## 🔧 Environment Variables

### Core Configuration

Create a `js/config.js` file with production settings:

```javascript
// MindVault Production Configuration
const config = {
    // Environment
    environment: 'production',
    debugMode: false,
    
    // Supabase Configuration
    supabase: {
        url: 'https://your-project-ref.supabase.co',
        anonKey: 'your-anon-key-here',
        serviceRoleKey: 'your-service-role-key-here' // Server-side only!
    },
    
    // API Configuration
    api: {
        baseUrl: 'https://mindvault.fit',
        timeout: 30000,
        retryAttempts: 3
    },
    
    // Email Configuration
    email: {
        provider: 'sendgrid', // or 'mailgun', 'ses'
        apiKey: 'your-email-api-key-here',
        fromEmail: 'noreply@mindvault.fit',
        fromName: 'MindVault',
        baseUrl: 'https://api.sendgrid.com/v3' // For Mailgun
    },
    
    // Analytics Configuration
    analytics: {
        gaTrackingId: 'G-V1ZZ3VLV2L',
        trackUserActions: true,
        trackPageViews: true,
        trackErrors: true,
        trackPerformance: true
    },
    
    // Security Configuration
    security: {
        rateLimitRequests: 5,
        rateLimitWindow: 15 * 60 * 1000, // 15 minutes
        maxFailedLogins: 5,
        lockoutDuration: 30 * 60 * 1000, // 30 minutes
        sessionTimeout: 24 * 60 * 60 * 1000, // 24 hours
        requireEmailVerification: true,
        requireStrongPasswords: true
    },
    
    // Backup Configuration
    backup: {
        enabled: true,
        schedule: '0 2 * * *', // 2 AM daily
        retentionDays: 30,
        storageProvider: 'supabase', // or 's3', 'gcs'
        storagePath: 'backups/mindvault'
    },
    
    // Feature Flags
    features: {
        anonymousSharing: true,
        professionalOnboarding: true,
        emergencyResponse: true,
        analyticsDashboard: true,
        backupDashboard: true,
        securityDashboard: true
    },
    
    // External Services
    services: {
        // AWS S3 (for backups)
        aws: {
            accessKeyId: 'your-aws-access-key',
            secretAccessKey: 'your-aws-secret-key',
            region: 'us-east-1',
            bucket: 'mindvault-backups'
        },
        
        // Google Cloud Storage (for backups)
        gcs: {
            projectId: 'your-gcs-project-id',
            bucket: 'mindvault-backups',
            keyFilename: 'path/to/service-account-key.json'
        },
        
        // Error Tracking (Sentry, Rollbar, etc.)
        errorTracking: {
            enabled: true,
            dsn: 'your-error-tracking-dsn',
            environment: 'production'
        },
        
        // Monitoring (New Relic, DataDog, etc.)
        monitoring: {
            enabled: true,
            apiKey: 'your-monitoring-api-key',
            appName: 'mindvault'
        }
    },
    
    // Performance Configuration
    performance: {
        enableCaching: true,
        cacheTTL: 3600, // 1 hour
        enableCompression: true,
        enableCDN: true,
        cdnUrl: 'https://cdn.mindvault.fit'
    },
    
    // Logging Configuration
    logging: {
        level: 'info', // 'debug', 'info', 'warn', 'error'
        enableConsoleLogging: false,
        enableRemoteLogging: true,
        remoteEndpoint: 'https://logs.mindvault.fit/api/logs'
    }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = config;
}

// Global config for browser use
window.config = config;
```

---

## 🔐 Secrets Management

### Never Commit Secrets to Git

Add to `.gitignore`:

```
# Environment variables
.env
.env.local
.env.production

# API keys
js/config.js

# Service account keys
*.json
service-account-*.json

# Secrets
secrets/
*.key
*.pem
```

### Use Environment Variables

For server-side code, use environment variables:

```javascript
// Load from environment
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
```

### GitHub Secrets (for CI/CD)

Add secrets in GitHub repository settings:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `EMAIL_API_KEY`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

---

## 🗄️ Database Configuration

### Production Database Settings

In Supabase dashboard:

1. **Database Settings**
   - Connection pooling: Enabled
   - Max connections: 100
   - Statement timeout: 30 seconds
   - Idle timeout: 10 minutes

2. **Connection String**
   ```
   postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres
   ```

3. **Connection Pooling**
   ```
   postgresql://postgres:[password]@db.[project-ref].supabase.co:6543/postgres
   ```

### Enable Connection Pooling

```javascript
// Use connection pooling for better performance
const supabaseUrl = 'https://your-project-ref.supabase.co';
const supabaseKey = 'your-anon-key';

const supabase = createClient(supabaseUrl, supabaseKey, {
    db: {
        schema: 'public',
    },
    auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
    },
    global: {
        headers: { 'x-client-info': 'mindvault@1.0.0' },
    },
});
```

---

## 📧 Email Service Configuration

### SendGrid Setup

1. **Get API Key**
   - Log in to SendGrid
   - Navigate to **Settings** → **API Keys**
   - Create new API key with **Full Access**
   - Copy the key

2. **Verify Sender**
   - Go to **Settings** → **Sender Authentication**
   - Add `noreply@mindvault.fit`
   - Verify the email address

3. **Configure in Code**
   ```javascript
   email: {
       provider: 'sendgrid',
       apiKey: 'SG.your-api-key-here',
       fromEmail: 'noreply@mindvault.fit',
       fromName: 'MindVault'
   }
   ```

### Mailgun Setup

1. **Get API Key**
   - Log in to Mailgun
   - Navigate to **Settings** → **API Keys**
   - Copy your API key

2. **Verify Domain**
   - Add `mindvault.fit` domain
   - Configure DNS records
   - Wait for verification

3. **Configure in Code**
   ```javascript
   email: {
       provider: 'mailgun',
       apiKey: 'your-mailgun-api-key',
       baseUrl: 'https://api.mailgun.net/v3/mg.mindvault.fit',
       fromEmail: 'noreply@mindvault.fit',
       fromName: 'MindVault'
   }
   ```

---

## 🔒 Security Hardening

### 1. Enable Row Level Security (RLS)

All tables should have RLS enabled:

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
-- ... repeat for all tables
```

### 2. Set Up Rate Limiting

```javascript
// Rate limiting configuration
security: {
    rateLimitRequests: 5,
    rateLimitWindow: 15 * 60 * 1000, // 15 minutes
    maxFailedLogins: 5,
    lockoutDuration: 30 * 60 * 1000 // 30 minutes
}
```

### 3. Enable HTTPS

```javascript
// Force HTTPS in production
if (window.location.protocol !== 'https:' && config.environment === 'production') {
    window.location.href = 'https:' + window.location.href.substring(window.location.protocol.length);
}
```

### 4. Content Security Policy

Add to HTML `<head>`:

```html
<meta http-equiv="Content-Security-Policy" content="
    default-src 'self';
    script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;
    style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
    font-src 'self' https://fonts.gstatic.com;
    img-src 'self' data: https:;
    connect-src 'self' https://your-project-ref.supabase.co;
">
```

### 5. Security Headers

Add to `.htaccess` (if using Apache):

```apache
# Security Headers
Header set X-Content-Type-Options "nosniff"
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"
Header set Referrer-Policy "strict-origin-when-cross-origin"
Header set Permissions-Policy "geolocation=(), microphone=(), camera=()"
```

---

## 📊 Performance Optimization

### 1. Enable Caching

```javascript
// Cache static assets
const cacheVersion = 'v1.0.0';
const cacheName = `mindvault-${cacheVersion}`;

// Service Worker for caching
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js');
}
```

### 2. Enable Compression

For GitHub Pages, add to HTML:

```html
<!-- Preload critical resources -->
<link rel="preload" href="/css/styles.css" as="style">
<link rel="preload" href="/js/app.js" as="script">

<!-- Defer non-critical scripts -->
<script src="/js/analytics.js" defer></script>
```

### 3. Optimize Images

```javascript
// Lazy load images
const images = document.querySelectorAll('img[data-src]');
const imageObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            imageObserver.unobserve(img);
        }
    });
});

images.forEach(img => imageObserver.observe(img));
```

### 4. Database Indexing

Ensure all foreign keys and frequently queried columns are indexed:

```sql
-- Example indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_sessions_client_id ON sessions(client_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_user_id ON user_activity_log(user_id);
```

---

## 🐛 Error Tracking

### Sentry Setup

1. **Create Sentry Account**
   - Go to [sentry.io](https://sentry.io)
   - Create a new project
   - Copy the DSN

2. **Install Sentry SDK**
   ```html
   <script src="https://browser.sentry-cdn.com/7.x.x/bundle.min.js"></script>
   ```

3. **Initialize Sentry**
   ```javascript
   Sentry.init({
       dsn: 'your-sentry-dsn',
       environment: 'production',
       release: '1.0.0',
       tracesSampleRate: 0.1
   });
   ```

### Rollbar Setup

1. **Create Rollbar Account**
   - Go to [rollbar.com](https://rollbar.com)
   - Create a new project
   - Copy the access token

2. **Install Rollbar SDK**
   ```html
   <script src="https://cdnjs.cloudflare.com/ajax/libs/rollbar.js/2.x.x/rollbar.min.js"></script>
   ```

3. **Initialize Rollbar**
   ```javascript
   Rollbar.init({
       accessToken: 'your-rollbar-access-token',
       environment: 'production',
       captureUncaught: true,
       captureUnhandledRejections: true
   });
   ```

---

## 📈 Monitoring

### Uptime Monitoring

Set up uptime monitoring with:

1. **UptimeRobot** (Free)
   - [uptimerobot.com](https://uptimerobot.com)
   - Monitor https://mindvault.fit
   - Alert on downtime

2. **Pingdom** (Paid)
   - [pingdom.com](https://pingdom.com)
   - Advanced monitoring
   - Performance insights

### Performance Monitoring

Use Google Analytics 4 for performance tracking:

```javascript
// Track page load time
window.addEventListener('load', () => {
    const perfData = performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
    
    gtag('event', 'page_load_time', {
        value: pageLoadTime,
        metric_name: 'page_load_time_ms'
    });
});
```

---

## 🧪 Testing

### Pre-Production Checklist

- [ ] All environment variables configured
- [ ] API keys and secrets secured
- [ ] Database connection tested
- [ ] Email service tested
- [ ] HTTPS enabled and working
- [ ] Security headers configured
- [ ] Rate limiting tested
- [ ] Error tracking configured
- [ ] Monitoring set up
- [ ] Backup system tested
- [ ] Performance optimized
- [ ] All features tested
- [ ] Load testing completed
- [ ] Security audit passed

---

## 🚀 Deployment

### Automated Deployment with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
```

---

## 📞 Support

If you encounter issues:

1. Check error logs
2. Review environment variables
3. Test API connections
4. Check monitoring dashboards
5. Review security settings

---

**Congratulations!** Your production environment is now configured! 🎊

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

