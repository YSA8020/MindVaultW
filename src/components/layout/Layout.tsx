import { ReactNode } from 'react';
import Head from 'next/head';
import Navigation from './Navigation';

interface LayoutProps {
  children: ReactNode;
  title?: string;
  description?: string;
  showNav?: boolean;
}

export default function Layout({ 
  children, 
  title = 'MindVault - Your Mental Health Companion',
  description = 'A safe space for mental health support, anonymous sharing, and AI-powered insights.',
  showNav = true 
}: LayoutProps) {
  return (
    <>
      <Head>
        <title>{title}</title>
        <meta name="description" content={description} />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/assets/favicon.svg" type="image/svg+xml" />
      </Head>
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-slate-900 dark:to-slate-800">
        {showNav && <Navigation />}
        <main>{children}</main>
      </div>
    </>
  );
}


