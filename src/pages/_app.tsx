import '../styles/globals.css'
import type { AppProps } from 'next/app'
import Head from 'next/head'
import { useEffect } from 'react'
import { validateEnvironment } from '@/lib/validate-env'

export default function App({ Component, pageProps }: AppProps) {
  useEffect(() => {
    // Validate environment on mount (development only)
    if (process.env.NODE_ENV === 'development') {
      const { isValid, errors } = validateEnvironment()
      if (!isValid) {
        console.error('Environment validation failed:', errors)
      }
    }

    // Check for dark mode preference
    const isDarkMode = localStorage.getItem('darkMode') === 'true'
    if (isDarkMode) {
      document.documentElement.classList.add('dark')
    }
  }, [])

  return (
    <>
      <Head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#4f46e5" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </Head>
      <Component {...pageProps} />
    </>
  )
}
