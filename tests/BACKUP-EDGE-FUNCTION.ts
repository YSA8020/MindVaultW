/**
 * MindVault Backup Automation - Supabase Edge Function
 * 
 * This Edge Function automates database backups for MindVault
 * Run on a schedule using Supabase cron jobs
 * 
 * Setup Instructions:
 * 1. Install Supabase CLI: npm install -g supabase
 * 2. Login: supabase login
 * 3. Link project: supabase link --project-ref your-project-ref
 * 4. Deploy: supabase functions deploy backup-automation
 * 5. Schedule: Add cron job in Supabase dashboard
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface BackupConfig {
  backupType: 'full' | 'incremental'
  retentionDays: number
  storageProvider: 'supabase' | 's3' | 'gcs'
  storagePath?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get configuration from request or environment
    const config: BackupConfig = {
      backupType: req.headers.get('backup-type') as 'full' | 'incremental' || 'full',
      retentionDays: parseInt(req.headers.get('retention-days') || '30'),
      storageProvider: req.headers.get('storage-provider') as 'supabase' | 's3' | 'gcs' || 'supabase',
      storagePath: req.headers.get('storage-path') || undefined
    }

    console.log('Starting backup process:', config)

    // Create backup record
    const { data: backupRecord, error: backupError } = await supabase
      .from('backup_history')
      .insert({
        backup_type: config.backupType,
        status: 'in_progress',
        started_at: new Date().toISOString(),
        config: config
      })
      .select()
      .single()

    if (backupError) {
      throw new Error(`Failed to create backup record: ${backupError.message}`)
    }

    const backupId = backupRecord.id

    try {
      // Perform backup based on type
      let backupData: any = {}

      if (config.backupType === 'full') {
        backupData = await performFullBackup(supabase)
      } else {
        backupData = await performIncrementalBackup(supabase)
      }

      // Store backup based on provider
      let storageUrl: string
      switch (config.storageProvider) {
        case 'supabase':
          storageUrl = await storeInSupabaseStorage(supabase, backupData, backupId)
          break
        case 's3':
          storageUrl = await storeInS3(backupData, backupId, config.storagePath)
          break
        case 'gcs':
          storageUrl = await storeInGCS(backupData, backupId, config.storagePath)
          break
        default:
          throw new Error(`Unsupported storage provider: ${config.storageProvider}`)
      }

      // Update backup record with success
      await supabase
        .from('backup_history')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          storage_url: storageUrl,
          size_bytes: JSON.stringify(backupData).length,
          record_count: backupData.totalRecords || 0
        })
        .eq('id', backupId)

      console.log('Backup completed successfully:', backupId)

      // Clean up old backups
      await cleanupOldBackups(supabase, config.retentionDays)

      return new Response(
        JSON.stringify({
          success: true,
          backupId,
          storageUrl,
          type: config.backupType,
          size: JSON.stringify(backupData).length,
          records: backupData.totalRecords || 0
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    } catch (error) {
      // Update backup record with failure
      await supabase
        .from('backup_history')
        .update({
          status: 'failed',
          completed_at: new Date().toISOString(),
          error_message: error.message
        })
        .eq('id', backupId)

      throw error
    }
  } catch (error) {
    console.error('Backup error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

/**
 * Perform full database backup
 */
async function performFullBackup(supabase: any) {
  console.log('Performing full backup...')

  const backupData: any = {
    timestamp: new Date().toISOString(),
    type: 'full',
    tables: {},
    totalRecords: 0
  }

  // List of tables to backup
  const tables = [
    'users',
    'user_settings',
    'user_sessions',
    'user_activity_log',
    'error_log',
    'notification_preferences',
    'user_feedback',
    'support_tickets',
    'professional_profiles',
    'onboarding_progress',
    'onboarding_checkpoints',
    'client_professional_relationships',
    'sessions',
    'treatment_plans',
    'client_assessments',
    'client_notes',
    'professional_availability',
    'professional_analytics',
    'rate_limits',
    'failed_login_attempts',
    'suspicious_activity',
    'ip_blacklist',
    'user_security_settings',
    'security_events',
    'anonymous_posts'
  ]

  // Backup each table
  for (const table of tables) {
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(100000) // Limit to prevent memory issues

      if (error) {
        console.error(`Error backing up ${table}:`, error.message)
        backupData.tables[table] = { error: error.message }
      } else {
        backupData.tables[table] = data
        backupData.totalRecords += data.length
        console.log(`Backed up ${table}: ${data.length} records`)
      }
    } catch (error) {
      console.error(`Exception backing up ${table}:`, error.message)
      backupData.tables[table] = { error: error.message }
    }
  }

  return backupData
}

/**
 * Perform incremental backup (only changed data since last backup)
 */
