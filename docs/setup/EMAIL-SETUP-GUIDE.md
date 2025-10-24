# Email Notification Setup Guide for MindVault

## Overview
This guide will help you set up email notifications for your MindVault application using SendGrid (recommended) or alternative providers.

## Option 1: SendGrid Setup (Recommended)

### Step 1: Create SendGrid Account
1. Go to [SendGrid](https://sendgrid.com/)
2. Click "Start for Free"
3. Sign up with your email
4. Verify your email address

### Step 2: Create API Key
1. Go to Settings → API Keys
2. Click "Create API Key"
3. Name it: "MindVault Production"
4. Select "Full Access" or "Restricted Access" with email sending permissions
5. Copy the API key (you'll need this later)

### Step 3: Verify Sender Identity
1. Go to Settings → Sender Authentication
2. Click "Verify a Single Sender"
3. Fill in the form:
   - From Email Address: noreply@mindvault.fit
   - From Name: MindVault
   - Reply To: support@mindvault.fit
   - Company Address: [Your address]
   - Website: https://mindvault.fit
4. Verify the email address

### Step 4: Configure Supabase Email Settings
1. Go to your Supabase project
2. Navigate to Authentication → Email Templates
3. Configure templates for:
   - Email Confirmation
   - Password Reset
   - Magic Link
   - Email Change

### Step 5: Update Supabase Environment Variables
Add these to your Supabase project settings:

```
SENDGRID_API_KEY=your_sendgrid_api_key_here
SENDGRID_FROM_EMAIL=noreply@mindvault.fit
SENDGRID_FROM_NAME=MindVault
```

## Option 2: Mailgun Setup

### Step 1: Create Mailgun Account
1. Go to [Mailgun](https://www.mailgun.com/)
2. Sign up for free account
3. Verify your email

### Step 2: Add Domain
1. Go to Sending → Domains
2. Click "Add New Domain"
3. Enter: mindvault.fit
4. Follow DNS setup instructions
5. Verify domain ownership

### Step 3: Get API Credentials
1. Go to Settings → API Keys
2. Copy your API Key
3. Note your domain name

### Step 4: Configure Supabase
Add these environment variables:

```
MAILGUN_API_KEY=your_mailgun_api_key
MAILGUN_DOMAIN=mg.mindvault.fit
MAILGUN_FROM_EMAIL=noreply@mindvault.fit
```

## Option 3: Amazon SES Setup

### Step 1: Create AWS Account
1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to Amazon SES
3. Verify your email address or domain

### Step 2: Get Credentials
1. Go to IAM → Users
2. Create new user with SES permissions
3. Generate access keys

### Step 3: Configure Supabase
Add these environment variables:

```
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
SES_FROM_EMAIL=noreply@mindvault.fit
```

## Supabase Edge Function for Email Notifications

### Step 1: Create Email Function
Create `supabase/functions/send-email/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { to, subject, template, data } = await req.json()

    // Send email using SendGrid
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [{
          to: [{ email: to }],
          subject: subject,
          dynamic_template_data: data
        }],
        from: {
          email: Deno.env.get('SENDGRID_FROM_EMAIL'),
          name: Deno.env.get('SENDGRID_FROM_NAME')
        },
        template_id: template // Use SendGrid template ID
      })
    })

    if (!response.ok) {
      throw new Error(`SendGrid error: ${response.statusText}`)
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
```

### Step 2: Deploy Function
```bash
supabase functions deploy send-email
```

## Email Notification Triggers

### 1. User Registration
Trigger when user signs up:
```javascript
// In signup.html after successful registration
const { data, error } = await supabase.functions.invoke('send-email', {
  body: {
    to: user.email,
    subject: 'Welcome to MindVault',
    template: 'welcome-template-id',
    data: {
      firstName: user.first_name,
      email: user.email
    }
  }
})
```

### 2. Professional Application
Trigger when professional submits application:
```javascript
// After professional signup
await supabase.functions.invoke('send-email', {
  body: {
    to: professional.email,
    subject: 'Your Professional Application Has Been Received',
    template: 'professional-application-received-id',
    data: {
      firstName: professional.first_name,
      professionalType: professional.professional_type,
      licenseType: professional.license_type,
      licenseNumber: professional.license_number,
      yearsExperience: professional.years_experience
    }
  }
})
```

### 3. Professional Approval
Trigger when admin approves professional:
```javascript
// In admin-dashboard.html after approval
await supabase.functions.invoke('send-email', {
  body: {
    to: professional.email,
    subject: 'Your Professional Application Has Been Approved!',
    template: 'professional-approved-id',
    data: {
      firstName: professional.first_name,
      licenseType: professional.license_type,
      dashboardLink: 'https://mindvault.fit/counselor-dashboard.html'
    }
  }
})
```

### 4. Professional Rejection
Trigger when admin rejects professional:
```javascript
// In admin-dashboard.html after rejection
await supabase.functions.invoke('send-email', {
  body: {
    to: professional.email,
    subject: 'Update on Your Professional Application',
    template: 'professional-rejected-id',
    data: {
      firstName: professional.first_name,
      rejectionReason: 'License verification failed'
    }
  }
})
```

## Email Template Setup in SendGrid

### Step 1: Create Dynamic Templates
1. Go to SendGrid → Email API → Dynamic Templates
2. Click "Create a Dynamic Template"
3. Name it: "MindVault Welcome Email"
4. Click "Add Version"

### Step 2: Design Template
Use the HTML template from EMAIL-TEMPLATES.md

### Step 3: Add Dynamic Variables
Use {{variable}} syntax:
- {{firstName}}
- {{email}}
- {{verificationLink}}

### Step 4: Save and Get Template ID
Copy the template ID for use in your code

## Testing Email Notifications

### Test Email Function
```bash
curl -X POST https://your-project.supabase.co/functions/v1/send-email \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "test@example.com",
    "subject": "Test Email",
    "template": "template-id",
    "data": {
      "firstName": "Test",
      "email": "test@example.com"
    }
  }'
```

### Test in Browser Console
```javascript
const { data, error } = await supabase.functions.invoke('send-email', {
  body: {
    to: 'your-email@example.com',
    subject: 'Test Email from MindVault',
    template: 'your-template-id',
    data: {
      firstName: 'Test User'
    }
  }
})

console.log('Email sent:', data)
```

## Email Monitoring and Analytics

### Track Email Metrics
- Open rates
- Click rates
- Bounce rates
- Unsubscribe rates

### Set Up Alerts
- High bounce rate alerts
- Failed delivery alerts
- Unusual activity alerts

## Compliance and Best Practices

### CAN-SPAM Compliance
- Include physical address
- Provide unsubscribe option
- Honor unsubscribe requests within 10 days
- Don't use deceptive subject lines

### GDPR Compliance
- Get explicit consent
- Allow data access
- Allow data deletion
- Honor opt-out requests

### Email Best Practices
- Send from verified domain
- Use consistent sender name
- Include clear unsubscribe link
- Test emails before sending
- Monitor deliverability
- Avoid spam trigger words

## Troubleshooting

### Common Issues

**Issue: Emails not sending**
- Check API key is correct
- Verify sender email is authenticated
- Check SendGrid account status
- Review error logs

**Issue: Emails going to spam**
- Verify SPF and DKIM records
- Use verified sender domain
- Avoid spam trigger words
- Maintain good sender reputation

**Issue: Template variables not rendering**
- Check variable syntax: {{variable}}
- Verify data is being passed correctly
- Test template in SendGrid

## Support Resources

- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Mailgun Documentation](https://documentation.mailgun.com/)
- [Amazon SES Documentation](https://docs.aws.amazon.com/ses/)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

## Next Steps

1. Choose email provider (SendGrid recommended)
2. Set up account and verify domain
3. Create email templates in provider
4. Deploy Supabase Edge Function
5. Test email notifications
6. Integrate into application
7. Monitor and optimize

Your email notification system is now ready! 🚀
