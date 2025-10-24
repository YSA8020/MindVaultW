import type { NextPage } from 'next'
import Head from 'next/head'
import Image from 'next/image'
import { motion } from 'framer-motion'
import { useState } from 'react'
import { 
  Brain, 
  Heart, 
  Shield, 
  Sparkles,
  Mail,
  Check
} from 'lucide-react'

const Home: NextPage = () => {
  const [email, setEmail] = useState('')
  const [isSubscribed, setIsSubscribed] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    setIsSubscribed(true)
    setIsLoading(false)
    setEmail('')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-800 relative overflow-hidden">
      <Head>
        <title>MindVault - Coming Soon</title>
        <meta name="description" content="Your mental health companion is launching soon. A safe space for mental health support, anonymous sharing, and AI-powered insights." />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-20 left-10 w-72 h-72 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl opacity-20"
          animate={{
            scale: [1, 1.2, 1],
            x: [0, 50, 0],
            y: [0, 30, 0],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        <motion.div
          className="absolute top-40 right-10 w-96 h-96 bg-pink-500 rounded-full mix-blend-multiply filter blur-xl opacity-20"
          animate={{
            scale: [1, 1.3, 1],
            x: [0, -50, 0],
            y: [0, 50, 0],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        <motion.div
          className="absolute -bottom-20 left-1/2 w-80 h-80 bg-indigo-500 rounded-full mix-blend-multiply filter blur-xl opacity-20"
          animate={{
            scale: [1, 1.4, 1],
            x: [0, 30, 0],
          }}
          transition={{
            duration: 12,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      </div>

      {/* Main Content */}
      <div className="relative z-10 min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          
          {/* Logo */}
          <motion.div
            className="flex justify-center mb-8"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <div className="relative w-32 h-32 sm:w-40 sm:h-40">
              <Image
                src="/logo.png"
                alt="MindVault Logo"
                fill
                className="object-contain drop-shadow-2xl"
                priority
              />
            </div>
          </motion.div>

          {/* Brand Name */}
          <motion.h1
            className="text-5xl sm:text-7xl md:text-8xl font-bold text-white mb-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            MindVault
          </motion.h1>

          {/* Coming Soon Badge */}
          <motion.div
            className="inline-flex items-center space-x-2 bg-white/20 backdrop-blur-lg px-6 py-3 rounded-full mb-8"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            <Sparkles className="h-5 w-5 text-yellow-300" />
            <span className="text-white font-semibold text-lg">Coming Soon</span>
            <Sparkles className="h-5 w-5 text-yellow-300" />
          </motion.div>

          {/* Tagline */}
          <motion.p
            className="text-xl sm:text-2xl md:text-3xl text-white/90 mb-4 font-light"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
          >
            Your Mental Health Companion
          </motion.p>

          <motion.p
            className="text-lg sm:text-xl text-white/70 mb-12 max-w-2xl mx-auto"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
          >
            A safe, anonymous space for mental wellness. Share your thoughts, track your mood, 
            and connect with AI-powered insights and professional counselors.
          </motion.p>

          {/* Feature Pills */}
          <motion.div
            className="flex flex-wrap justify-center gap-4 mb-12"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1 }}
          >
            {[
              { icon: Heart, text: "Anonymous Sharing" },
              { icon: Brain, text: "AI Insights" },
              { icon: Shield, text: "Privacy First" }
            ].map((feature, index) => (
              <div
                key={index}
                className="bg-white/10 backdrop-blur-lg px-6 py-3 rounded-full flex items-center space-x-2"
              >
                <feature.icon className="h-5 w-5 text-white" />
                <span className="text-white font-medium">{feature.text}</span>
              </div>
            ))}
          </motion.div>

          {/* Email Signup */}
          <motion.div
            className="max-w-xl mx-auto"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1.2 }}
          >
            {!isSubscribed ? (
              <>
                <p className="text-white/90 mb-6 text-xl font-medium">
                  Be the first to know when we launch
                </p>
                <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-4">
                  <div className="flex-1 relative">
                    <Mail className="absolute left-5 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/40" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Enter your email"
                      required
                      className="w-full pl-14 pr-5 py-4 rounded-xl bg-white/15 backdrop-blur-lg border-2 border-white/30 text-white placeholder-white/60 focus:outline-none focus:ring-2 focus:ring-white/60 focus:border-white/50 transition-all text-base"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="px-10 py-4 bg-white text-purple-900 font-bold rounded-xl hover:bg-white/95 hover:shadow-2xl transition-all transform hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none whitespace-nowrap text-base"
                  >
                    {isLoading ? (
                      <span className="flex items-center gap-2">
                        <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none"/>
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                        </svg>
                        Joining...
                      </span>
                    ) : 'Notify Me'}
                  </button>
                </form>
              </>
            ) : (
              <motion.div
                className="bg-white/15 backdrop-blur-lg p-8 rounded-2xl border-2 border-white/30 shadow-2xl"
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
              >
                <div className="flex items-center justify-center space-x-3 text-white">
                  <div className="bg-green-400 rounded-full p-1">
                    <Check className="h-6 w-6 text-white" />
                  </div>
                  <span className="text-xl font-bold">Thank you for subscribing!</span>
                </div>
                <p className="text-white/80 mt-3 text-center text-base">
                  We'll notify you when MindVault launches.
                </p>
              </motion.div>
            )}
          </motion.div>

          {/* Launch Timeline */}
          <motion.div
            className="mt-20 text-white/70"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 1.4 }}
          >
            <p className="text-base font-medium tracking-wide">Expected Launch: Q2 2025</p>
          </motion.div>

        </div>
      </div>

      {/* Footer */}
      <motion.footer
        className="absolute bottom-0 w-full py-10 text-center text-white/60"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8, delay: 1.6 }}
      >
        <div className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm mb-5 px-4">
          <a 
            href="mailto:hello@mindvault.fit" 
            className="hover:text-white/90 transition-colors duration-200 font-medium"
          >
            Contact
          </a>
          <span className="hidden sm:inline text-white/40">•</span>
          <a 
            href="#" 
            className="hover:text-white/90 transition-colors duration-200 font-medium"
          >
            Privacy Policy
          </a>
          <span className="hidden sm:inline text-white/40">•</span>
          <a 
            href="#" 
            className="hover:text-white/90 transition-colors duration-200 font-medium"
          >
            Terms of Service
          </a>
        </div>
        <p className="text-sm text-white/50">&copy; 2024 MindVault. All rights reserved.</p>
      </motion.footer>
    </div>
  )
}

export default Home