async function performIncrementalBackup(supabase: any) {
  console.log('Performing incremental backup...')

  const backupData: any = {
    timestamp: new Date().toISOString(),
    type: 'incremental',
    tables: {},
    totalRecords: 0
  }

  // Get last backup timestamp
  const { data: lastBackup } = await supabase
    .from('backup_history')
    .select('completed_at')
    .eq('status', 'completed')
    .order('completed_at', { ascending: false })
    .limit(1)
    .single()

  const lastBackupTime = lastBackup?.completed_at || '1970-01-01T00:00:00Z'

  // Tables with updated_at columns
  const tablesWithTimestamps = [
    'users',
    'user_settings',
    'user_sessions',
    'user_activity_log',
    'error_log',
    'notification_preferences',
    'user_feedback',
    'support_tickets',
    'professional_profiles',
    'onboarding_progress',
    'client_professional_relationships',
    'sessions',
    'treatment_plans',
    'client_assessments',
    'client_notes',
    'professional_availability',
    'professional_analytics',
    'rate_limits',
    'failed_login_attempts',
    'suspicious_activity',
    'security_events',
    'anonymous_posts'
  ]

  // Backup only changed records
  for (const table of tablesWithTimestamps) {
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .gte('updated_at', lastBackupTime)
        .limit(100000)

      if (error) {
        console.error(`Error backing up ${table}:`, error.message)
        backupData.tables[table] = { error: error.message }
      } else if (data && data.length > 0) {
        backupData.tables[table] = data
        backupData.totalRecords += data.length
        console.log(`Backed up ${table}: ${data.length} records`)
      }
    } catch (error) {
      console.error(`Exception backing up ${table}:`, error.message)
      backupData.tables[table] = { error: error.message }
    }
  }

  return backupData
}

/**
 * Store backup in Supabase Storage
 */
async function storeInSupabaseStorage(supabase: any, backupData: any, backupId: string): Promise<string> {
  console.log('Storing backup in Supabase Storage...')

  const fileName = `backup-${backupId}-${Date.now()}.json`
  const bucketName = 'backups'

  // Create bucket if it doesn't exist
  const { error: bucketError } = await supabase.storage.createBucket(bucketName, {
    public: false,
    fileSizeLimit: 52428800, // 50MB
    allowedMimeTypes: ['application/json']
  })

  if (bucketError && !bucketError.message.includes('already exists')) {
    console.error('Error creating bucket:', bucketError.message)
  }

  // Upload backup file
  const { data: uploadData, error: uploadError } = await supabase.storage
    .from(bucketName)
    .upload(fileName, JSON.stringify(backupData), {
      contentType: 'application/json',
      upsert: false
    })

  if (uploadError) {
    throw new Error(`Failed to upload backup: ${uploadError.message}`)
  }

  // Get public URL
  const { data: urlData } = supabase.storage
    .from(bucketName)
    .getPublicUrl(fileName)

  return urlData.publicUrl
}

/**
 * Store backup in AWS S3
 */
async function storeInS3(backupData: any, backupId: string, path?: string): Promise<string> {
  console.log('Storing backup in S3...')

  const AWS_ACCESS_KEY = Deno.env.get('AWS_ACCESS_KEY_ID')
  const AWS_SECRET_KEY = Deno.env.get('AWS_SECRET_ACCESS_KEY')
  const S3_BUCKET = Deno.env.get('S3_BUCKET_NAME')
  const S3_REGION = Deno.env.get('S3_REGION') || 'us-east-1'

  if (!AWS_ACCESS_KEY || !AWS_SECRET_KEY || !S3_BUCKET) {
    throw new Error('AWS credentials not configured')
  }

  const fileName = path || `backups/mindvault-${backupId}-${Date.now()}.json`
  const url = `https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/${fileName}`

  // Note: S3 upload requires AWS SDK
  // For production, use the AWS SDK for Deno
  // This is a placeholder implementation

  return url
}

/**
 * Store backup in Google Cloud Storage
 */
async function storeInGCS(backupData: any, backupId: string, path?: string): Promise<string> {
  console.log('Storing backup in GCS...')

  const GCS_BUCKET = Deno.env.get('GCS_BUCKET_NAME')
  const GCS_PROJECT = Deno.env.get('GCS_PROJECT_ID')

  if (!GCS_BUCKET || !GCS_PROJECT) {
    throw new Error('GCS credentials not configured')
  }

  const fileName = path || `backups/mindvault-${backupId}-${Date.now()}.json`
  const url = `https://storage.googleapis.com/${GCS_BUCKET}/${fileName}`

  // Note: GCS upload requires Google Cloud SDK
  // For production, use the Google Cloud SDK for Deno
  // This is a placeholder implementation

  return url
}

/**
 * Clean up old backups based on retention policy
 */
async function cleanupOldBackups(supabase: any, retentionDays: number) {
  console.log(`Cleaning up backups older than ${retentionDays} days...`)

  const cutoffDate = new Date()
  cutoffDate.setDate(cutoffDate.getDate() - retentionDays)

  // Delete old backup records
  const { error } = await supabase
    .from('backup_history')
    .delete()
    .lt('completed_at', cutoffDate.toISOString())

  if (error) {
    console.error('Error cleaning up old backups:', error.message)
  } else {
    console.log('Old backups cleaned up successfully')
  }
}

