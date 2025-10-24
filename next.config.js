/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['images.unsplash.com'],
    unoptimized: true, // For static export if needed
  },
  experimental: {
    appDir: false,
  },
  // Redirects for old HTML pages to new Next.js routes
  async redirects() {
    return [
      {
        source: '/public/login.html',
        destination: '/login',
        permanent: true,
      },
      {
        source: '/public/signup.html',
        destination: '/signup',
        permanent: true,
      },
      {
        source: '/public/dashboard.html',
        destination: '/dashboard',
        permanent: true,
      },
      {
        source: '/public/index.html',
        destination: '/',
        permanent: true,
      },
    ];
  },
}

module.exports = nextConfig
