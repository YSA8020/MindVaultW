# 🔄 Backup Automation Setup Guide

This guide will help you set up automated database backups for MindVault using Supabase Edge Functions.

---

## 🎯 Overview

The backup automation system provides:
- ✅ **Full backups** - Complete database snapshot
- ✅ **Incremental backups** - Only changed data since last backup
- ✅ **Automated scheduling** - Run backups on a schedule
- ✅ **Multiple storage options** - Supabase Storage, S3, or GCS
- ✅ **Retention policies** - Automatic cleanup of old backups
- ✅ **Backup history** - Track all backup operations

---

## 📋 Prerequisites

- Supabase project with database deployed
- Supabase CLI installed
- Node.js and npm installed
- Git repository access

---

## 🚀 Setup Instructions

### Step 1: Install Supabase CLI

```bash
# Install globally
npm install -g supabase

# Verify installation
supabase --version
```

### Step 2: Login to Supabase

```bash
# Login to your Supabase account
supabase login

# Follow the prompts to authenticate
```

### Step 3: Link Your Project

```bash
# Get your project reference from Supabase dashboard
# Navigate to: Settings → General → Reference ID

# Link your project
supabase link --project-ref your-project-ref-here

# Example:
# supabase link --project-ref abcdefghijklmnop
```

### Step 4: Create Edge Function

```bash
# Create the backup automation function
supabase functions new backup-automation

# This creates a new directory: supabase/functions/backup-automation
```

### Step 5: Add Backup Code

Copy the contents of `BACKUP-EDGE-FUNCTION.ts` to:
```
supabase/functions/backup-automation/index.ts
```

### Step 6: Set Environment Variables

Create a `.env` file in your project root:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# AWS S3 (Optional - for S3 storage)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
S3_BUCKET_NAME=your-bucket-name
S3_REGION=us-east-1

# Google Cloud Storage (Optional - for GCS storage)
GCS_BUCKET_NAME=your-bucket-name
GCS_PROJECT_ID=your-project-id
```

**Important:** Never commit the `.env` file to git!

### Step 7: Deploy Edge Function

```bash
# Deploy the function
supabase functions deploy backup-automation

# You should see:
# Deploying function backup-automation...
# Function backup-automation deployed successfully
```

### Step 8: Test the Function

```bash
# Test full backup
curl -X POST \
  'https://your-project-ref.supabase.co/functions/v1/backup-automation' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'backup-type: full' \
  -H 'retention-days: 30'

# Test incremental backup
curl -X POST \
  'https://your-project-ref.supabase.co/functions/v1/backup-automation' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'backup-type: incremental' \
  -H 'retention-days: 30'
```

### Step 9: Schedule Automated Backups

#### Option A: Using Supabase Cron Jobs (Recommended)

1. Go to your Supabase dashboard
2. Navigate to **Database** → **Cron Jobs**
3. Click **Create Cron Job**
4. Configure:
   - **Name:** `mindvault-daily-backup`
   - **Schedule:** `0 2 * * *` (2 AM daily)
   - **Function:** `backup-automation`
   - **Headers:**
     - `backup-type: full`
     - `retention-days: 30`
     - `storage-provider: supabase`

5. Click **Create**

#### Option B: Using GitHub Actions

Create `.github/workflows/backup.yml`:

```yaml
name: Daily Backup

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
  workflow_dispatch:  # Manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Backup
        run: |
          curl -X POST \
            'https://${{ secrets.SUPABASE_URL }}/functions/v1/backup-automation' \
            -H 'Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}' \
            -H 'backup-type: full' \
            -H 'retention-days: 30'
```

#### Option C: Using External Cron Service

Use services like:
- **cron-job.org** - Free cron job service
- **EasyCron** - Reliable cron service
- **Cronitor** - Monitoring and cron jobs

Configure to call your Edge Function URL daily.

---

## 🔧 Configuration Options

### Backup Types

#### Full Backup
- Backs up all data from all tables
- Larger file size
- Recommended for weekly backups
- Use header: `backup-type: full`

#### Incremental Backup
- Backs up only data changed since last backup
- Smaller file size
- Recommended for daily backups
- Use header: `backup-type: incremental`

### Storage Providers

#### Supabase Storage (Default)
```bash
-H 'storage-provider: supabase'
```
- Easiest to set up
- Integrated with Supabase
- 1GB free storage

#### AWS S3
```bash
-H 'storage-provider: s3'
-H 'storage-path: backups/mindvault'
```
- Scalable and reliable
- Pay as you go
- Requires AWS credentials

#### Google Cloud Storage
```bash
-H 'storage-provider: gcs'
-H 'storage-path: backups/mindvault'
```
- Cost-effective
- Global infrastructure
- Requires GCS credentials

### Retention Policy

```bash
-H 'retention-days: 30'
```
- Automatically deletes backups older than specified days
- Default: 30 days
- Adjust based on your needs

---

## 📊 Monitoring Backups

### View Backup History

Query the `backup_history` table:

```sql
-- View all backups
SELECT * FROM backup_history
ORDER BY completed_at DESC
LIMIT 10;

