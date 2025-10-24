# Database Migration Guide for Next.js Refactor

## Overview
This guide explains how the database configuration has been updated to work with the new Next.js/TypeScript structure.

## What Changed

### 1. Configuration Files

**Old Structure:**
```
js/
├── supabase-config.js (JavaScript config)
├── config.js (Global config)
└── supabase-client.js (Database client)
```

**New Structure:**
```
src/lib/
├── supabase.ts (TypeScript client with types)
├── auth.ts (Authentication manager)
└── config.ts (Centralized Next.js config)
```

### 2. Environment Variables

**Old Way:** Hardcoded in `js/supabase-config.js`
```javascript
const SUPABASE_CONFIG = {
    url: 'https://swacnbyayimigfzgzgvm.supabase.co',
    anonKey: 'eyJhbGc...'
};
```

**New Way:** Environment variables in `.env.local`
```bash
NEXT_PUBLIC_SUPABASE_URL=https://swacnbyayimigfzgzgvm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
```

### 3. Database Client Usage

**Old Way (JavaScript):**
```javascript
// Import from window global
const supabaseClient = window.supabaseClient;

// Create mood entry
const { data, error } = await supabaseClient
  .from('mood_entries')
  .insert([{ user_id, mood, mood_score }]);
```

**New Way (TypeScript):**
```typescript
// Import from module
import { SupabaseService } from '@/lib/supabase';

// Create mood entry with type safety
const entry = await SupabaseService.createMoodEntry({
  user_id,
  mood,
  mood_score,
});
```

## Database Schema (No Changes Required)

The database schema remains the same. All tables, indexes, and RLS policies work as before:

### Core Tables
- ✅ `users` - User accounts and profiles
- ✅ `mood_entries` - Daily mood tracking
- ✅ `posts` - Anonymous sharing posts
- ✅ `insights` - AI-generated insights
- ✅ `comments` - Post comments
- ✅ `counselor_profiles` - Professional profiles
- ✅ `sessions` - Counseling sessions

### Additional Tables (From migrations)
- ✅ `professional_profiles` - Professional information
- ✅ `onboarding_progress` - User onboarding state
- ✅ `onboarding_checkpoints` - Onboarding milestones
- ✅ `client_professional_relationships` - Client-counselor links
- ✅ `treatment_plans` - Treatment planning
- ✅ `client_assessments` - Client assessments
- ✅ `rate_limits` - API rate limiting
- ✅ `failed_login_attempts` - Security monitoring
- ✅ `suspicious_activity` - Security logs
- ✅ `anonymous_posts` - Anonymous content
- ✅ And more...

## Migration Steps

### For Existing Supabase Projects

**No migration needed!** Your existing Supabase database will work immediately with the new setup.

Just update your environment variables:

1. **Copy environment template:**
   ```bash
   cp .env.example .env.local
   ```

2. **Add your Supabase credentials:**
   ```bash
   NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Test connection:**
   ```bash
   npm run dev
   ```

### For New Supabase Projects

1. **Create Supabase project** at [supabase.com](https://supabase.com)

2. **Run database setup:**
   - Navigate to SQL Editor in Supabase dashboard
   - Run `database/migrations/COMPLETE-DATABASE-SETUP.sql`
   - Or run `database/migrations/FINAL-WORKING-SETUP.sql`

3. **Get your credentials:**
   - Project Settings → API
   - Copy Project URL and anon/public key

4. **Update `.env.local`:**
   ```bash
   NEXT_PUBLIC_SUPABASE_URL=your-project-url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   ```

5. **Verify setup:**
   - Run `database/schemas/VERIFY-DATABASE-SETUP.sql`
   - Check all tables and policies are created

## TypeScript Types

All database types are now defined in TypeScript:

```typescript
// src/types/index.ts
export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  user_type: 'user' | 'professional' | 'admin';
  plan: 'basic' | 'premium' | 'professional';
  // ... more fields
}

