import type { NextPage } from 'next'
import Head from 'next/head'
import Link from 'next/link'
import { motion } from 'framer-motion'
import { 
  Brain, 
  Heart, 
  MessageCircle, 
  ArrowLeft,
  Play,
  Pause,
  Volume2,
  Mic,
  Send,
  Smile,
  Frown,
  Meh
} from 'lucide-react'
import { useState } from 'react'

const Demo: NextPage = () => {
  const [currentStep, setCurrentStep] = useState(0)
  const [mood, setMood] = useState('')
  const [thought, setThought] = useState('')
  const [isRecording, setIsRecording] = useState(false)
  const [aiResponse, setAiResponse] = useState('')

  const steps = [
    {
      title: "Welcome to MindVault",
      content: "This is a safe space to share your thoughts and feelings anonymously.",
      action: () => setCurrentStep(1)
    },
    {
      title: "How are you feeling?",
      content: "Select your current mood to help us understand your emotional state.",
      action: () => setCurrentStep(2)
    },
    {
      title: "Share your thoughts",
      content: "Write about what's on your mind. You can also record a voice note.",
      action: () => setCurrentStep(3)
    },
    {
      title: "AI Insights",
      content: "Get personalized insights and suggestions based on your input.",
      action: () => setCurrentStep(4)
    }
  ]

  const handleMoodSelect = (selectedMood: string) => {
    setMood(selectedMood)
    setTimeout(() => setCurrentStep(2), 500)
  }

  const handleSubmit = () => {
    if (thought.trim()) {
      setAiResponse("Thank you for sharing. I can see you're feeling " + mood + ". Here are some suggestions that might help...")
      setTimeout(() => setCurrentStep(3), 1000)
    }
  }

  const toggleRecording = () => {
    setIsRecording(!isRecording)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <Head>
        <title>MindVault Demo - Try It Now</title>
        <meta name="description" content="Experience MindVault's features with our interactive demo." />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <Link href="/" className="flex items-center space-x-2">
              <Brain className="h-8 w-8 text-indigo-600" />
              <span className="text-2xl font-bold text-gray-900">MindVault</span>
            </Link>
            <Link href="/" className="flex items-center text-gray-600 hover:text-indigo-600 transition-colors">
              <ArrowLeft className="h-5 w-5 mr-2" />
              Back to Home
            </Link>
          </div>
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">Interactive Demo</h1>
          <p className="text-xl text-gray-600">Experience MindVault's core features</p>
        </div>

        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-4">
            {steps.map((_, index) => (
              <div
                key={index}
                className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                  index <= currentStep
                    ? 'bg-indigo-600 text-white'
                    : 'bg-gray-300 text-gray-600'
                }`}
              >
                {index + 1}
              </div>
            ))}
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-indigo-600 h-2 rounded-full transition-all duration-500"
              style={{ width: `${((currentStep + 1) / steps.length) * 100}%` }}
            />
          </div>
        </div>

        {/* Demo Content */}
        <div className="bg-white rounded-2xl shadow-xl p-8 min-h-[500px]">
          {currentStep === 0 && (
            <motion.div
              className="text-center"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <Heart className="h-16 w-16 text-indigo-600 mx-auto mb-6" />
              <h2 className="text-3xl font-bold text-gray-900 mb-4">{steps[0].title}</h2>
              <p className="text-lg text-gray-600 mb-8">{steps[0].content}</p>
              <button
                onClick={steps[0].action}
                className="bg-indigo-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-indigo-700 transition-colors"
              >
                Get Started
              </button>
            </motion.div>
          )}

          {currentStep === 1 && (
            <motion.div
              className="text-center"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h2 className="text-3xl font-bold text-gray-900 mb-4">{steps[1].title}</h2>
              <p className="text-lg text-gray-600 mb-8">{steps[1].content}</p>
              <div className="flex justify-center space-x-6">
                {[
                  { icon: Frown, label: 'Sad', value: 'sad', color: 'text-blue-500' },
                  { icon: Meh, label: 'Neutral', value: 'neutral', color: 'text-yellow-500' },
                  { icon: Smile, label: 'Happy', value: 'happy', color: 'text-green-500' }
                ].map((moodOption) => (
                  <button
                    key={moodOption.value}
                    onClick={() => handleMoodSelect(moodOption.value)}
                    className={`flex flex-col items-center p-6 rounded-xl border-2 transition-all hover:scale-105 ${
                      mood === moodOption.value
                        ? 'border-indigo-500 bg-indigo-50'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <moodOption.icon className={`h-12 w-12 ${moodOption.color} mb-2`} />
                    <span className="font-semibold text-gray-700">{moodOption.label}</span>
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {currentStep === 2 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h2 className="text-3xl font-bold text-gray-900 mb-4">{steps[2].title}</h2>
              <p className="text-lg text-gray-600 mb-6">{steps[2].content}</p>
              
              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    What's on your mind?
                  </label>
                  <textarea
                    value={thought}
                    onChange={(e) => setThought(e.target.value)}
                    className="w-full h-32 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent resize-none"
                    placeholder="Share your thoughts, feelings, or experiences..."
                  />
                </div>
                
                <div className="flex items-center justify-between">
                  <button
                    onClick={toggleRecording}
                    className={`flex items-center px-4 py-2 rounded-lg transition-colors ${
                      isRecording
                        ? 'bg-red-500 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    <Mic className="h-5 w-5 mr-2" />
                    {isRecording ? 'Stop Recording' : 'Record Voice Note'}
                  </button>
                  
                  <button
                    onClick={handleSubmit}
                    disabled={!thought.trim()}
                    className="bg-indigo-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
                  >
                    <Send className="h-5 w-5 mr-2" />
                    Submit
                  </button>
                </div>
              </div>
            </motion.div>
          )}

          {currentStep === 3 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h2 className="text-3xl font-bold text-gray-900 mb-4">{steps[3].title}</h2>
              <p className="text-lg text-gray-600 mb-6">{steps[3].content}</p>
              
              <div className="bg-indigo-50 p-6 rounded-xl">
                <div className="flex items-start space-x-4">
                  <Brain className="h-8 w-8 text-indigo-600 mt-1" />
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">AI Response</h3>
                    <p className="text-gray-700">{aiResponse}</p>
                  </div>
                </div>
              </div>
              
              <div className="mt-8 text-center">
                <Link
                  href="/"
                  className="bg-indigo-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-indigo-700 transition-colors inline-flex items-center"
                >
                  Learn More About MindVault
                  <ArrowLeft className="h-5 w-5 ml-2 rotate-180" />
                </Link>
              </div>
            </motion.div>
          )}
        </div>

        {/* Features Preview */}
        <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-6">
          {[
            {
              icon: MessageCircle,
              title: "Anonymous Sharing",
              description: "Share your thoughts without revealing your identity"
            },
            {
              icon: Brain,
              title: "AI Insights",
              description: "Get personalized mood analysis and suggestions"
            },
            {
              icon: Heart,
              title: "Safe Space",
              description: "A supportive environment for your mental health journey"
            }
          ].map((feature, index) => (
            <div key={index} className="bg-white p-6 rounded-xl shadow-lg">
              <feature.icon className="h-8 w-8 text-indigo-600 mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">{feature.title}</h3>
              <p className="text-gray-600">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export default Demo
