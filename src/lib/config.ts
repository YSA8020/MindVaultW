// MindVault Configuration for Next.js
// Centralized configuration with environment variable support

export const CONFIG = {
  // Environment detection
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
  
  // API Configuration
  api: {
    supabase: {
      url: process.env.NEXT_PUBLIC_SUPABASE_URL || '',
      anonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '',
    },
    
    // API endpoints (for potential API routes)
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      posts: '/api/posts',
      insights: '/api/insights',
      mood: '/api/mood',
      counselors: '/api/counselors',
    },
    
    // Request settings
    timeout: 30000, // 30 seconds
    retryAttempts: 3,
    retryDelay: 1000, // 1 second
  },
  
  // Feature flags
  features: {
    analytics: true,
    errorReporting: true,
    debugMode: process.env.NODE_ENV === 'development',
    maintenanceMode: false,
    
    // Feature toggles
    enablePeerSupport: true,
    enableCounselorMatching: true,
    enableAIInsights: true,
    enableProgressTracking: true,
    enableCrisisSupport: true,
    enableEmergencyResponse: true,
  },
  
  // UI Configuration
  ui: {
    defaultTheme: 'light' as const,
    enableDarkMode: true,
    enableAnimations: true,
    
    // Pagination
    postsPerPage: 10,
    insightsPerPage: 5,
    counselorsPerPage: 20,
  },
  
  // Security Configuration
  security: {
    // Password requirements
    minPasswordLength: 8,
    requireSpecialChars: true,
    requireNumbers: true,
    requireUppercase: true,
    
    // Session settings
    sessionTimeout: 24 * 60 * 60 * 1000, // 24 hours
    rememberMeDuration: 30 * 24 * 60 * 60 * 1000, // 30 days
    
    // Rate limiting
    maxLoginAttempts: 5,
    lockoutDuration: 15 * 60 * 1000, // 15 minutes
    maxRequestsPerMinute: 60,
  },
  
  // Analytics Configuration
  analytics: {
    gaTrackingId: process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID || 'G-V1ZZ3VLV2L',
    trackUserActions: true,
    trackPageViews: true,
    trackErrors: true,
    trackPerformance: true,
  },
  
  // Content Configuration
  content: {
    defaultSupportGroups: [
      'Anxiety Support',
      'Depression Support',
      'Stress Management',
      'Grief and Loss',
      'Addiction Recovery',
      'Trauma Support',
      'LGBTQ+ Support',
      'Youth Support',
    ],
    
    defaultExperienceLevels: [
      'Just starting my journey',
      'Some experience with therapy',
      'Experienced with mental health support',
      'Peer supporter',
      'Professional counselor',
    ],
    
    // Crisis resources
    crisisResources: {
      nationalSuicidePreventionLifeline: '988',
      crisisTextLine: '741741',
      emergencyNumber: '911',
    },
  },
  
  // Subscription Configuration
  subscription: {
    trialDurationDays: 14,
    
    plans: {
      basic: {
        name: 'Basic',
        price: { monthly: 0, annual: 0 },
        features: ['mood_tracking', 'basic_insights', 'peer_support'],
        limits: {
          insightsPerDay: 3,
          postsPerDay: 5,
          counselorSessions: 0,
        },
      },
      premium: {
        name: 'Premium',
        price: { monthly: 19.99, annual: 199.99 },
        features: ['mood_tracking', 'advanced_insights', 'peer_support', 'counselor_matching'],
        limits: {
          insightsPerDay: 10,
          postsPerDay: 20,
          counselorSessions: 2,
        },
      },
      professional: {
        name: 'Professional',
        price: { monthly: 49.99, annual: 499.99 },
        features: [
          'mood_tracking',
          'premium_insights',
          'peer_support',
          'unlimited_counselor_sessions',
          'crisis_support',
        ],
        limits: {
          insightsPerDay: -1, // unlimited
          postsPerDay: -1, // unlimited
          counselorSessions: -1, // unlimited
        },
      },
    },
  },
} as const;

// Utility functions
export const ConfigUtils = {
  // Check if feature is enabled
  isFeatureEnabled: (feature: keyof typeof CONFIG.features): boolean => {
    return CONFIG.features[feature] === true;
  },
  
  // Get plan configuration
  getPlanConfig: (planName: 'basic' | 'premium' | 'professional') => {
    return CONFIG.subscription.plans[planName] || CONFIG.subscription.plans.basic;
  },
  
  // Check if user has access to feature
  hasFeatureAccess: (userPlan: 'basic' | 'premium' | 'professional', feature: string): boolean => {
    const planConfig = ConfigUtils.getPlanConfig(userPlan);
    return planConfig.features.includes(feature as any);
  },
  
  // Get API endpoint
  getApiEndpoint: (endpoint: keyof typeof CONFIG.api.endpoints): string => {
    return CONFIG.api.endpoints[endpoint];
  },
  
  // Check if in maintenance mode
  isMaintenanceMode: (): boolean => {
    return CONFIG.features.maintenanceMode;
  },
  
  // Validate environment
  validateEnvironment: (): { isValid: boolean; errors: string[] } => {
    const errors: string[] = [];
    
    if (!CONFIG.api.supabase.url) {
      errors.push('NEXT_PUBLIC_SUPABASE_URL is not set');
    }
    
    if (!CONFIG.api.supabase.anonKey) {
      errors.push('NEXT_PUBLIC_SUPABASE_ANON_KEY is not set');
    }
    
    return {
      isValid: errors.length === 0,
      errors,
    };
  },
};

export default CONFIG;

