# 👤 Admin Accounts Setup Guide

This guide explains how to create admin accounts for MindVault.

---

## 🎯 Overview

Admin accounts have elevated privileges and can:
- Access all user data
- View security dashboard
- Manage backups
- View analytics
- Manage professional verifications
- Access emergency response dashboard

---

## ⚠️ Important Notes

1. **Admin accounts must be created through Supabase Auth first**
2. **Then run the seeding script to create corresponding database records**
3. **Never share admin credentials**
4. **Use strong, unique passwords**
5. **Enable 2FA for all admin accounts**

---

## 🔐 Creating Admin Accounts

### Step 1: Create Account in Supabase Auth

1. **Go to Supabase Dashboard**
   - Navigate to [supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your MindVault project

2. **Navigate to Authentication**
   - Click **Authentication** in the left sidebar
   - Click **Users** tab

3. **Add New User**
   - Click **Add user** button
   - Choose **Create new user**

4. **Fill in User Details**
   ```
   Email: admin@mindvault.fit
   Password: [Generate strong password]
   Auto Confirm User: Yes (checked)
   ```

5. **Create User**
   - Click **Create user**
   - Copy the user ID (you'll need this)

6. **Repeat for Other Admins**
   - Create: `support@mindvault.fit`
   - Create: `tech@mindvault.fit`

### Step 2: Update User Metadata

For each admin user:

1. **Click on the user**
2. **Go to User Metadata section**
3. **Add metadata:**
   ```json
   {
     "full_name": "System Administrator",
     "is_admin": true,
     "user_type": "admin"
   }
   ```
4. **Save changes**

### Step 3: Run Database Seeding Script

1. **Open Supabase SQL Editor**
   - Navigate to **SQL Editor**
   - Click **New query**

2. **Copy and Paste Seeding Script**
   - Open `SEED-DATABASE.sql`
   - Copy the entire contents
   - Paste into SQL Editor

3. **Run the Script**
   - Click **Run** or press `Ctrl+Enter`
   - Wait for completion
   - Check for success message

4. **Verify Admin Accounts**
   ```sql
   -- Check admin accounts
   SELECT id, email, full_name, user_type, is_admin, created_at
   FROM users
   WHERE is_admin = true;
   ```

---

## 🔑 Admin Account Credentials

### Recommended Passwords

Use a password manager to generate strong passwords:

**Requirements:**
- Minimum 16 characters
- Mix of uppercase, lowercase, numbers, symbols
- Unique for each account
- Never used before

**Example Format:**
```
Admin1: Abc123!@#Xyz789$%^
Admin2: Xyz789$%^Abc123!@#
Admin3: 789$%^Abc123!@#Xyz
```

### Password Storage

**Store passwords securely:**
1. Use a password manager (1Password, LastPass, Bitwarden)
2. Enable 2FA on password manager
3. Share passwords only through secure channels
4. Rotate passwords every 90 days

---

## 👥 Admin Roles

### System Administrator (admin@mindvault.fit)

**Responsibilities:**
- Full system access
- User management
- Security configuration
- Backup management
- Database administration

**Permissions:**
- ✅ All user data access
- ✅ Security dashboard
- ✅ Backup dashboard
- ✅ Analytics dashboard
- ✅ Emergency response
- ✅ System configuration

### Support Administrator (support@mindvault.fit)

**Responsibilities:**
- Customer support
- User assistance
- Ticket management
- Professional verification
- Content moderation

**Permissions:**
- ✅ User data access (limited)
- ✅ Support tickets
- ✅ Professional verification
- ✅ User feedback
- ✅ Help center management
- ❌ Security configuration
- ❌ Backup management

### Technical Administrator (tech@mindvault.fit)

**Responsibilities:**
- Technical support
- System monitoring
- Error tracking
- Performance optimization
- Technical documentation

**Permissions:**
- ✅ Error logs
- ✅ System monitoring
- ✅ Performance metrics
- ✅ Technical documentation
- ✅ System configuration
- ❌ User data access (limited)
- ❌ Security configuration

---

## 🔒 Security Best Practices

### 1. Enable Two-Factor Authentication (2FA)

**For Supabase Auth:**
1. Go to **Authentication** → **Providers**
2. Enable **Phone** or **Email** for 2FA
3. Require 2FA for admin accounts

**For Admin Users:**
1. Login to MindVault
2. Go to **Account Settings**
3. Enable **Two-Factor Authentication**
4. Scan QR code with authenticator app
5. Save backup codes securely

### 2. Use Strong Passwords

**Password Requirements:**
- Minimum 16 characters
- Mix of character types
- No dictionary words
- No personal information
- Unique for each account

### 3. Regular Password Rotation

**Schedule:**
- Rotate every 90 days
- Rotate immediately if compromised
- Document rotation in secure location

### 4. Monitor Admin Activity

**Enable Activity Logging:**
```sql
-- Check admin activity
SELECT * FROM user_activity_log
WHERE user_id IN (
    SELECT id FROM users WHERE is_admin = true
)
ORDER BY created_at DESC
LIMIT 50;
```

### 5. Limit Admin Access

**Best Practices:**
- Only create admin accounts when needed
- Use principle of least privilege
- Review admin access quarterly
- Disable unused admin accounts

### 6. Secure Credential Sharing

**Never:**
- Share passwords via email
- Share passwords via chat
- Share passwords verbally
- Store passwords in plain text

**Always:**
- Use password manager
- Use encrypted channels
- Verify recipient identity
- Rotate after sharing

---

## 🧪 Testing Admin Accounts

### Test Admin Access

1. **Login as Admin**
   ```
   Email: admin@mindvault.fit
   Password: [Your password]
   ```

2. **Verify Admin Dashboard Access**
   - Navigate to security dashboard
   - Navigate to backup dashboard
   - Navigate to analytics dashboard

3. **Test Admin Permissions**
   - View all user data
   - Access security features
   - Manage backups
   - View system logs

### Test User Restrictions

1. **Login as Regular User**
   ```
   Email: testuser@mindvault.fit
   Password: TestUser123!
   ```

2. **Verify Restrictions**
   - Cannot access admin dashboards
   - Cannot view other users' data
   - Cannot access security features
   - Cannot manage backups

---

## 📊 Admin Dashboard Access

### Security Dashboard
- **URL:** `/security-dashboard.html`
- **Access:** Admin only
- **Features:** Failed logins, IP blacklist, security events

### Backup Dashboard
- **URL:** `/backup-dashboard.html`
- **Access:** Admin only
- **Features:** Backup management, restore, history

### Analytics Dashboard
- **URL:** `/analytics-dashboard.html`
- **Access:** Admin only
- **Features:** User analytics, usage statistics

### Emergency Response Dashboard
- **URL:** `/emergency-response-dashboard.html`
- **Access:** Admin only
- **Features:** Critical alerts, risk assessment

---

## 🔄 Admin Account Management

### Adding New Admin

1. **Create in Supabase Auth**
2. **Update user metadata**
3. **Run seeding script**
4. **Verify access**
5. **Document in admin registry**

### Removing Admin Access

1. **Update user metadata:**
   ```sql
   UPDATE users
   SET is_admin = false, user_type = 'user'
   WHERE email = 'old-admin@example.com';
   ```

2. **Verify removal:**
   ```sql
   SELECT * FROM users WHERE email = 'old-admin@example.com';
   ```

3. **Document removal**
4. **Notify team**

### Disabling Admin Account

1. **Go to Supabase Auth**
2. **Find the user**
3. **Click "More" → "Delete user"**
4. **Confirm deletion**
5. **Remove from database:**
   ```sql
   DELETE FROM users WHERE email = 'admin@example.com';
   ```

---

## 📝 Admin Registry

Maintain a secure registry of admin accounts:

| Email | Name | Role | Created | Last Login | Status |
|-------|------|------|---------|------------|--------|
| admin@mindvault.fit | System Admin | Full Access | 2024-12-01 | 2024-12-15 | Active |
| support@mindvault.fit | Support Admin | Support | 2024-12-01 | 2024-12-14 | Active |
| tech@mindvault.fit | Tech Admin | Technical | 2024-12-01 | 2024-12-13 | Active |

**Store this registry:**
- In password manager
- In secure document vault
- With limited access
- Updated regularly

---

## 🚨 Emergency Procedures

### Compromised Admin Account

**If admin account is compromised:**

1. **Immediately disable account**
   - Go to Supabase Auth
   - Disable the user
   - Change password

2. **Review activity logs**
   ```sql
   SELECT * FROM user_activity_log
   WHERE user_id = 'compromised-user-id'
   ORDER BY created_at DESC;
   ```

3. **Review security events**
   ```sql
   SELECT * FROM security_events
   WHERE user_id = 'compromised-user-id'
   ORDER BY created_at DESC;
   ```

4. **Reset all admin passwords**
5. **Enable 2FA for all admins**
6. **Review and rotate API keys**
7. **Document incident**

### Lost Admin Access

**If you lose access to admin account:**

1. **Contact Supabase Support**
   - Request password reset
   - Verify identity
   - Reset credentials

2. **Use Backup Admin Account**
   - Login with another admin account
   - Reset lost account password
   - Re-enable access

3. **Review access logs**
4. **Update security settings**

---

## ✅ Admin Setup Checklist

### Initial Setup
- [ ] Create admin accounts in Supabase Auth
- [ ] Update user metadata
- [ ] Run database seeding script
- [ ] Verify admin accounts created
- [ ] Test admin login
- [ ] Enable 2FA for all admins
- [ ] Store credentials securely
- [ ] Document in admin registry

### Security Setup
- [ ] Enable 2FA for all admin accounts
- [ ] Set strong, unique passwords
- [ ] Configure password rotation
- [ ] Enable activity logging
- [ ] Set up security alerts
- [ ] Review admin permissions
- [ ] Test admin restrictions

### Testing
- [ ] Test admin login
- [ ] Test admin dashboard access
- [ ] Test admin permissions
- [ ] Test user restrictions
- [ ] Test 2FA
- [ ] Test password reset
- [ ] Test activity logging

### Documentation
- [ ] Document admin accounts
- [ ] Create admin registry
- [ ] Document emergency procedures
- [ ] Share with team securely
- [ ] Update as needed

---

## 📞 Support

If you encounter issues:

1. Check Supabase Auth documentation
2. Review the seeding script
3. Check database logs
4. Contact Supabase support
5. Review security settings

---

**Admin accounts are critical for system security. Handle with care!** 🔒

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

