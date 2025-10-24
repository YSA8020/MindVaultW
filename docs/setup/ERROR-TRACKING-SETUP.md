# 🐛 Error Tracking and Monitoring Setup Guide

This guide will help you set up comprehensive error tracking and monitoring for MindVault.

---

## 🎯 Overview

Error tracking and monitoring provides:
- ✅ **Real-time error alerts** - Get notified immediately when errors occur
- ✅ **Error aggregation** - Group similar errors together
- ✅ **Stack traces** - See exactly where errors occur
- ✅ **User context** - Understand who was affected
- ✅ **Performance monitoring** - Track page load times and API performance
- ✅ **Uptime monitoring** - Ensure your site is always available

---

## 📋 Prerequisites

- Production environment configured
- GitHub repository set up
- Domain configured (mindvault.fit)
- Admin access to Supabase

---

## 🔧 Option 1: Sentry (Recommended)

### Step 1: Create Sentry Account

1. Go to [sentry.io](https://sentry.io)
2. Sign up for a free account
3. Create a new project
4. Select **JavaScript** as the platform
5. Copy your **DSN** (Data Source Name)

### Step 2: Install Sentry SDK

Add to your HTML files (before closing `</head>`):

```html
<!-- Sentry SDK -->
<script src="https://browser.sentry-cdn.com/7.83.0/bundle.min.js"></script>
```

### Step 3: Initialize Sentry

Create `js/error-tracking.js`:

```javascript
/**
 * MindVault Error Tracking with Sentry
 */

// Initialize Sentry
if (typeof Sentry !== 'undefined') {
    Sentry.init({
        dsn: 'YOUR_SENTRY_DSN_HERE',
        environment: 'production',
        release: '1.0.0',
        
        // Performance monitoring
        tracesSampleRate: 0.1, // 10% of transactions
        tracePropagationTargets: ['localhost', /^https:\/\/mindvault\.fit/],
        
        // Session replay (optional)
        replaysSessionSampleRate: 0.1,
        replaysOnErrorSampleRate: 1.0,
        
        // User context
        beforeSend(event, hint) {
            // Add user information if available
            const user = window.supabaseClient?.auth?.user();
            if (user) {
                event.user = {
                    id: user.id,
                    email: user.email,
                };
            }
            
            // Filter out development errors
            if (event.environment === 'development') {
                return null;
            }
            
            return event;
        },
        
        // Ignore certain errors
        ignoreErrors: [
            // Browser extensions
            'top.GLOBALS',
            'originalCreateNotification',
            'canvas.contentDocument',
            'MyApp_RemoveAllHighlights',
            'atomicFindClose',
            
            // Network errors
            'Network request failed',
            'Failed to fetch',
            
            // Third-party scripts
            'Script error',
        ],
        
        // Custom tags
        tags: {
            component: 'mindvault-frontend',
        },
        
        // Additional options
        debug: false,
        maxBreadcrumbs: 50,
        attachStacktrace: true,
    });
    
    // Set user context
    function setUserContext(user) {
        if (user) {
            Sentry.setUser({
                id: user.id,
                email: user.email,
                username: user.user_metadata?.full_name || user.email,
            });
        } else {
            Sentry.setUser(null);
        }
    }
    
    // Listen for auth state changes
    if (window.supabaseClient) {
        window.supabaseClient.auth.onAuthStateChange((event, session) => {
            if (session?.user) {
                setUserContext(session.user);
            } else {
                Sentry.setUser(null);
            }
        });
    }
    
    // Add breadcrumbs for user actions
    document.addEventListener('click', (event) => {
        Sentry.addBreadcrumb({
            category: 'ui.click',
            message: `Clicked ${event.target.tagName}`,
            level: 'info',
        });
    });
    
    // Add breadcrumbs for navigation
    window.addEventListener('popstate', () => {
        Sentry.addBreadcrumb({
            category: 'navigation',
            message: `Navigated to ${window.location.pathname}`,
            level: 'info',
        });
    });
    
    console.log('✅ Sentry error tracking initialized');
}

// Export for use in other modules
window.errorTracking = {
    captureException: (error, context) => {
        if (typeof Sentry !== 'undefined') {
            Sentry.captureException(error, context);
        }
        console.error('Error captured:', error, context);
    },
    
    captureMessage: (message, level = 'info') => {
        if (typeof Sentry !== 'undefined') {
            Sentry.captureMessage(message, level);
        }
        console.log(`[${level}]`, message);
    },
    
    setContext: (name, context) => {
        if (typeof Sentry !== 'undefined') {
            Sentry.setContext(name, context);
        }
    },
    
    addBreadcrumb: (breadcrumb) => {
        if (typeof Sentry !== 'undefined') {
            Sentry.addBreadcrumb(breadcrumb);
        }
    },
};
```

### Step 4: Integrate into Your App

Add to all HTML files (before closing `</body>`):

```html
<!-- Error Tracking -->
<script src="js/error-tracking.js?v=1"></script>
```

### Step 5: Test Error Tracking

```javascript
// Test error tracking
try {
    throw new Error('Test error for Sentry');
} catch (error) {
    window.errorTracking.captureException(error, {
        tags: { test: true },
        extra: { page: 'test' }
    });
}

// Test message tracking
window.errorTracking.captureMessage('Test message', 'info');
```

---

## 🔧 Option 2: Rollbar

### Step 1: Create Rollbar Account

1. Go to [rollbar.com](https://rollbar.com)
2. Sign up for a free account
3. Create a new project
4. Select **JavaScript** as the platform
5. Copy your **Client Access Token**

### Step 2: Install Rollbar SDK

Add to your HTML files:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/rollbar.js/2.26.2/rollbar.min.js"></script>
```

### Step 3: Initialize Rollbar

Create `js/error-tracking.js`:

```javascript
/**
 * MindVault Error Tracking with Rollbar
 */

// Initialize Rollbar
if (typeof Rollbar !== 'undefined') {
    Rollbar.init({
        accessToken: 'YOUR_ROLLBAR_ACCESS_TOKEN_HERE',
        environment: 'production',
        captureUncaught: true,
        captureUnhandledRejections: true,
        payload: {
            client: {
                javascript: {
                    source_map_enabled: true,
                    code_version: '1.0.0',
                }
            }
        },
        transform: (payload) => {
            // Add user information if available
            const user = window.supabaseClient?.auth?.user();
            if (user) {
                payload.person = {
                    id: user.id,
                    email: user.email,
                    username: user.user_metadata?.full_name || user.email,
                };
            }
            return payload;
        },
    });
    
    console.log('✅ Rollbar error tracking initialized');
}

// Export for use in other modules
window.errorTracking = {
    captureException: (error, context) => {
        if (typeof Rollbar !== 'undefined') {
            Rollbar.error(error, context);
        }
        console.error('Error captured:', error, context);
    },
    
    captureMessage: (message, level = 'info') => {
        if (typeof Rollbar !== 'undefined') {
            Rollbar[level](message);
        }
        console.log(`[${level}]`, message);
    },
    
    setContext: (name, context) => {
        if (typeof Rollbar !== 'undefined') {
            Rollbar.configure({ payload: { [name]: context } });
        }
    },
};
```

---

## 🔧 Option 3: LogRocket

### Step 1: Create LogRocket Account

1. Go to [logrocket.com](https://logrocket.com)
2. Sign up for a free account
3. Create a new project
4. Copy your **App ID**

### Step 2: Install LogRocket SDK

Add to your HTML files:

```html
<script src="https://cdn.logrocket.io/LogRocket.min.js"></script>
```

### Step 3: Initialize LogRocket

```javascript
// Initialize LogRocket
if (typeof LogRocket !== 'undefined') {
    LogRocket.init('YOUR_APP_ID_HERE', {
        dom: {
            textSanitizer: true,
            inputSanitizer: true,
        },
        network: {
            requestSanitizer: (request) => {
                // Remove sensitive data
                if (request.headers) {
                    delete request.headers['Authorization'];
                }
                return request;
            },
        },
    });
    
    // Identify user
    if (window.supabaseClient) {
        window.supabaseClient.auth.onAuthStateChange((event, session) => {
            if (session?.user) {
                LogRocket.identify(session.user.id, {
                    email: session.user.email,
                    name: session.user.user_metadata?.full_name,
                });
            }
        });
    }
    
    console.log('✅ LogRocket session replay initialized');
}
```

---

## 📊 Uptime Monitoring

### UptimeRobot (Free)

1. **Create Account**
   - Go to [uptimerobot.com](https://uptimerobot.com)
   - Sign up for a free account

2. **Add Monitor**
   - Click **Add New Monitor**
   - Monitor Type: **HTTP(s)**
   - Friendly Name: `MindVault Production`
   - URL: `https://mindvault.fit`
   - Monitoring Interval: **5 minutes**
   - Alert Contacts: Add your email

3. **Configure Alerts**
   - Set up email alerts for downtime
   - Set up SMS alerts (optional)
   - Set up webhook alerts for Slack/Discord

### Pingdom (Paid)

1. **Create Account**
   - Go to [pingdom.com](https://pingdom.com)
   - Sign up for a paid account

2. **Add Check**
   - Click **Add Check**
   - Check Type: **HTTP**
   - URL: `https://mindvault.fit`
   - Check Interval: **1 minute**
   - Alert Contacts: Configure

---

## 📈 Performance Monitoring

### Google Analytics 4

Already configured! Track performance metrics:

```javascript
// Track page load time
window.addEventListener('load', () => {
    const perfData = performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
    
    gtag('event', 'page_load_time', {
        value: pageLoadTime,
        metric_name: 'page_load_time_ms',
        page_path: window.location.pathname
    });
});

// Track API response time
async function trackAPICall(endpoint, responseTime) {
    gtag('event', 'api_call', {
        endpoint: endpoint,
        response_time: responseTime,
        metric_name: 'api_response_time_ms'
    });
}
```

### Custom Performance Monitoring

Create `js/performance-monitoring.js`:

```javascript
/**
 * MindVault Performance Monitoring
 */

class PerformanceMonitor {
    constructor() {
        this.metrics = [];
        this.observer = null;
    }
    
    init() {
        // Monitor page load performance
        this.monitorPageLoad();
        
        // Monitor resource loading
        this.monitorResources();
        
        // Monitor long tasks
        this.monitorLongTasks();
        
        // Monitor memory usage
        this.monitorMemory();
        
        console.log('✅ Performance monitoring initialized');
    }
    
    monitorPageLoad() {
        window.addEventListener('load', () => {
            const perfData = performance.timing;
            
            const metrics = {
                dns: perfData.domainLookupEnd - perfData.domainLookupStart,
                tcp: perfData.connectEnd - perfData.connectStart,
                request: perfData.responseStart - perfData.requestStart,
                response: perfData.responseEnd - perfData.responseStart,
                dom: perfData.domComplete - perfData.domLoading,
                load: perfData.loadEventEnd - perfData.navigationStart,
            };
            
            this.logMetrics('page_load', metrics);
            
            // Send to analytics
            if (window.gtag) {
                Object.entries(metrics).forEach(([key, value]) => {
                    gtag('event', 'performance_metric', {
                        metric_name: key,
                        value: value,
                        page_path: window.location.pathname
                    });
                });
            }
        });
    }
    
    monitorResources() {
        const observer = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
                if (entry.duration > 1000) { // Log resources taking > 1s
                    this.logMetrics('slow_resource', {
                        name: entry.name,
                        duration: entry.duration,
                        size: entry.transferSize,
                        type: entry.initiatorType
                    });
                }
            }
        });
        
        observer.observe({ entryTypes: ['resource'] });
    }
    
    monitorLongTasks() {
        if ('PerformanceObserver' in window) {
            const observer = new PerformanceObserver((list) => {
                for (const entry of list.getEntries()) {
                    if (entry.duration > 50) { // Log tasks > 50ms
                        this.logMetrics('long_task', {
                            duration: entry.duration,
                            startTime: entry.startTime
                        });
                    }
                }
            });
            
            observer.observe({ entryTypes: ['longtask'] });
        }
    }
    
    monitorMemory() {
        if ('memory' in performance) {
            setInterval(() => {
                const memory = performance.memory;
                this.logMetrics('memory_usage', {
                    used: memory.usedJSHeapSize,
                    total: memory.totalJSHeapSize,
                    limit: memory.jsHeapSizeLimit
                });
            }, 60000); // Every minute
        }
    }
    
    logMetrics(type, data) {
        const metric = {
            type,
            data,
            timestamp: Date.now(),
            page: window.location.pathname
        };
        
        this.metrics.push(metric);
        
        // Send to error tracking
        if (window.errorTracking && type === 'long_task') {
            window.errorTracking.captureMessage('Long task detected', 'warning', {
                extra: data
            });
        }
        
        console.log('[Performance]', type, data);
    }
    
    getMetrics() {
        return this.metrics;
    }
}

// Initialize performance monitoring
const perfMonitor = new PerformanceMonitor();
perfMonitor.init();

window.performanceMonitor = perfMonitor;
```

---

## 🔔 Alert Configuration

### Email Alerts

Configure email alerts in your error tracking service:

1. **Sentry**
   - Go to **Settings** → **Alerts**
   - Create alert rules
   - Configure email notifications

2. **Rollbar**
   - Go to **Settings** → **Notifications**
   - Add email addresses
   - Configure alert thresholds

### Slack/Discord Integration

Configure webhooks for real-time alerts:

1. **Create Webhook URL**
   - Slack: Create incoming webhook
   - Discord: Create webhook in channel settings

2. **Configure in Error Tracking**
   - Add webhook URL
   - Set alert conditions
   - Test webhook

---

## 📊 Dashboard Setup

### Create Monitoring Dashboard

Create `monitoring-dashboard.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitoring Dashboard - MindVault</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <div class="container mx-auto p-8">
        <h1 class="text-3xl font-bold mb-8">Monitoring Dashboard</h1>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <!-- Uptime Status -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-semibold mb-4">Uptime Status</h2>
                <div class="text-4xl font-bold text-green-600">99.9%</div>
                <p class="text-gray-600 mt-2">Last 30 days</p>
            </div>
            
            <!-- Error Rate -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-semibold mb-4">Error Rate</h2>
                <div class="text-4xl font-bold text-red-600">0.1%</div>
                <p class="text-gray-600 mt-2">Last 24 hours</p>
            </div>
            
            <!-- Response Time -->
            <div class="bg-white p-6 rounded-lg shadow">
                <h2 class="text-xl font-semibold mb-4">Avg Response Time</h2>
                <div class="text-4xl font-bold text-blue-600">120ms</div>
                <p class="text-gray-600 mt-2">Last hour</p>
            </div>
        </div>
        
        <!-- Recent Errors -->
        <div class="bg-white p-6 rounded-lg shadow">
            <h2 class="text-xl font-semibold mb-4">Recent Errors</h2>
            <div id="errors-list">
                <p class="text-gray-600">No errors in the last 24 hours</p>
            </div>
        </div>
    </div>
    
    <script src="js/performance-monitoring.js"></script>
    <script>
        // Fetch and display recent errors
        async function loadRecentErrors() {
            // This would fetch from your error tracking service
            // For now, just display a placeholder
            console.log('Loading recent errors...');
        }
        
        loadRecentErrors();
        setInterval(loadRecentErrors, 60000); // Refresh every minute
    </script>
</body>
</html>
```

---

## 🧪 Testing

### Test Error Tracking

```javascript
// Test 1: Uncaught exception
throw new Error('Test uncaught exception');

// Test 2: Caught exception
try {
    throw new Error('Test caught exception');
} catch (error) {
    window.errorTracking.captureException(error);
}

// Test 3: Async error
Promise.reject(new Error('Test async error'));

// Test 4: Custom message
window.errorTracking.captureMessage('Test message', 'info');
```

### Test Performance Monitoring

```javascript
// Check if performance monitoring is working
console.log('Performance metrics:', window.performanceMonitor.getMetrics());
```

---

## 📞 Support

If you encounter issues:

1. Check error tracking service documentation
2. Verify DSN/Access Token is correct
3. Check browser console for errors
4. Test with sample errors
5. Contact service support

---

## 🎉 Success Checklist

- [ ] Error tracking service configured
- [ ] SDK installed and initialized
- [ ] User context tracking set up
- [ ] Breadcrumbs configured
- [ ] Uptime monitoring configured
- [ ] Performance monitoring enabled
- [ ] Alerts configured
- [ ] Dashboard created
- [ ] Testing completed
- [ ] Documentation reviewed

---

**Congratulations!** Your error tracking and monitoring is now set up! 🎊

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

