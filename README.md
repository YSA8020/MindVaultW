# MindVault - Your Mental Health Companion

<div align="center">

![MindVault](public/assets/mindvault-icon.svg)

**A modern, production-ready mental health platform built with Next.js, TypeScript, and Supabase.**

[![Next.js](https://img.shields.io/badge/Next.js-14.0-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Latest-green)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Features](#features) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Deployment](#deployment)

</div>

---

## 🌟 Features

### For Users
- 🎯 **Mood Tracking** - Daily mood logging with insights
- 💬 **Anonymous Sharing** - Safe space to share thoughts
- 🤖 **AI Insights** - Personalized mental health insights
- 👥 **Peer Support** - Connect with others on similar journeys
- 📊 **Progress Tracking** - Visualize your mental health journey
- 🆘 **Crisis Support** - Immediate help resources
- 🌙 **Dark Mode** - Easy on the eyes, day or night

### For Professionals
- 📋 **Client Management** - Organize and track clients
- 📅 **Session Scheduling** - Manage appointments
- 📝 **Treatment Planning** - Create and update plans
- 📈 **Analytics Dashboard** - Track practice metrics
- ✅ **Professional Verification** - Credential verification
- 💼 **Profile Management** - Showcase specializations

### For Admins
- 📊 **Analytics** - System-wide metrics
- 🔒 **Security Dashboard** - Monitor threats
- 💾 **Backup Management** - Data protection
- 👤 **User Management** - System administration
- 🚨 **Emergency Response** - Crisis intervention tools

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm 9+
- Supabase account (free tier works!)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/mindvault.git
cd mindvault

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# Run development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) 🎉

**📖 For detailed setup instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)**

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [SETUP-GUIDE.md](SETUP-GUIDE.md) | Complete installation and setup instructions |
| [REFACTORING-SUMMARY.md](REFACTORING-SUMMARY.md) | Project structure and architecture overview |
| [DATABASE-MIGRATION-GUIDE.md](DATABASE-MIGRATION-GUIDE.md) | Database setup and migration guide |
| [docs/](docs/) | Comprehensive feature documentation |

## 🏗️ Tech Stack

### Frontend
- **Framework:** Next.js 14 with TypeScript
- **Styling:** Tailwind CSS
- **Animations:** Framer Motion
- **Icons:** Lucide React
- **State Management:** React Hooks

### Backend
- **Database:** PostgreSQL (via Supabase)
- **Authentication:** Supabase Auth
- **Real-time:** Supabase Realtime
- **Storage:** Supabase Storage
- **Row Level Security:** Enabled on all tables

### Development
- **Language:** TypeScript
- **Linting:** ESLint
- **Formatting:** Prettier (recommended)
- **Type Checking:** TypeScript Compiler

## 📁 Project Structure

```
mindvault/
├── src/
│   ├── components/          # React components
│   │   ├── layout/         # Layout components
│   │   ├── auth/           # Authentication components
│   │   └── dashboard/      # Dashboard components
│   ├── lib/                # Utilities and services
│   │   ├── supabase.ts    # Supabase client
│   │   ├── auth.ts        # Auth manager
│   │   └── config.ts      # Configuration
│   ├── hooks/              # Custom React hooks
│   │   └── useAuth.ts     # Authentication hook
│   ├── pages/              # Next.js pages (routes)
│   │   ├── index.tsx      # Landing page
│   │   ├── login.tsx      # Login page
│   │   ├── signup.tsx     # Signup page
│   │   └── dashboard.tsx  # User dashboard
│   ├── types/              # TypeScript type definitions
│   └── styles/             # Global styles
├── public/
│   └── assets/             # Static assets (images, icons)
├── database/
│   ├── migrations/         # Database migrations
│   ├── schemas/            # Database schemas
│   └── seeds/              # Seed data
├── docs/                   # Documentation
└── tests/                  # Test files
```

## 🔐 Security

- **Row Level Security (RLS)** enabled on all tables
- **Authentication** via Supabase Auth
- **Environment variables** for sensitive data
- **Rate limiting** on critical endpoints
- **Input validation** on all forms
- **HTTPS only** in production

## 🧪 Testing

```bash
# Run tests
npm test

# Type checking
npm run type-check

# Linting
npm run lint
```

## 📦 Deployment

### Vercel (Recommended for Next.js)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy to production
vercel --prod

# Or use npm script
npm run deploy:vercel
```

### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy to production
netlify deploy --prod

# Or use npm script
npm run deploy:netlify
```

### Cloudflare Pages

Connect your GitHub repository at [dash.cloudflare.com](https://dash.cloudflare.com) for automatic deployments.

**📖 For detailed deployment instructions, see [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)**

**Note:** GitHub Pages is not recommended for this Next.js application due to its server-side rendering requirements.

## 🗃️ Database

The project uses Supabase (PostgreSQL) with:

- **26+ Tables** - Complete schema for all features
- **13 Functions** - Database operations
- **3 Views** - Analytics and dashboards
- **50+ RLS Policies** - Data security

**📖 Setup instructions: [DATABASE-MIGRATION-GUIDE.md](DATABASE-MIGRATION-GUIDE.md)**

## 🎨 Customization

### Branding
1. Replace logo in `public/assets/`
2. Update colors in `tailwind.config.js`
3. Modify content in page files

### Features
1. Check archived pages in `archive/legacy-html-pages/`
2. Convert to React using existing patterns
3. Add routing in `src/pages/`

### Configuration
- Update `src/lib/config.ts` for app settings
- Modify `.env.local` for environment-specific values

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Next.js team for the amazing framework
- Supabase for the backend infrastructure
- Tailwind CSS for the styling system
- All contributors and supporters

## 📧 Support

- **Email:** hello@mindvault.app
- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/yourusername/mindvault/issues)

## 🗺️ Roadmap

- [ ] Mobile app (React Native)
- [ ] Video sessions
- [ ] Group therapy features
- [ ] Integrated payments
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] API for third-party integrations

## 📊 Project Status

**Version:** 2.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** October 2025

---

<div align="center">

**Built with ❤️ for mental health awareness**

[Website](https://mindvault.fit) • [Documentation](docs/) • [Support](mailto:hello@mindvault.app)

</div>
