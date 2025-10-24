# 📧 Email Configuration Guide for MindVault

This guide will help you set up email notifications for your MindVault platform.

---

## 🎯 Overview

MindVault supports three email service providers:
1. **SendGrid** (Recommended for ease of use)
2. **Mailgun** (Good for high volume)
3. **Amazon SES** (Most cost-effective for large scale)

---

## 📋 Prerequisites

- A domain email address (e.g., `noreply@mindvault.fit`)
- An account with one of the email service providers
- API credentials from your chosen provider

---

## 🔧 Option 1: SendGrid Setup (Recommended)

### Step 1: Create SendGrid Account

1. Go to [SendGrid](https://sendgrid.com/)
2. Sign up for a free account (100 emails/day free)
3. Verify your email address

### Step 2: Create API Key

1. Navigate to **Settings** → **API Keys**
2. Click **Create API Key**
3. Name it "MindVault Production"
4. Select **Full Access** permissions
5. Copy the API key (you won't see it again!)

### Step 3: Verify Sender Identity

1. Go to **Settings** → **Sender Authentication**
2. Choose **Single Sender Verification**
3. Add your email: `noreply@mindvault.fit`
4. Fill in the required information
5. Verify the email (check your inbox)

### Step 4: Configure MindVault

Add to your `js/config.js`:

```javascript
// Email Configuration
email: {
    provider: 'sendgrid',
    apiKey: 'YOUR_SENDGRID_API_KEY_HERE',
    fromEmail: 'noreply@mindvault.fit',
    fromName: 'MindVault'
}
```

### Step 5: Initialize Email Service

In your application code:

```javascript
// Initialize email service
const emailService = new MindVaultEmailService();
await emailService.initialize('sendgrid', 'YOUR_SENDGRID_API_KEY');

// Send a test email
await emailService.sendVerificationEmail('test@example.com', 'https://mindvault.fit/verify?token=abc123');
```

---

## 🔧 Option 2: Mailgun Setup

### Step 1: Create Mailgun Account

1. Go to [Mailgun](https://www.mailgun.com/)
2. Sign up for a free account (5,000 emails/month free)
3. Verify your email address

### Step 2: Add Domain

1. Navigate to **Sending** → **Domains**
2. Click **Add New Domain**
3. Enter your domain: `mindvault.fit`
4. Select your region (US or EU)

### Step 3: Configure DNS Records

Add these DNS records to your domain provider:

```
Type: TXT
Name: @
Value: v=spf1 include:mailgun.org ~all

Type: TXT
Name: @
Value: k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...

Type: CNAME
Name: email
Value: mailgun.org

Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none
```

### Step 4: Verify Domain

1. Wait for DNS propagation (up to 48 hours)
2. Go back to Mailgun dashboard
3. Click **Verify DNS Settings**
4. Wait for verification to complete

### Step 5: Get API Credentials

1. Navigate to **Sending** → **Domain Settings**
2. Copy your **API Key**
3. Note your **Base URL** (e.g., `https://api.mailgun.net/v3/mg.mindvault.fit`)

### Step 6: Configure MindVault

Add to your `js/config.js`:

```javascript
// Email Configuration
email: {
    provider: 'mailgun',
    apiKey: 'YOUR_MAILGUN_API_KEY_HERE',
    baseUrl: 'https://api.mailgun.net/v3/mg.mindvault.fit',
    fromEmail: 'noreply@mindvault.fit',
    fromName: 'MindVault'
}
```

### Step 7: Initialize Email Service

```javascript
// Initialize email service
const emailService = new MindVaultEmailService();
await emailService.initialize('mailgun', 'YOUR_MAILGUN_API_KEY', 'https://api.mailgun.net/v3/mg.mindvault.fit');

// Send a test email
await emailService.sendVerificationEmail('test@example.com', 'https://mindvault.fit/verify?token=abc123');
```

---

## 🔧 Option 3: Amazon SES Setup

### Step 1: Create AWS Account

1. Go to [AWS](https://aws.amazon.com/)
2. Sign up for an account
3. Navigate to **Amazon SES** service

### Step 2: Verify Email Address

1. Go to **Verified identities** → **Create identity**
2. Select **Email address**
3. Enter: `noreply@mindvault.fit`
4. Check your email and verify

### Step 3: Verify Domain (Recommended)

1. Go to **Verified identities** → **Create identity**
2. Select **Domain**
3. Enter: `mindvault.fit`
4. Add the provided DNS records to your domain
5. Wait for verification

### Step 4: Request Production Access

1. Go to **Account dashboard**
2. Click **Request production access**
3. Fill out the form:
   - Mail Type: Transactional
   - Website URL: https://mindvault.fit
   - Use case description: Mental health platform user notifications
4. Submit and wait for approval (usually 24 hours)

### Step 5: Create IAM User

1. Go to **IAM** service
2. Click **Users** → **Add user**
3. Name: `mindvault-email`
4. Select **Programmatic access**
5. Attach policy: `AmazonSESFullAccess`
6. Save the **Access Key ID** and **Secret Access Key**

### Step 6: Configure MindVault

**Note:** Amazon SES requires server-side implementation. For client-side use, consider SendGrid or Mailgun instead.

---

## 🧪 Testing Email Configuration

### Test Script

Create a test file `test-email.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Email Test</title>
    <script src="EMAIL-INTEGRATION.js"></script>
</head>
<body>
    <h1>Email Configuration Test</h1>
    <button onclick="testEmail()">Send Test Email</button>
    <div id="result"></div>

    <script>
        async function testEmail() {
            try {
                // Initialize email service
                const emailService = new MindVaultEmailService();
                
                // Replace with your actual credentials
                await emailService.initialize('sendgrid', 'YOUR_API_KEY');
                
                // Send test email
                const result = await emailService.sendVerificationEmail(
                    'your-email@example.com',
                    'https://mindvault.fit/verify?token=test123'
                );
                
                document.getElementById('result').innerHTML = `
                    <p style="color: green;">✅ Email sent successfully!</p>
                    <p>Provider: ${result.provider}</p>
                    <p>Check your inbox for the verification email.</p>
                `;
            } catch (error) {
                document.getElementById('result').innerHTML = `
                    <p style="color: red;">❌ Error: ${error.message}</p>
                `;
            }
        }
    </script>
</body>
</html>
```

### Common Issues

**Issue:** "Email service not initialized"
- **Solution:** Make sure you call `initialize()` before sending emails

**Issue:** "API key invalid"
- **Solution:** Check your API key and ensure it has the correct permissions

**Issue:** "Sender not verified"
- **Solution:** Verify your sender email address in your provider's dashboard

**Issue:** "Rate limit exceeded"
- **Solution:** Check your provider's rate limits and upgrade if needed

---

## 📧 Email Templates Available

The `EMAIL-INTEGRATION.js` module includes these pre-built templates:

1. ✅ **User Verification Email** - `sendVerificationEmail()`
2. ✅ **Password Reset Email** - `sendPasswordResetEmail()`
3. ✅ **Professional Verification Email** - `sendProfessionalVerificationEmail()`
4. ✅ **Session Reminder Email** - `sendSessionReminderEmail()`
5. ✅ **Welcome Email** - `sendWelcomeEmail()`
6. ✅ **Emergency Alert Email** - `sendEmergencyAlertEmail()`

### Usage Example

```javascript
// Initialize service
const emailService = new MindVaultEmailService();
await emailService.initialize('sendgrid', 'YOUR_API_KEY');

// Send verification email
await emailService.sendVerificationEmail(
    'user@example.com',
    'https://mindvault.fit/verify?token=abc123'
);

// Send password reset
await emailService.sendPasswordResetEmail(
    'user@example.com',
    'https://mindvault.fit/reset-password?token=xyz789'
);

// Send professional verification
await emailService.sendProfessionalVerificationEmail(
    'professional@example.com',
    'Dr. Jane Smith'
);
```

---

## 🔒 Security Best Practices

1. **Never commit API keys to git**
   - Use environment variables
   - Store in `js/config.js` (add to `.gitignore`)

2. **Use environment-specific keys**
   - Different keys for development and production
   - Rotate keys regularly

3. **Monitor email usage**
   - Set up usage alerts
   - Track email delivery rates

4. **Implement rate limiting**
   - Prevent email abuse
   - Use the built-in rate limiting system

5. **Validate email addresses**
   - Verify email format before sending
   - Handle bounced emails

---

## 📊 Email Service Comparison

| Feature | SendGrid | Mailgun | Amazon SES |
|---------|----------|---------|------------|
| **Free Tier** | 100/day | 5,000/month | 62,000/month |
| **Setup Difficulty** | Easy | Medium | Hard |
| **DNS Configuration** | Optional | Required | Required |
| **Client-Side Support** | ✅ Yes | ✅ Yes | ❌ No |
| **Deliverability** | Excellent | Excellent | Excellent |
| **Cost (after free)** | $19.95/mo | $35/mo | Pay as you go |
| **Support** | Good | Good | Excellent |

**Recommendation:** Start with **SendGrid** for ease of setup, then migrate to **Mailgun** or **Amazon SES** as you scale.

---

## 🚀 Next Steps

After configuring email:

1. ✅ Test email delivery
2. ✅ Integrate into user registration flow
3. ✅ Set up email notifications for professionals
4. ✅ Configure emergency alert emails
5. ✅ Monitor email delivery rates
6. ✅ Set up bounce and complaint handling

---

## 📞 Support

If you encounter issues:

1. Check the provider's documentation
2. Review the error messages
3. Test with the test script
4. Contact provider support
5. Check DNS settings (if using domain verification)

---

**Need help?** Check the troubleshooting section in your provider's documentation or review the `EMAIL-INTEGRATION.js` code for implementation details.

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

