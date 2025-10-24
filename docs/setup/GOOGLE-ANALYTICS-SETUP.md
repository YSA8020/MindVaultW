# Google Analytics Setup Guide for MindVault

## Overview
This guide will help you set up Google Analytics 4 (GA4) for your MindVault application to track user behavior, conversions, and performance metrics.

## Step 1: Create Google Analytics Account

### 1.1 Sign up for Google Analytics
1. Go to [Google Analytics](https://analytics.google.com/)
2. Click "Start measuring"
3. Sign in with your Google account
4. Create an account for "MindVault"

### 1.2 Create a Property
1. Click "Create Property"
2. Enter property name: **MindVault**
3. Select your country and timezone
4. Choose your industry: **Healthcare**
5. Select your business size
6. Choose your business objectives:
   - ✅ Generate leads
   - ✅ Drive online sales
   - ✅ Raise brand awareness
   - ✅ Examine user behavior

### 1.3 Create a Data Stream
1. Select "Web" as your platform
2. Enter your website URL: **https://mindvault.fit**
3. Enter stream name: **MindVault Web**
4. Click "Create stream"

### 1.4 Get Your Measurement ID
1. Copy your **Measurement ID** (starts with `G-`)
2. It will look like: `G-XXXXXXXXXX`

## Step 2: Configure Analytics in MindVault

### 2.1 Update Configuration
1. Open `js/config.js`
2. Find the analytics section
3. Replace `null` with your Measurement ID:

```javascript
analytics: {
    gaTrackingId: 'G-XXXXXXXXXX', // Replace with your actual ID
    // ... rest of config
}
```

### 2.2 Add Analytics Script to Pages
The analytics script is already included in your pages via `js/analytics-config.js`. Make sure it's loaded in the correct order:

```html
<script src="js/supabase-config.js"></script>
<script src="js/config.js"></script>
<script src="js/analytics-config.js"></script>
```

## Step 3: Set Up Custom Dimensions

### 3.1 Configure Custom Dimensions in GA4
1. Go to your GA4 property
2. Click "Configure" → "Custom Definitions"
3. Click "Create custom dimension"
4. Add these dimensions:

| Dimension Name | Parameter Name | Scope | Description |
|----------------|----------------|-------|-------------|
| User Type | user_type | User | user, professional, admin |
| Subscription Plan | subscription_plan | User | basic, premium, professional |
| License Type | license_type | User | For professionals |
| Support Group | support_group | User | User's support group |
| Experience Level | experience_level | User | User's experience level |

### 3.2 Configure Custom Events
1. Go to "Configure" → "Events"
2. Add these custom events:

| Event Name | Description | Parameters |
|------------|-------------|------------|
| professional_signup | Professional registration | license_type, professional_type |
| user_login | User login | method |
| user_registration | User registration | method |
| form_submit | Form submission | form_id, form_action |
| button_click | Button clicks | button_id, button_text |
| file_download | File downloads | file_name, file_extension |
| external_link_click | External link clicks | link_url, link_text |

## Step 4: Set Up Goals and Conversions

### 4.1 Mark Key Events as Conversions
1. Go to "Configure" → "Conversions"
2. Mark these events as conversions:
   - ✅ **professional_signup** - Professional registration
   - ✅ **user_registration** - User registration
   - ✅ **purchase** - Subscription purchase (if applicable)

### 4.2 Set Up Enhanced Ecommerce (Optional)
If you plan to sell subscriptions:
1. Go to "Configure" → "Enhanced measurement"
2. Enable "Purchase" tracking
3. Configure your subscription plans as products

## Step 5: Configure Audiences

### 5.1 Create User Segments
1. Go to "Configure" → "Audiences"
2. Create these audiences:

| Audience Name | Description | Conditions |
|---------------|-------------|------------|
| Professionals | Licensed professionals | user_type = professional |
| Premium Users | Premium subscribers | subscription_plan = premium |
| Active Users | Users with recent activity | Last seen within 7 days |
| New Users | Recently registered | First seen within 30 days |

## Step 6: Set Up Reporting

### 6.1 Create Custom Reports
1. Go to "Reports" → "Library"
2. Create custom reports for:
   - **User Journey Analysis**
   - **Professional Signup Funnel**
   - **Feature Usage Tracking**
   - **Performance Metrics**

### 6.2 Set Up Dashboards
1. Go to "Reports" → "Library"
2. Create dashboards for:
   - **Executive Summary**
   - **User Behavior**
   - **Professional Analytics**
   - **Performance Monitoring**

## Step 7: Privacy and Compliance

### 7.1 Configure Data Retention
1. Go to "Admin" → "Data Settings" → "Data Retention"
2. Set retention to **26 months** (maximum)
3. Enable "Reset on new activity"

### 7.2 Set Up Data Filters
1. Go to "Admin" → "Data Settings" → "Data Filters"
2. Create filters to exclude:
   - Internal traffic (your IP addresses)
   - Bot traffic
   - Development/staging environments

### 7.3 Configure Consent Mode (GDPR/CCPA)
1. Go to "Admin" → "Data Settings" → "Data Collection"
2. Enable "Google signals data collection"
3. Configure consent mode for privacy compliance

## Step 8: Testing and Validation

### 8.1 Test Analytics Implementation
1. Use Google Analytics DebugView:
   - Install [Google Analytics Debugger](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)
   - Visit your site and check DebugView
   - Verify events are firing correctly

### 8.2 Validate Custom Dimensions
1. Go to "Reports" → "Realtime"
2. Perform actions on your site
3. Check that custom dimensions are populated

### 8.3 Test Conversions
1. Complete a test registration
2. Check "Reports" → "Conversions"
3. Verify the conversion is recorded

## Step 9: Monitoring and Maintenance

### 9.1 Set Up Alerts
1. Go to "Admin" → "Custom Alerts"
2. Create alerts for:
   - Significant traffic drops
   - Conversion rate changes
   - Error rate increases

### 9.2 Regular Reviews
- **Weekly**: Check key metrics and trends
- **Monthly**: Review user behavior and conversion funnels
- **Quarterly**: Analyze audience segments and optimize

## Step 10: Integration with MindVault Dashboard

### 10.1 Access Analytics Dashboard
Your custom analytics dashboard is available at:
- **URL**: `https://mindvault.fit/analytics-dashboard.html`
- **Features**: Real-time metrics, user behavior, performance data

### 10.2 Key Metrics to Monitor
- **User Acquisition**: New users, traffic sources
- **User Engagement**: Session duration, page views, bounce rate
- **Conversions**: Professional signups, user registrations
- **Performance**: Core Web Vitals, page load times
- **User Behavior**: Top pages, user journeys, feature usage

## Troubleshooting

### Common Issues
1. **Events not firing**: Check Measurement ID and script loading
2. **Custom dimensions not showing**: Verify dimension configuration
3. **Data delays**: GA4 has 24-48 hour processing delay
4. **Missing data**: Check filters and data retention settings

### Support Resources
- [Google Analytics Help Center](https://support.google.com/analytics/)
- [GA4 Documentation](https://developers.google.com/analytics/devguides/collection/ga4)
- [MindVault Analytics Dashboard](https://mindvault.fit/analytics-dashboard.html)

## Next Steps
1. Set up your Google Analytics account
2. Configure your Measurement ID in `js/config.js`
3. Test the implementation
4. Monitor your analytics dashboard
5. Set up custom reports and alerts

Your MindVault application is now ready for comprehensive analytics tracking! 🚀