-- View backup statistics
SELECT 
    backup_type,
    COUNT(*) as total_backups,
    AVG(size_bytes) as avg_size,
    MIN(completed_at) as first_backup,
    MAX(completed_at) as last_backup
FROM backup_history
WHERE status = 'completed'
GROUP BY backup_type;

-- View failed backups
SELECT * FROM backup_history
WHERE status = 'failed'
ORDER BY completed_at DESC;
```

### Check Backup Dashboard

Open `backup-dashboard.html` in your browser to view:
- Recent backups
- Backup statistics
- Storage usage
- Backup health

---

## 🔄 Restoring from Backup

### Manual Restore

```sql
-- Example: Restore users table
-- 1. Download backup file from storage
-- 2. Extract the users data
-- 3. Run restore query

INSERT INTO users (id, email, full_name, created_at, updated_at)
VALUES 
  ('uuid-1', 'user1@example.com', 'User One', '2024-01-01', '2024-01-01'),
  ('uuid-2', 'user2@example.com', 'User Two', '2024-01-02', '2024-01-02');
```

### Automated Restore Function

Create a restore Edge Function:

```typescript
// supabase/functions/restore-backup/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const supabase = createClient(supabaseUrl, supabaseServiceKey)

  const { backupId, tables } = await req.json()

  // Download backup from storage
  const { data: backupData } = await supabase.storage
    .from('backups')
    .download(`backup-${backupId}.json`)

  const backup = JSON.parse(await backupData.text())

  // Restore specified tables
  for (const table of tables) {
    if (backup.tables[table]) {
      await supabase.from(table).upsert(backup.tables[table])
    }
  }

  return new Response(JSON.stringify({ success: true }))
})
```

---

## 🛠️ Troubleshooting

### Issue: Function deployment fails

**Solution:**
```bash
# Check Supabase CLI version
supabase --version

# Update to latest version
npm update -g supabase

# Try deploying again
supabase functions deploy backup-automation
```

### Issue: Backup times out

**Solution:**
- Reduce the number of tables backed up
- Increase function timeout in Supabase dashboard
- Use incremental backups instead of full backups

### Issue: Storage quota exceeded

**Solution:**
- Upgrade your Supabase plan
- Use external storage (S3 or GCS)
- Reduce retention days
- Delete old backups manually

### Issue: Backup fails with permission error

**Solution:**
- Ensure you're using the service role key
- Check RLS policies on tables
- Verify storage bucket permissions

### Issue: Cron job not running

**Solution:**
- Check cron job configuration in dashboard
- Verify the schedule syntax
- Check function logs for errors
- Test the function manually

---

## 📈 Best Practices

1. **Backup Frequency**
   - Daily incremental backups
   - Weekly full backups
   - Before major deployments

2. **Storage Strategy**
   - Use Supabase Storage for small projects
   - Migrate to S3/GCS as you scale
   - Keep multiple backup copies

3. **Retention Policy**
   - Keep 30 days of daily backups
   - Keep 12 months of weekly backups
   - Keep yearly backups indefinitely

4. **Testing**
   - Test restore process monthly
   - Verify backup integrity
   - Document restore procedures

5. **Monitoring**
   - Set up alerts for failed backups
   - Monitor storage usage
   - Track backup performance

---

## 🔒 Security Considerations

1. **API Keys**
   - Never commit service role keys
   - Use environment variables
   - Rotate keys regularly

2. **Storage Access**
   - Make backup buckets private
   - Use signed URLs for downloads
   - Enable encryption at rest

3. **Backup Data**
   - Encrypt sensitive data
   - Comply with data regulations
   - Secure backup storage

---

## 📞 Support

If you encounter issues:

1. Check function logs in Supabase dashboard
2. Review the troubleshooting section
3. Test the function manually
4. Check Supabase documentation
5. Contact Supabase support

---

## 🎉 Success Checklist

- [ ] Supabase CLI installed
- [ ] Project linked
- [ ] Edge function deployed
- [ ] Environment variables configured
- [ ] Test backup successful
- [ ] Cron job scheduled
- [ ] Backup dashboard accessible
- [ ] Restore process tested
- [ ] Monitoring set up
- [ ] Documentation reviewed

---

**Congratulations!** Your backup automation is now set up and running! 🎊

---

*Last Updated: December 2024*  
*MindVault - Your Mental Health Companion*

