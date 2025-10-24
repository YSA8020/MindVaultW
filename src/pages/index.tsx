import type { NextPage } from 'next'
import Head from 'next/head'
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
            <div className="bg-white/10 backdrop-blur-lg rounded-full p-6 shadow-2xl">
              <Brain className="h-16 w-16 text-white" />
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
            className="max-w-md mx-auto"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1.2 }}
          >
            {!isSubscribed ? (
              <>
                <p className="text-white/80 mb-4 text-lg">
                  Be the first to know when we launch
                </p>
                <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-3">
                  <div className="flex-1 relative">
                    <Mail className="absolute left-4 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Enter your email"
                      required
                      className="w-full pl-12 pr-4 py-4 rounded-lg bg-white/10 backdrop-blur-lg border border-white/20 text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/50"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={isLoading}
                    className="px-8 py-4 bg-white text-indigo-900 font-semibold rounded-lg hover:bg-gray-100 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                  >
                    {isLoading ? 'Joining...' : 'Notify Me'}
                  </button>
                </form>
              </>
            ) : (
              <motion.div
                className="bg-white/10 backdrop-blur-lg p-6 rounded-lg"
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
              >
                <div className="flex items-center justify-center space-x-2 text-white">
                  <Check className="h-6 w-6 text-green-400" />
                  <span className="text-lg font-semibold">Thank you for subscribing!</span>
                </div>
                <p className="text-white/70 mt-2">
                  We'll notify you when MindVault launches.
                </p>
              </motion.div>
            )}
          </motion.div>

          {/* Launch Timeline */}
          <motion.div
            className="mt-16 text-white/60"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 1.4 }}
          >
            <p className="text-sm">Expected Launch: Q2 2025</p>
          </motion.div>

        </div>
      </div>

      {/* Footer */}
      <motion.footer
        className="absolute bottom-0 w-full py-8 text-center text-white/50"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8, delay: 1.6 }}
      >
        <div className="flex items-center justify-center space-x-8 text-sm">
          <a href="mailto:hello@mindvault.fit" className="hover:text-white/80 transition-colors">
            Contact
          </a>
          <span>•</span>
          <a href="#" className="hover:text-white/80 transition-colors">
            Privacy Policy
          </a>
          <span>•</span>
          <a href="#" className="hover:text-white/80 transition-colors">
            Terms of Service
          </a>
        </div>
        <p className="mt-4">&copy; 2024 MindVault. All rights reserved.</p>
      </motion.footer>
    </div>
  )
}

export default Home
