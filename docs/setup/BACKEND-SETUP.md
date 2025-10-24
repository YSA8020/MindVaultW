# MindVault Backend Setup & Deployment Guide

## 🚀 Quick Setup with Supabase + GitHub

### 1. Supabase Setup

#### Step 1: Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

#### Step 2: Configure Database
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `supabase-setup.sql`
4. Run the SQL script to create all tables and policies

#### Step 3: Update Configuration
1. Open `js/supabase-config.js`
2. Replace the placeholder values:
   ```javascript
   const SUPABASE_CONFIG = {
       url: 'https://your-project-id.supabase.co',
       anonKey: 'your-anon-key-here'
   };
   ```

### 2. Frontend Integration

#### Option A: Use Supabase Backend (Production)
1. Include Supabase scripts in your HTML:
   ```html
   <script src="https://unpkg.com/@supabase/supabase-js@2"></script>
   <script src="js/supabase-config.js"></script>
   <script src="js/supabase-database.js"></script>
   ```

#### Option B: Use IndexedDB Fallback (Development)
1. Keep using the current setup:
   ```html
   <script src="js/database.js"></script>
   ```

### 3. GitHub Deployment

#### Step 1: Enable GitHub Pages
1. Go to your GitHub repository settings
2. Navigate to Pages section
3. Select "GitHub Actions" as source

#### Step 2: Push to Main Branch
1. Commit all changes:
   ```bash
   git add .
   git commit -m "Add Supabase backend integration"
   git push origin main
   ```

#### Step 3: Verify Deployment
1. GitHub Actions will automatically deploy
2. Check the Actions tab for deployment status
3. Your site will be available at `https://yourusername.github.io/MindvaultW`

## 🔧 Environment Configuration

### Development Environment
- Uses IndexedDB for local development
- No external dependencies required
- Run with: `python -m http.server 8000`

### Production Environment
- Uses Supabase for data persistence
- Requires Supabase project setup
- Automatically deployed via GitHub Actions

## 📊 Database Schema

### Core Tables
- **users**: User accounts and profiles
- **posts**: Anonymous sharing posts
- **mood_entries**: Daily mood tracking
- **insights**: AI-generated insights
- **comments**: Post comments
- **counselor_profiles**: Counselor information
- **sessions**: Counseling sessions

### Security Features
- Row Level Security (RLS) enabled
- User data isolation
- Anonymous posting support
- Secure authentication

## 🔐 Security Considerations

### Client-Side Security
- Passwords are hashed using SHA-256 (upgrade to bcrypt in production)
- Sensitive data is not stored in localStorage
- RLS policies prevent unauthorized access

### Production Recommendations
1. **Password Hashing**: Implement server-side bcrypt hashing
2. **API Keys**: Use environment variables for sensitive keys
3. **HTTPS**: Ensure all connections use HTTPS
4. **Rate Limiting**: Implement rate limiting for API calls
5. **Input Validation**: Add server-side input validation

## 🧪 Testing

### Local Testing
1. Open `integration-test.html` in browser
2. Run all test suites
3. Verify database operations

### Production Testing
1. Deploy to staging environment
2. Test user registration flow
3. Verify data persistence
4. Test all features end-to-end

## 📈 Monitoring & Analytics

### Supabase Dashboard
- Monitor database performance
- View user analytics
- Check error logs
- Monitor API usage

### GitHub Actions
- Monitor deployment status
- View build logs
- Track deployment history

## 🚨 Troubleshooting

### Common Issues

#### Database Connection Failed
- Check Supabase URL and keys
- Verify RLS policies
- Check network connectivity

#### Authentication Issues
- Verify user exists in database
- Check password hashing
- Ensure RLS policies allow access

#### Deployment Failures
- Check GitHub Actions logs
- Verify file permissions
- Ensure all dependencies are included

### Support Resources
- [Supabase Documentation](https://supabase.com/docs)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🔄 Migration from IndexedDB

If you're currently using IndexedDB and want to migrate to Supabase:

1. **Export existing data** using the export function
2. **Set up Supabase** following the steps above
3. **Import data** into Supabase tables
4. **Update frontend** to use Supabase backend
5. **Test thoroughly** before going live

## 📝 Next Steps

1. **Set up Supabase project** and configure database
2. **Update configuration** with your Supabase credentials
3. **Test locally** with Supabase backend
4. **Deploy to GitHub** and verify production deployment
5. **Monitor and optimize** based on usage patterns

Your MindVault website is now ready for production deployment with a robust backend infrastructure!
