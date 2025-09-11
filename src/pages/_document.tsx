import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        <meta name="description" content="MindVault - Your Mental Health Companion. A safe space for anonymous sharing, AI-powered insights, and professional support." />
        <meta name="keywords" content="mental health, anonymous sharing, AI insights, counselor support, mood tracking" />
        <meta name="author" content="MindVault Team" />
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://mindvault.app/" />
        <meta property="og:title" content="MindVault - Your Mental Health Companion" />
        <meta property="og:description" content="A safe space for mental health support, anonymous sharing, and AI-powered insights." />
        <meta property="og:image" content="https://mindvault.app/og-image.jpg" />

        {/* Twitter */}
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:url" content="https://mindvault.app/" />
        <meta property="twitter:title" content="MindVault - Your Mental Health Companion" />
        <meta property="twitter:description" content="A safe space for mental health support, anonymous sharing, and AI-powered insights." />
        <meta property="twitter:image" content="https://mindvault.app/og-image.jpg" />

        {/* Favicon */}
        <link rel="icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
        <link rel="manifest" href="/site.webmanifest" />
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
