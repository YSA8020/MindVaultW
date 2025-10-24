import { useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/layout/Layout';

const steps = [
  { id: 1, title: 'Welcome', icon: '👋' },
  { id: 2, title: 'Profile', icon: '👤' },
  { id: 3, title: 'Credentials', icon: '📜' },
  { id: 4, title: 'Availability', icon: '📅' },
  { id: 5, title: 'Complete', icon: '✅' },
];

export default function ProfessionalOnboarding() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(1);

  const nextStep = () => {
    if (currentStep < steps.length) {
      setCurrentStep(currentStep + 1);
    } else {
      router.push('/counselor-dashboard');
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  return (
    <Layout title="Professional Onboarding - MindVault" showNav={false}>
      <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl w-full space-y-8">
          {/* Progress Bar */}
          <div className="mb-8">
            <div className="flex justify-between mb-4">
              {steps.map((step) => (
                <div key={step.id} className="flex flex-col items-center">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl transition-all ${
                      step.id === currentStep
                        ? 'bg-indigo-600 scale-110 shadow-lg'
                        : step.id < currentStep
                        ? 'bg-green-500'
                        : 'bg-gray-300 dark:bg-slate-600'
                    }`}
                  >
                    {step.icon}
                  </div>
                  <p className={`mt-2 text-sm font-medium ${
                    step.id === currentStep ? 'text-indigo-600 dark:text-indigo-400' : 'text-gray-600 dark:text-gray-400'
                  }`}>
                    {step.title}
                  </p>
                </div>
              ))}
            </div>
            <div className="w-full bg-gray-200 dark:bg-slate-700 rounded-full h-2">
              <div
                className="bg-indigo-600 h-2 rounded-full transition-all duration-500"
                style={{ width: `${(currentStep / steps.length) * 100}%` }}
              ></div>
            </div>
          </div>

          {/* Step Content */}
          <div className="bg-white dark:bg-slate-800 shadow-2xl rounded-2xl p-8">
            {currentStep === 1 && (
              <div className="text-center">
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                  Welcome to MindVault Professional!
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                  Let's get you set up to help clients on their mental health journey.
                </p>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-left">
                  <div className="p-4 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg">
                    <div className="text-2xl mb-2">🎯</div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">Connect with Clients</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      Reach thousands of individuals seeking support
                    </p>
                  </div>
                  <div className="p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
                    <div className="text-2xl mb-2">📊</div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">Manage Practice</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      Tools to organize and grow your practice
                    </p>
                  </div>
                  <div className="p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                    <div className="text-2xl mb-2">💼</div>
                    <h3 className="font-semibold text-gray-900 dark:text-white mb-1">Flexible Schedule</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      Set your availability and work on your terms
                    </p>
                  </div>
                </div>
              </div>
            )}

            {currentStep === 2 && (
              <div>
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                  Complete Your Profile
                </h2>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Professional Title
                    </label>
                    <input
                      type="text"
                      placeholder="e.g., Licensed Clinical Psychologist"
                      className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-slate-700 dark:text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Specializations
                    </label>
                    <select multiple className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-slate-700 dark:text-white">
                      <option>Anxiety</option>
                      <option>Depression</option>
                      <option>Trauma & PTSD</option>
                      <option>Relationship Issues</option>
                      <option>Addiction</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Bio
                    </label>
                    <textarea
                      rows={4}
                      placeholder="Tell clients about your approach and experience..."
                      className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-slate-700 dark:text-white"
                    ></textarea>
                  </div>
                </div>
              </div>
            )}

            {currentStep === 3 && (
              <div>
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                  Verify Your Credentials
                </h2>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      License Number
                    </label>
                    <input
                      type="text"
                      placeholder="Enter your license number"
                      className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-slate-700 dark:text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      State/Region
                    </label>
                    <input
                      type="text"
                      placeholder="Where are you licensed?"
                      className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-slate-700 dark:text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Upload License Document
                    </label>
                    <div className="border-2 border-dashed border-gray-300 dark:border-slate-600 rounded-lg p-6 text-center">
                      <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                      <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
                        Click to upload or drag and drop
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {currentStep === 4 && (
              <div>
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                  Set Your Availability
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mb-6">
                  Choose when you're available for sessions
                </p>
                <div className="space-y-4">
                  {['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day) => (
                    <div key={day} className="flex items-center justify-between p-4 bg-gray-50 dark:bg-slate-700 rounded-lg">
                      <div className="flex items-center space-x-3">
                        <input type="checkbox" className="h-4 w-4 text-indigo-600 rounded" />
                        <span className="font-medium text-gray-900 dark:text-white">{day}</span>
                      </div>
                      <div className="flex space-x-2">
                        <input
                          type="time"
                          defaultValue="09:00"
                          className="px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg text-sm dark:bg-slate-600 dark:text-white"
                        />
                        <span className="text-gray-600 dark:text-gray-400">to</span>
                        <input
                          type="time"
                          defaultValue="17:00"
                          className="px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg text-sm dark:bg-slate-600 dark:text-white"
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {currentStep === 5 && (
              <div className="text-center">
                <div className="text-6xl mb-4">🎉</div>
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                  You're All Set!
                </h2>
                <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
                  Your profile is under review. We'll notify you once it's approved.
                </p>
                <div className="bg-indigo-50 dark:bg-indigo-900/20 rounded-lg p-6 text-left">
                  <h3 className="font-semibold text-gray-900 dark:text-white mb-3">Next Steps:</h3>
                  <ul className="space-y-2 text-gray-600 dark:text-gray-400">
                    <li className="flex items-start">
                      <svg className="w-5 h-5 text-green-500 mr-2 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      Profile review (typically 1-2 business days)
                    </li>
                    <li className="flex items-start">
                      <svg className="w-5 h-5 text-green-500 mr-2 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      Background check completion
                    </li>
                    <li className="flex items-start">
                      <svg className="w-5 h-5 text-green-500 mr-2 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      Start accepting clients!
                    </li>
                  </ul>
                </div>
              </div>
            )}

            {/* Navigation Buttons */}
            <div className="flex justify-between mt-8">
              <button
                onClick={prevStep}
                disabled={currentStep === 1}
                className="px-6 py-3 border border-gray-300 dark:border-slate-600 rounded-lg font-semibold text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-slate-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              <button
                onClick={nextStep}
                className="px-6 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-lg font-semibold hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg"
              >
                {currentStep === steps.length ? 'Go to Dashboard' : 'Next'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}

