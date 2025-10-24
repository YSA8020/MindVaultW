# MindVault Setup Guide - Complete Installation

## Prerequisites

Before you begin, ensure you have:

- **Node.js** (v18 or higher): [Download](https://nodejs.org/)
- **npm** (v9 or higher): Comes with Node.js
- **Supabase Account**: [Sign up free](https://supabase.com)
- **Git**: For version control

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

This will install all required packages including:
- Next.js 14
- React 18
- TypeScript
- Supabase client
- Tailwind CSS
- Framer Motion
- And more...

### 2. Set Up Environment Variables

**Create `.env.local` file:**

```bash
# Copy the example file
cp .env.example .env.local
```

**Add your Supabase credentials:**

```env
# Get these from your Supabase project settings
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# Optional: Google Analytics
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-V1ZZ3VLV2L

# Environment
NODE_ENV=development
```

### 3. Set Up Supabase Database

**Option A: Use Existing Database**

If you already have a MindVault database:
1. Update `.env.local` with your credentials
2. Skip to step 4

**Option B: Create New Database**

1. **Create Supabase Project:**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose organization and set project name
   - Select region closest to your users
   - Set database password (save this!)
   - Wait for setup to complete (~2 minutes)

2. **Get API Credentials:**
   - Go to Project Settings → API
   - Copy "Project URL" → `NEXT_PUBLIC_SUPABASE_URL`
   - Copy "anon/public" key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

3. **Run Database Migrations:**
   - Go to SQL Editor in Supabase dashboard
   - Click "New Query"
   - Copy contents of `database/migrations/COMPLETE-DATABASE-SETUP.sql`
   - Paste and click "Run"
   - Wait for completion (should see "Success" message)

4. **Verify Setup:**
   - Go to Table Editor
   - You should see 26+ tables
   - Run `database/schemas/VERIFY-DATABASE-SETUP.sql` to confirm

5. **(Optional) Seed Data:**
   - Run `database/seeds/SEED-DATABASE.sql` for test data

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

You should see the MindVault landing page! 🎉

## Testing the Setup

### 1. Test Database Connection

Visit any page and open browser console (F12). You should see:
```
✅ Supabase client initialized successfully
```

### 2. Test Authentication

1. Navigate to `/signup`
2. Create a test account
3. You should be redirected to `/dashboard`

### 3. Test Features

- **Dashboard**: Log mood, view stats
- **Navigation**: Dark mode toggle works
- **Professional Access**: Sign up as professional user

## Project Structure

```
MindvaultW/
├── src/
│   ├── components/         # React components
│   │   └── layout/        # Navigation, Layout
│   ├── lib/               # Utilities
│   │   ├── supabase.ts   # Database client
│   │   ├── auth.ts       # Auth manager
│   │   └── config.ts     # Configuration
│   ├── hooks/            # React hooks
│   │   └── useAuth.ts    # Auth hook
│   ├── pages/            # Next.js pages
│   │   ├── index.tsx     # Landing page
│   │   ├── login.tsx     # Login page
│   │   ├── signup.tsx    # Signup page
│   │   └── dashboard.tsx # User dashboard
│   ├── types/            # TypeScript types
│   └── styles/           # CSS files
├── public/
│   └── assets/           # Static files
├── database/
│   ├── migrations/       # SQL migrations
│   ├── schemas/          # Database schemas
│   └── seeds/            # Test data
├── docs/                 # Documentation
├── tests/                # Test files
└── archive/              # Legacy code (reference)
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server (port 3000) |
| `npm run build` | Build for production |
| `npm start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run type-check` | Check TypeScript types |
| `npm run export` | Export static site |
| `npm run deploy` | Deploy to GitHub Pages |

## Common Issues & Solutions

### Issue: "Supabase credentials not found"

**Solution:**
1. Ensure `.env.local` exists in project root
2. Check variables start with `NEXT_PUBLIC_`
3. Restart dev server after changing env vars

### Issue: "Cannot connect to database"

**Solution:**
1. Verify Supabase project URL is correct
2. Check API key hasn't expired
3. Ensure project is not paused (free tier)
4. Check network/firewall settings

### Issue: "Table does not exist"

**Solution:**
1. Run database migrations
2. Check SQL editor for errors
3. Verify all tables were created
4. Use `VERIFY-DATABASE-SETUP.sql`

### Issue: "Permission denied for table"

**Solution:**
1. Check Row Level Security (RLS) is enabled
2. Verify RLS policies are created
3. Ensure user is authenticated
4. Check auth token is valid

### Issue: "Module not found" errors

**Solution:**
```bash
# Clear cache and reinstall
rm -rf node_modules .next
npm install
npm run dev
```

### Issue: Port 3000 already in use

**Solution:**
```bash
# Kill process on port 3000 (Mac/Linux)
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 npm run dev
```

## Development Workflow

### 1. Create New Feature

```bash
# Create new branch
git checkout -b feature/your-feature-name

# Make changes
# Test locally
npm run dev

# Check types
npm run type-check

# Lint code
npm run lint
```

### 2. Database Changes

1. Create migration file in `database/migrations/`
2. Test locally in Supabase dashboard
3. Document changes
4. Update type definitions if needed

### 3. Add New Page

```tsx
// src/pages/new-page.tsx
import Layout from '@/components/layout/Layout';

export default function NewPage() {
  return (
    <Layout title="New Page - MindVault">
      <div className="pt-20 px-4">
        {/* Your content */}
      </div>
    </Layout>
  );
}
```

### 4. Add New Component

```tsx
// src/components/NewComponent.tsx
interface NewComponentProps {
  title: string;
}

export default function NewComponent({ title }: NewComponentProps) {
  return <div>{title}</div>;
}
```

## Deployment

### Deploy to Vercel (Recommended)

1. **Push to GitHub:**
   ```bash
   git push origin main
   ```

2. **Import to Vercel:**
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Add environment variables
   - Deploy!

3. **Configure Environment:**
   - Add all `NEXT_PUBLIC_*` variables
   - Set Node.js version to 18+
   - Configure build command: `npm run build`

### Deploy to GitHub Pages

```bash
# Build and deploy
npm run deploy
```

Configure in repository settings:
- Settings → Pages
- Source: `gh-pages` branch
- Wait for deployment

### Deploy to Netlify

1. Connect GitHub repository
2. Build command: `npm run build`
3. Publish directory: `out`
4. Add environment variables
5. Deploy

## Environment-Specific Configuration

### Development
```env
NODE_ENV=development
NEXT_PUBLIC_ENVIRONMENT=development
# Longer timeouts, debug mode enabled
```

### Production
```env
NODE_ENV=production
NEXT_PUBLIC_ENVIRONMENT=production
# Optimized builds, error tracking enabled
```

## Database Maintenance

### Backup Database

```sql
-- Use Supabase dashboard
-- Database → Backups → Create backup
```

### Restore Database

```sql
-- Use Supabase dashboard
-- Database → Backups → Restore
```

### Update Schema

1. Create new migration file
2. Test in development
3. Run in production during low-traffic period
4. Verify with test queries

## Security Best Practices

1. **Never commit `.env.local`** - It's in `.gitignore`
2. **Use environment variables** for all secrets
3. **Enable RLS** on all tables
4. **Validate user input** on client and server
5. **Keep dependencies updated**
6. **Use HTTPS** in production
7. **Rotate API keys** regularly

## Performance Optimization

### 1. Images
- Use Next.js `Image` component
- Optimize before uploading
- Use appropriate formats (WebP)

### 2. Code Splitting
- Dynamic imports for large components
- Lazy load routes
- Split vendor bundles

### 3. Caching
- Cache API responses
- Use SWR or React Query
- Enable Next.js caching

### 4. Database
- Index frequently queried columns
- Use connection pooling
- Optimize queries

## Monitoring

### Check Application Health

1. **Performance:**
   - Use Chrome DevTools Lighthouse
   - Monitor Core Web Vitals
   - Check bundle sizes

2. **Errors:**
   - Check browser console
   - Review Supabase logs
   - Set up error tracking (Sentry)

3. **Database:**
   - Monitor query performance
   - Check connection pool
   - Review slow queries

## Next Steps

After setup is complete:

1. ✅ **Customize Branding:**
   - Update logo in `public/assets/`
   - Modify colors in `tailwind.config.js`
   - Edit content in pages

2. ✅ **Add Features:**
   - Review `REFACTORING-SUMMARY.md` for remaining pages
   - Convert archived HTML pages as needed
   - Add new functionality

3. ✅ **Configure Services:**
   - Set up email service (SendGrid/Mailgun)
   - Configure analytics
   - Add error tracking
   - Set up monitoring

4. ✅ **Test Thoroughly:**
   - Run through user workflows
   - Test on different devices
   - Check all features work
   - Verify data persistence

5. ✅ **Deploy:**
   - Choose hosting platform
   - Configure domain
   - Set up SSL
   - Configure CDN

## Getting Help

- **Documentation:** Check `docs/` folder
- **Database Issues:** See `DATABASE-MIGRATION-GUIDE.md`
- **Structure Questions:** See `REFACTORING-SUMMARY.md`
- **Supabase Docs:** [supabase.com/docs](https://supabase.com/docs)
- **Next.js Docs:** [nextjs.org/docs](https://nextjs.org/docs)

## Checklist

Use this checklist to ensure everything is set up correctly:

- [ ] Node.js 18+ installed
- [ ] Dependencies installed (`npm install`)
- [ ] `.env.local` created with Supabase credentials
- [ ] Database migrations run successfully
- [ ] Development server starts (`npm run dev`)
- [ ] Can access http://localhost:3000
- [ ] Can create user account
- [ ] Can login successfully
- [ ] Dark mode toggle works
- [ ] Dashboard loads with user data
- [ ] No console errors
- [ ] TypeScript compiles without errors
- [ ] Environment validated

## Congratulations! 🎉

Your MindVault application is now set up and ready for development!

For more details, check out:
- `REFACTORING-SUMMARY.md` - Project structure overview
- `DATABASE-MIGRATION-GUIDE.md` - Database setup details
- `docs/` folder - Comprehensive documentation

Happy coding! 🚀

