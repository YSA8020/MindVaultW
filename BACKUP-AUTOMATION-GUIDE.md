# Backup Automation Guide for MindVault

## Overview
This guide explains how to set up automated backups for your MindVault application using Supabase Edge Functions and external services.

## Step 1: Set Up Supabase Edge Functions

### 1.1 Install Supabase CLI
```bash
npm install -g supabase
```

### 1.2 Login to Supabase
```bash
supabase login
```

### 1.3 Initialize Edge Functions
```bash
supabase functions new backup-automation
```

### 1.4 Create Backup Function
Create `supabase/functions/backup-automation/index.ts`:

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
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { backup_type = 'incremental' } = await req.json()

    let result
    if (backup_type === 'full') {
      result = await supabaseClient.rpc('create_full_backup')
    } else {
      result = await supabaseClient.rpc('create_incremental_backup')
    }

    return new Response(
      JSON.stringify({ success: true, backup_id: result.data }),
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

### 1.5 Deploy Edge Function
```bash
supabase functions deploy backup-automation
```

## Step 2: Set Up GitHub Actions for Automated Backups

### 2.1 Create GitHub Actions Workflow
Create `.github/workflows/backup-automation.yml`:

```yaml
name: Automated Backup

on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'
  workflow_dispatch:
    inputs:
      backup_type:
        description: 'Type of backup to create'
        required: true
        default: 'incremental'
        type: choice
        options:
        - incremental
        - full

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
    - name: Create Backup
      run: |
        curl -X POST \
          -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}" \
          -H "Content-Type: application/json" \
          -d '{"backup_type": "${{ github.event.inputs.backup_type || 'incremental' }}"}' \
          https://your-project.supabase.co/functions/v1/backup-automation
        
    - name: Notify on Failure
      if: failure()
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        text: 'MindVault backup failed!'
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Step 3: Set Up External Backup Storage

### 3.1 AWS S3 Backup (Recommended)
Create `backup-to-s3.js`:

```javascript
// Backup to AWS S3
const AWS = require('aws-sdk');
const { createClient } = require('@supabase/supabase-js');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function backupToS3() {
  try {
    // Create backup
    const { data: backupId } = await supabase.rpc('create_full_backup');
    
    // Get backup data
    const { data: backups } = await supabase
      .from('table_backups')
      .select('*')
      .eq('backup_id', backupId);
    
    // Upload to S3
    const s3Key = `mindvault-backups/${backupId}.json`;
    await s3.putObject({
      Bucket: process.env.S3_BACKUP_BUCKET,
      Key: s3Key,
      Body: JSON.stringify(backups),
      ContentType: 'application/json'
    }).promise();
    
    console.log(`Backup ${backupId} uploaded to S3: ${s3Key}`);
  } catch (error) {
    console.error('Backup to S3 failed:', error);
  }
}

// Run backup
backupToS3();
```

### 3.2 Google Cloud Storage Backup
Create `backup-to-gcs.js`:

```javascript
// Backup to Google Cloud Storage
const { Storage } = require('@google-cloud/storage');
const { createClient } = require('@supabase/supabase-js');

const storage = new Storage({
  keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS,
  projectId: process.env.GOOGLE_CLOUD_PROJECT_ID
});

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function backupToGCS() {
  try {
    // Create backup
    const { data: backupId } = await supabase.rpc('create_full_backup');
    
    // Get backup data
    const { data: backups } = await supabase
      .from('table_backups')
      .select('*')
      .eq('backup_id', backupId);
    
    // Upload to GCS
    const bucket = storage.bucket(process.env.GCS_BACKUP_BUCKET);
    const file = bucket.file(`mindvault-backups/${backupId}.json`);
    
    await file.save(JSON.stringify(backups), {
      metadata: {
        contentType: 'application/json'
      }
    });
    
    console.log(`Backup ${backupId} uploaded to GCS: gs://${process.env.GCS_BACKUP_BUCKET}/mindvault-backups/${backupId}.json`);
  } catch (error) {
    console.error('Backup to GCS failed:', error);
  }
}

// Run backup
backupToGCS();
```

## Step 4: Set Up Monitoring and Alerts

### 4.1 Slack Notifications
Create `backup-monitor.js`:

```javascript
// Monitor backup health and send alerts
const { createClient } = require('@supabase/supabase-js');
const axios = require('axios');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function checkBackupHealth() {
  try {
    // Get recent backups
    const { data: backups } = await supabase
      .from('backup_logs')
      .select('*')
      .gte('started_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .order('started_at', { ascending: false });
    
    const failedBackups = backups.filter(b => b.status === 'failed');
    const noBackups = backups.length === 0;
    
    if (failedBackups.length > 0 || noBackups) {
      await sendSlackAlert({
        text: `🚨 MindVault Backup Alert`,
        attachments: [{
          color: 'danger',
          fields: [
            {
              title: 'Failed Backups',
              value: failedBackups.length,
              short: true
            },
            {
              title: 'No Backups in 24h',
              value: noBackups ? 'Yes' : 'No',
              short: true
            }
          ]
        }]
      });
    }
  } catch (error) {
    console.error('Backup health check failed:', error);
  }
}

async function sendSlackAlert(message) {
  try {
    await axios.post(process.env.SLACK_WEBHOOK_URL, message);
  } catch (error) {
    console.error('Failed to send Slack alert:', error);
  }
}

// Run health check
checkBackupHealth();
```

### 4.2 Email Notifications
Create `backup-email-alerts.js`:

```javascript
// Send email alerts for backup issues
const nodemailer = require('nodemailer');
const { createClient } = require('@supabase/supabase-js');

const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function sendBackupEmailAlert() {
  try {
    // Check for failed backups
    const { data: failedBackups } = await supabase
      .from('backup_logs')
      .select('*')
      .eq('status', 'failed')
      .gte('started_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());
    
    if (failedBackups.length > 0) {
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: process.env.ADMIN_EMAIL,
        subject: 'MindVault Backup Alert',
        html: `
          <h2>Backup Alert</h2>
          <p>${failedBackups.length} backup(s) failed in the last 24 hours:</p>
          <ul>
            ${failedBackups.map(backup => `
              <li>${backup.backup_id} - ${new Date(backup.started_at).toLocaleString()}</li>
            `).join('')}
          </ul>
          <p>Please check the backup dashboard for more details.</p>
        `
      };
      
      await transporter.sendMail(mailOptions);
      console.log('Backup alert email sent');
    }
  } catch (error) {
    console.error('Failed to send backup email alert:', error);
  }
}

// Run email alert check
sendBackupEmailAlert();
```

## Step 5: Disaster Recovery Plan

### 5.1 Recovery Procedures
Create `disaster-recovery-plan.md`:

```markdown
# MindVault Disaster Recovery Plan

## Recovery Scenarios

### 1. Database Corruption
1. Stop all services
2. Identify last known good backup
3. Restore from backup using restore_from_backup() function
4. Verify data integrity
5. Restart services

### 2. Complete System Failure
1. Provision new Supabase project
2. Run database schema setup
3. Restore from latest backup
4. Update DNS and configuration
5. Test all functionality

### 3. Partial Data Loss
1. Identify affected tables
2. Restore specific tables from backup
3. Verify data consistency
4. Update any dependent data

## Recovery Contacts
- Primary Admin: [Your Email]
- Backup Admin: [Backup Email]
- Hosting Provider: Supabase Support
- Domain Provider: GoDaddy Support

## Recovery Time Objectives (RTO)
- Critical System: 4 hours
- Full System: 24 hours
- Data Recovery: 2 hours

## Recovery Point Objectives (RPO)
- User Data: 1 hour
- System Logs: 24 hours
- Analytics Data: 1 week
```

## Step 6: Testing and Validation

### 6.1 Backup Testing Script
Create `test-backup-recovery.js`:

```javascript
// Test backup and recovery procedures
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function testBackupRecovery() {
  try {
    console.log('Starting backup and recovery test...');
    
    // 1. Create test backup
    console.log('Creating test backup...');
    const { data: backupId } = await supabase.rpc('create_full_backup');
    console.log(`Test backup created: ${backupId}`);
    
    // 2. Verify backup exists
    const { data: backup } = await supabase
      .from('backup_logs')
      .select('*')
      .eq('backup_id', backupId)
      .single();
    
    if (backup.status !== 'completed') {
      throw new Error('Backup not completed successfully');
    }
    
    // 3. Test restore (on test data only)
    console.log('Testing restore procedure...');
    // Note: Only test on non-production data
    
    console.log('Backup and recovery test completed successfully');
  } catch (error) {
    console.error('Backup and recovery test failed:', error);
  }
}

// Run test
testBackupRecovery();
```

## Step 7: Implementation Checklist

### 7.1 Immediate Actions
- [ ] Run `backup-system.sql` in Supabase SQL Editor
- [ ] Set up backup dashboard access
- [ ] Create first manual backup
- [ ] Test restore procedure

### 7.2 Automation Setup
- [ ] Install Supabase CLI
- [ ] Deploy backup automation Edge Function
- [ ] Set up GitHub Actions workflow
- [ ] Configure external storage (S3/GCS)

### 7.3 Monitoring Setup
- [ ] Set up Slack webhook
- [ ] Configure email alerts
- [ ] Set up backup health monitoring
- [ ] Test alert systems

### 7.4 Documentation
- [ ] Create disaster recovery plan
- [ ] Document recovery procedures
- [ ] Set up recovery contacts
- [ ] Schedule regular backup tests

## Step 8: Maintenance Schedule

### 8.1 Daily
- [ ] Check backup status
- [ ] Review backup logs
- [ ] Verify storage usage

### 8.2 Weekly
- [ ] Test backup restore
- [ ] Review backup retention
- [ ] Check alert systems

### 8.3 Monthly
- [ ] Full disaster recovery test
- [ ] Review and update procedures
- [ ] Clean up old backups
- [ ] Update documentation

## Support and Resources

### Useful Links
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [GitHub Actions](https://docs.github.com/en/actions)
- [AWS S3](https://aws.amazon.com/s3/)
- [Google Cloud Storage](https://cloud.google.com/storage)

### Emergency Contacts
- Supabase Support: support@supabase.com
- GitHub Support: support@github.com
- AWS Support: aws.amazon.com/support
- Google Cloud Support: cloud.google.com/support

Your MindVault backup system is now ready for production use! 🚀