export interface MoodEntry {
  id: string;
  user_id: string;
  mood: string;
  mood_score: number;
  notes?: string;
  created_at: string;
}
```

## API Changes

### Authentication

**Old:**
```javascript
// Manual localStorage management
localStorage.setItem('isLoggedIn', 'true');
localStorage.setItem('userId', user.id);
```

**New:**
```typescript
// Use auth hook
const { user, login, logout } = useAuth();

// Login updates state automatically
await login(userData);
```

### Data Fetching

**Old:**
```javascript
// Direct Supabase calls
const { data } = await supabaseClient
  .from('users')
  .select('*')
  .eq('id', userId);
```

**New:**
```typescript
// Service layer with error handling
const user = await SupabaseService.getUserById(userId);
```

## Row Level Security (RLS)

All existing RLS policies continue to work without modification:

- ✅ Users can only view/edit their own data
- ✅ Posts and comments have proper visibility rules
- ✅ Professionals can only access their clients
- ✅ Admin operations properly restricted

## Database Functions

All existing database functions remain unchanged:

- ✅ `get_user_profile()`
- ✅ `update_user_profile()`
- ✅ `get_professional_clients()`
- ✅ `get_client_sessions()`
- ✅ `create_treatment_plan()`
- ✅ And all others...

## Testing Database Connection

### Test Script
```typescript
// Create a test file: src/lib/__tests__/supabase.test.ts
import { supabase } from '@/lib/supabase';

async function testConnection() {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('count');
    
    if (error) throw error;
    console.log('✅ Database connection successful!');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    return false;
  }
}

testConnection();
```

### Run Test
```bash
npm run dev
# Visit any page and check browser console
```

## Troubleshooting

### Connection Issues

**Problem:** "Supabase credentials not found"

**Solution:**
1. Check `.env.local` exists and has correct values
2. Restart dev server: `npm run dev`
3. Verify environment variables are prefixed with `NEXT_PUBLIC_`

**Problem:** "Row Level Security policy violation"

**Solution:**
1. Ensure user is authenticated
2. Check RLS policies in Supabase dashboard
3. Verify auth token is being sent

**Problem:** "Table does not exist"

**Solution:**
1. Run database migrations
2. Use `database/schemas/VERIFY-DATABASE-SETUP.sql`
3. Check Supabase project is correct

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid API key` | Wrong anon key | Check Project Settings → API |
| `JWT expired` | Old session | Logout and login again |
| `Permission denied` | RLS policy | Check user is authenticated |
| `Relation does not exist` | Missing table | Run migrations |

## Backwards Compatibility

The old JavaScript configuration files are preserved in `archive/` for reference:

```
archive/legacy-html-pages/
└── js/
    ├── supabase-config.js
    ├── config.js
    ├── supabase-client.js
    └── auth.js
```

These are **not used** by the new Next.js app but are kept for reference.

## Performance Improvements

The new setup includes several optimizations:

1. **Connection Pooling** - Supabase client is singleton
2. **Type Safety** - Catch errors at compile time
3. **Error Handling** - Consistent error handling layer
4. **Code Splitting** - Only load what's needed
5. **Tree Shaking** - Smaller bundle sizes

## Security Enhancements

1. **Environment Variables** - No hardcoded credentials
2. **Type Safety** - Prevents SQL injection through types
3. **Service Layer** - Centralized security checks
4. **Auth Hooks** - Consistent authentication checks

## Next Steps

1. ✅ Update `.env.local` with your credentials
2. ✅ Run `npm run dev` to test
3. ✅ Verify database connection
4. ✅ Test authentication flow
5. ✅ Check existing data loads correctly

## Support

If you encounter issues:

1. Check `REFACTORING-SUMMARY.md` for structure changes
2. Review Supabase dashboard for connection issues
3. Run verification scripts in `database/schemas/`
4. Check browser console for detailed errors

## Conclusion

The database layer has been modernized but remains **100% compatible** with your existing Supabase project. No database changes are required - just update your environment variables and you're ready to go! 🚀

