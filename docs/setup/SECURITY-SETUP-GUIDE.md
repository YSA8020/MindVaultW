# 🔒 Security & Rate Limiting Setup Guide

## Overview

This guide covers the comprehensive security and rate limiting system for MindVault, including protection against abuse, malicious activity, and unauthorized access.

## Table of Contents

1. [Database Setup](#database-setup)
2. [Rate Limiting Configuration](#rate-limiting-configuration)
3. [Security Features](#security-features)
4. [Monitoring & Alerts](#monitoring--alerts)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Database Setup

### Step 1: Create Security Tables

Run the `rate-limiting-table.sql` script in your Supabase SQL Editor:

```sql
-- This creates:
-- - rate_limits: Track API request rates
-- - failed_login_attempts: Monitor login failures
-- - suspicious_activity: Log security threats
-- - ip_blacklist: Manage blocked IP addresses
-- - user_security_settings: User-specific security config
-- - security_events: Comprehensive event logging
```

### Step 2: Verify Tables

Check that all tables were created successfully:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'rate_limits',
    'failed_login_attempts',
    'suspicious_activity',
    'ip_blacklist',
    'user_security_settings',
    'security_events'
);
```

### Step 3: Test Functions

Verify the security functions are working:

```sql
-- Test rate limiting
SELECT * FROM check_rate_limit('user123', '192.168.1.1', '/api/login', 5, 60);

-- Test failed login logging
SELECT log_failed_login('test@example.com', '192.168.1.1', 'Mozilla/5.0', 'Invalid password');

-- Test security event logging
SELECT log_security_event('user123', 'login', '192.168.1.1', 'Mozilla/5.0', true);
```

---

## Rate Limiting Configuration

### Default Limits

| Endpoint | Max Requests | Window |
|----------|--------------|--------|
| Login | 5 per 15 minutes | 15 min |
| Signup | 3 per hour | 60 min |
| API Calls | 60 per hour | 60 min |
| Password Reset | 3 per hour | 60 min |
| Email Verification | 5 per hour | 60 min |

### Customizing Limits

Edit `js/rate-limiter.js` to customize rate limits:

```javascript
// Set custom rate limits
rateLimiter.setRateLimit(100, 60000); // 100 requests per minute

// Check rate limit before making request
const result = await rateLimiter.checkRateLimit('/api/endpoint', 60, 60000);
if (!result.allowed) {
    console.log('Rate limit exceeded. Try again at:', result.resetTime);
}
```

### Server-Side Rate Limiting

Use Supabase Edge Functions for server-side rate limiting:

```typescript
import { createClient } from '@supabase/supabase-js'

export default async function handler(req: Request) {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    // Check rate limit
    const { data, error } = await supabase.rpc('check_rate_limit', {
        p_user_id: userId,
        p_ip_address: ipAddress,
        p_endpoint: endpoint,
        p_max_requests: 60,
        p_window_minutes: 60
    })
    
    if (!data.allowed) {
        return new Response('Rate limit exceeded', { status: 429 })
    }
    
    // Process request...
}
```

---

## Security Features

### 1. Failed Login Protection

Automatic account locking after multiple failed attempts:

```javascript
// In login.html
async function handleLogin(email, password) {
    // Check if account is locked
    const lockStatus = failedLoginTracker.isAccountLocked(email, ipAddress);
    if (lockStatus && lockStatus.locked) {
        showError(`Account locked. Try again in ${Math.ceil(lockStatus.remainingTime / 60000)} minutes.`);
        return;
    }
    
    try {
        // Attempt login
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        
        if (error) {
            // Log failed attempt
            const result = failedLoginTracker.recordFailedAttempt(email, ipAddress);
            
            // Log to database
            await supabase.rpc('log_failed_login', {
                p_email: email,
                p_ip_address: ipAddress,
                p_user_agent: navigator.userAgent,
                p_reason: error.message
            });
            
            if (result.locked) {
                showError(result.message);
            } else {
                showError(result.message);
            }
        } else {
            // Reset failed attempts on success
            failedLoginTracker.resetAttempts(email, ipAddress);
            
            // Log successful login
            await supabase.rpc('log_security_event', {
                p_user_id: data.user.id,
                p_event_type: 'login',
                p_ip_address: ipAddress,
                p_user_agent: navigator.userAgent,
                p_success: true
            });
        }
    } catch (error) {
        console.error('Login error:', error);
    }
}
```

### 2. IP Blacklisting

Manually or automatically block malicious IPs:

```javascript
// Block IP from security dashboard
async function blockIP(ipAddress, reason) {
    const { data, error } = await supabase
        .from('ip_blacklist')
        .insert([{
            ip_address: ipAddress,
            reason: reason,
            blocked_by: 'admin',
            permanent: true
        }]);
}

// Check if IP is blocked before processing request
async function isIPBlocked(ipAddress) {
    const { data } = await supabase
        .from('ip_blacklist')
        .select('*')
        .eq('ip_address', ipAddress)
        .or('permanent.eq.true,blocked_until.gt.' + new Date().toISOString())
        .single();
    
    return !!data;
}
```

### 3. Suspicious Activity Detection

Automatic detection and logging of suspicious patterns:

```javascript
// Check for suspicious activity patterns
async function detectSuspiciousActivity(userId, ipAddress, activity) {
    // Multiple failed logins
    const { data: failedLogins } = await supabase
        .from('failed_login_attempts')
        .select('*')
        .or(`email.eq.${email},ip_address.eq.${ipAddress}`)
        .gte('attempted_at', new Date(Date.now() - 15 * 60 * 1000).toISOString());
    
    if (failedLogins && failedLogins.length >= 5) {
        // Log suspicious activity
        await supabase.from('suspicious_activity').insert([{
            ip_address: ipAddress,
            activity_type: 'multiple_failed_logins',
            description: 'Multiple failed login attempts detected',
            severity: 'high'
        }]);
        
        // Optionally auto-block IP
        await blockIP(ipAddress, 'Multiple failed login attempts');
    }
}
```

### 4. Security Event Logging

Comprehensive logging of all security events:

```javascript
// Log security event
async function logSecurityEvent(eventType, success, metadata) {
    await supabase.rpc('log_security_event', {
        p_user_id: currentUserId,
        p_event_type: eventType, // 'login', 'logout', 'password_change', etc.
        p_ip_address: getIPAddress(),
        p_user_agent: navigator.userAgent,
        p_success: success,
        p_failure_reason: success ? null : metadata.error,
        p_metadata: metadata
    });
}

// Usage examples
await logSecurityEvent('login', true, { loginMethod: 'email' });
await logSecurityEvent('password_change', true, {});
await logSecurityEvent('suspicious_activity', false, { reason: 'Unusual login location' });
```

---

## Monitoring & Alerts

### Security Dashboard

Access the security dashboard at `/security-dashboard.html` to monitor:

- **Active Threats**: Real-time suspicious activity
- **Failed Logins**: Recent login failures
- **Blocked IPs**: Currently blocked IP addresses
- **Security Events**: Comprehensive event log

### Automated Cleanup

Set up scheduled cleanup jobs to maintain database performance:

```sql
-- Run daily at 2 AM (configure in Supabase Dashboard > Database > Cron Jobs)
SELECT cleanup_old_rate_limits();        -- Cleans rate limits older than 24 hours
SELECT cleanup_old_failed_logins();      -- Cleans failed logins older than 30 days
SELECT cleanup_old_security_events();    -- Cleans security events older than 90 days
```

### Email Alerts

Configure email alerts for critical security events (requires email setup):

```javascript
// Send security alert email
async function sendSecurityAlert(email, subject, message) {
    const { data, error } = await supabase.functions.invoke('send-email', {
        body: {
            to: email,
            subject: subject,
            template: 'security-alert',
            data: {
                message: message,
                timestamp: new Date().toISOString()
            }
        }
    });
}

// Usage
if (suspiciousActivity.severity === 'critical') {
    await sendSecurityAlert(
        'admin@mindvault.fit',
        'Critical Security Alert',
        'High-severity suspicious activity detected'
    );
}
```

---

## Best Practices

### 1. Rate Limiting Strategy

- **Progressive Limits**: Implement stricter limits for unauthenticated users
- **Endpoint-Specific**: Different limits for different endpoints
- **User-Based**: Higher limits for verified users
- **IP-Based**: Fallback rate limiting by IP address

### 2. Security Monitoring

- **Real-Time Alerts**: Set up alerts for critical security events
- **Regular Reviews**: Review security logs weekly
- **Pattern Detection**: Look for unusual access patterns
- **Incident Response**: Have a plan for security incidents

### 3. User Education

- **Strong Passwords**: Enforce password requirements
- **Two-Factor Authentication**: Encourage 2FA for all users
- **Security Tips**: Provide security best practices to users
- **Phishing Awareness**: Educate users about phishing attempts

### 4. Data Protection

- **Encryption**: Use HTTPS for all connections
- **Secure Storage**: Encrypt sensitive data at rest
- **Access Control**: Implement proper RLS policies
- **Audit Logs**: Maintain comprehensive audit trails

---

## Troubleshooting

### Issue: Rate Limiting Not Working

**Symptoms**: Users can make unlimited requests

**Solutions**:
1. Check if `rate-limiter.js` is loaded: `console.log(rateLimiter)`
2. Verify rate limit function exists: `console.log(rateLimiter.checkRateLimit)`
3. Check browser console for errors
4. Ensure Supabase functions are deployed

### Issue: False Positives

**Symptoms**: Legitimate users being blocked

**Solutions**:
1. Adjust rate limits in `js/rate-limiter.js`
2. Review IP blacklist and remove false positives
3. Check suspicious activity logs for patterns
4. Implement user whitelist for trusted users

### Issue: Security Events Not Logging

**Symptoms**: No security events in dashboard

**Solutions**:
1. Verify `security_events` table exists
2. Check RLS policies allow inserts
3. Test function: `SELECT log_security_event(...)`
4. Check browser console for errors

### Issue: IP Blacklist Not Blocking

**Symptoms**: Blocked IPs can still access

**Solutions**:
1. Verify IP address format is correct
2. Check `blocked_until` timestamp is in future
3. Ensure client-side checks are implemented
4. Consider server-side enforcement with Edge Functions

---

## Testing

### Test Rate Limiting

```javascript
// Test rate limiting
async function testRateLimiting() {
    console.log('Testing rate limiting...');
    
    for (let i = 0; i < 10; i++) {
        const result = await rateLimiter.checkRateLimit('/api/test', 5, 60000);
        console.log(`Request ${i + 1}:`, result);
        
        if (!result.allowed) {
            console.log('Rate limit exceeded!');
            break;
        }
    }
}

testRateLimiting();
```

### Test Failed Login Protection

```javascript
// Test failed login tracking
async function testFailedLoginProtection() {
    console.log('Testing failed login protection...');
    
    const email = 'test@example.com';
    const ipAddress = '192.168.1.1';
    
    for (let i = 0; i < 6; i++) {
        const result = failedLoginTracker.recordFailedAttempt(email, ipAddress);
        console.log(`Attempt ${i + 1}:`, result);
        
        if (result.locked) {
            console.log('Account locked!');
            break;
        }
    }
}

testFailedLoginProtection();
```

### Test IP Blacklisting

```javascript
// Test IP blacklisting
async function testIPBlacklisting() {
    console.log('Testing IP blacklisting...');
    
    const ipAddress = '192.168.1.1';
    
    // Block IP
    await blockIP(ipAddress, 'Test blocking');
    console.log('IP blocked');
    
    // Check if blocked
    const isBlocked = await isIPBlocked(ipAddress);
    console.log('Is IP blocked?', isBlocked);
    
    // Unblock IP
    await unblockIP(ipAddress);
    console.log('IP unblocked');
}

testIPBlacklisting();
```

---

## Next Steps

1. ✅ **Database Setup**: Run `rate-limiting-table.sql`
2. ✅ **JavaScript Integration**: Add `js/rate-limiter.js` to all pages
3. ✅ **Security Dashboard**: Access `/security-dashboard.html`
4. ✅ **Testing**: Run test functions to verify setup
5. ✅ **Monitoring**: Set up automated cleanup and alerts
6. ✅ **Documentation**: Train team on security procedures

---

## Support

For issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review the security dashboard for patterns
- Contact the development team
- Review Supabase documentation for RLS and Edge Functions

---

**Security is an ongoing process. Regularly review and update your security measures!** 🔒
