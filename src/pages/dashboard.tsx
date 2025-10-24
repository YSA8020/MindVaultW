import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Layout from '@/components/layout/Layout';
import { useAuth } from '@/hooks/useAuth';
import { SupabaseService, MoodEntry } from '@/lib/supabase';

const moods = [
  { emoji: '😊', label: 'Great', score: 5, color: 'bg-green-500' },
  { emoji: '🙂', label: 'Good', score: 4, color: 'bg-blue-500' },
  { emoji: '😐', label: 'Okay', score: 3, color: 'bg-yellow-500' },
  { emoji: '😟', label: 'Low', score: 2, color: 'bg-orange-500' },
  { emoji: '😢', label: 'Struggling', score: 1, color: 'bg-red-500' },
];

export default function Dashboard() {
  const router = useRouter();
  const { user, isAuthenticated, loading, getTrialStatus, hasFeatureAccess } = useAuth();
  const [selectedMood, setSelectedMood] = useState<number | null>(null);
  const [moodNote, setMoodNote] = useState('');
  const [recentMoods, setRecentMoods] = useState<MoodEntry[]>([]);
  const [savingMood, setSavingMood] = useState(false);

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, loading, router]);

  useEffect(() => {
    if (user) {
      loadRecentMoods();
    }
  }, [user]);

  const loadRecentMoods = async () => {
    if (!user) return;
    
    const moods = await SupabaseService.getMoodEntries(user.id, 7);
    setRecentMoods(moods);
  };

  const handleSaveMood = async () => {
    if (selectedMood === null || !user) return;

    setSavingMood(true);
    try {
      const moodData = moods.find(m => m.score === selectedMood);
      if (!moodData) return;

      await SupabaseService.createMoodEntry({
        user_id: user.id,
        mood: moodData.label,
        mood_score: moodData.score,
        notes: moodNote || undefined,
      });

      // Reload moods
      await loadRecentMoods();
      
      // Reset form
      setSelectedMood(null);
      setMoodNote('');
      
      alert('Mood logged successfully!');
    } catch (error) {
      console.error('Error saving mood:', error);
      alert('Failed to save mood');
    } finally {
      setSavingMood(false);
    }
  };

  const trialStatus = getTrialStatus();

  if (loading) {
    return (
      <Layout title="Dashboard - MindVault">
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
            <p className="mt-4 text-gray-600 dark:text-gray-400">Loading...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (!user) return null;

  return (
    <Layout title="Dashboard - MindVault">
      <div className="pt-20 pb-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          {/* Trial Banner */}
          {trialStatus && trialStatus.isActive && (
            <div className="mb-6 bg-gradient-to-r from-indigo-500 to-purple-600 text-white rounded-lg p-4 shadow-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-semibold">🎉 Premium Trial Active</p>
                  <p className="text-sm opacity-90">
                    {trialStatus.remainingDays} days remaining • Upgrade anytime to keep your premium features
                  </p>
                </div>
                <Link
                  href="/subscription"
                  className="bg-white text-indigo-600 px-4 py-2 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
                >
                  Upgrade Now
                </Link>
              </div>
            </div>
          )}

          {/* Welcome Section */}
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">
              Welcome back, {user.first_name}!
            </h1>
            <p className="text-lg text-gray-600 dark:text-gray-400">
              How are you feeling today?
            </p>
          </div>

          {/* Mood Tracking Card */}
          <div className="bg-white dark:bg-slate-800 rounded-2xl shadow-xl p-8 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
              Track Your Mood
            </h2>
            
            <div className="flex justify-center space-x-4 mb-6">
              {moods.map((mood) => (
                <button
                  key={mood.score}
                  onClick={() => setSelectedMood(mood.score)}
                  className={`flex flex-col items-center p-4 rounded-xl transition-all ${
                    selectedMood === mood.score
                      ? 'bg-indigo-100 dark:bg-indigo-900/30 scale-110 shadow-lg'
                      : 'hover:bg-gray-100 dark:hover:bg-slate-700'
                  }`}
                >
                  <span className="text-4xl mb-2">{mood.emoji}</span>
                  <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
                    {mood.label}
                  </span>
                </button>
              ))}
            </div>

            {selectedMood !== null && (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Add a note (optional)
                  </label>
                  <textarea
                    value={moodNote}
                    onChange={(e) => setMoodNote(e.target.value)}
                    className="w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent dark:bg-slate-700 dark:text-white"
                    rows={3}
                    placeholder="What's on your mind?"
                  />
                </div>
                <button
                  onClick={handleSaveMood}
                  disabled={savingMood}
                  className="w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white py-3 rounded-lg font-semibold hover:from-indigo-700 hover:to-purple-700 transition-all disabled:opacity-50"
                >
                  {savingMood ? 'Saving...' : 'Save Mood'}
                </button>
              </div>
            )}

            {/* Recent Moods */}
            {recentMoods.length > 0 && (
              <div className="mt-8 pt-8 border-t border-gray-200 dark:border-slate-700">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                  Recent Entries
                </h3>
                <div className="space-y-2">
                  {recentMoods.slice(0, 5).map((entry) => (
                    <div
                      key={entry.id}
                      className="flex items-center justify-between p-3 bg-gray-50 dark:bg-slate-700 rounded-lg"
                    >
                      <div className="flex items-center space-x-3">
                        <span className="text-2xl">
                          {moods.find(m => m.score === entry.mood_score)?.emoji}
                        </span>
                        <div>
                          <p className="font-medium text-gray-900 dark:text-white">
                            {entry.mood}
                          </p>
                          {entry.notes && (
                            <p className="text-sm text-gray-600 dark:text-gray-400">
                              {entry.notes}
                            </p>
                          )}
                        </div>
                      </div>
                      <span className="text-sm text-gray-500 dark:text-gray-400">
                        {new Date(entry.created_at).toLocaleDateString()}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Features Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* AI Insights */}
            <Link
              href="/insights"
              className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1"
            >
              <div className="w-12 h-12 bg-indigo-100 dark:bg-indigo-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                AI Insights
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Get personalized insights from your mood patterns
              </p>
            </Link>

            {/* Counselor Matching */}
            <Link
              href="/counselor-matching"
              className={`bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 ${
                !hasFeatureAccess('counselor_matching') ? 'opacity-60' : ''
              }`}
            >
              <div className="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                Find a Counselor
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Connect with licensed professionals
              </p>
              {!hasFeatureAccess('counselor_matching') && (
                <span className="inline-block mt-2 px-2 py-1 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-400 text-xs font-semibold rounded">
                  Premium
                </span>
              )}
            </Link>

            {/* Peer Support */}
            <Link
              href="/peer-support"
              className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1"
            >
              <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                Peer Support
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Connect with others on similar journeys
              </p>
            </Link>

            {/* Progress Tracking */}
            <Link
              href="/progress-tracking"
              className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1"
            >
              <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                Track Progress
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Visualize your mental health journey
              </p>
            </Link>

            {/* Anonymous Sharing */}
            <Link
              href="/anonymous-sharing"
              className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1"
            >
              <div className="w-12 h-12 bg-pink-100 dark:bg-pink-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-pink-600 dark:text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                Anonymous Sharing
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Share your thoughts safely and anonymously
              </p>
            </Link>

            {/* Crisis Support */}
            <Link
              href="/crisis-support"
              className="bg-white dark:bg-slate-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 border-2 border-red-200 dark:border-red-800"
            >
              <div className="w-12 h-12 bg-red-100 dark:bg-red-900/30 rounded-lg flex items-center justify-center mb-4">
                <svg className="w-6 h-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                Crisis Support
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                Get immediate help if you're in crisis
              </p>
            </Link>
          </div>
        </div>
      </div>
    </Layout>
  );
}


