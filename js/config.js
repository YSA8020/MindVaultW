// MindVault Production Configuration
// Environment-specific settings for different deployment stages

const CONFIG = {
    // Environment detection
    isDevelopment: window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1',
    isProduction: window.location.hostname.includes('github.io') || window.location.hostname.includes('mindvault'),
    
    // API Configuration
    api: {
        // Supabase configuration (already set in supabase-config.js)
        supabase: {
            url: SUPABASE_CONFIG.url,
            anonKey: SUPABASE_CONFIG.anonKey
        },
        
        // API endpoints
        endpoints: {
            base: window.location.origin,
            auth: '/auth',
            users: '/users',
            posts: '/posts',
            insights: '/insights',
            mood: '/mood',
            counselors: '/counselors'
        },
        
        // Request timeouts
        timeout: 30000, // 30 seconds
        retryAttempts: 3,
        retryDelay: 1000 // 1 second
    },
    
    // Feature flags
    features: {
        // Enable/disable features based on environment
        analytics: true,
        errorReporting: true,
        debugMode: false,
        maintenanceMode: false,
        
        // Feature toggles
        enablePeerSupport: true,
        enableCounselorMatching: true,
        enableAIInsights: true,
        enableProgressTracking: true,
        enableCrisisSupport: true,
        enableEmergencyResponse: true
    },
    
    // UI Configuration
    ui: {
        // Theme settings
        defaultTheme: 'light',
        enableDarkMode: true,
        enableAnimations: true,
        
        // Layout settings
        sidebarCollapsible: true,
        showNotifications: true,
        showUserStats: true,
        
        // Pagination
        postsPerPage: 10,
        insightsPerPage: 5,
        counselorsPerPage: 20
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
        maxRequestsPerMinute: 60
    },
    
    // Analytics Configuration
    analytics: {
        // Google Analytics (if enabled)
        gaTrackingId: null, // Set your GA4 tracking ID here (e.g., 'G-XXXXXXXXXX')
        
        // Custom analytics
        trackUserActions: true,
        trackPageViews: true,
        trackErrors: true,
        trackPerformance: true,
        trackConversions: true,
        trackEcommerce: true,
        
        // Custom dimensions (GA4)
        customDimensions: {
            userType: 1,        // 'user', 'professional', 'admin'
            subscriptionPlan: 2, // 'basic', 'premium', 'professional'
            licenseType: 3,     // For professionals
            supportGroup: 4,    // User's support group
            experienceLevel: 5  // User's experience level
        },
        
        // Event categories
        eventCategories: {
            user: 'user_interaction',
            professional: 'professional_action',
            system: 'system_event',
            error: 'error_event',
            performance: 'performance_metric'
        }
    },
    
    // Error Reporting
    errorReporting: {
        // Sentry configuration (if enabled)
        sentryDsn: null, // Set your Sentry DSN here
        
        // Error handling
        reportToConsole: true,
        reportToServer: true,
        showUserFriendlyErrors: true
    },
    
    // Content Configuration
    content: {
        // Default content
        defaultSupportGroups: [
            'Anxiety Support',
            'Depression Support',
            'Stress Management',
            'Grief and Loss',
            'Addiction Recovery',
            'Trauma Support',
            'LGBTQ+ Support',
            'Youth Support'
        ],
        
        defaultExperienceLevels: [
            'Just starting my journey',
            'Some experience with therapy',
            'Experienced with mental health support',
            'Peer supporter',
            'Professional counselor'
        ],
        
        // Crisis resources
        crisisResources: {
            nationalSuicidePreventionLifeline: '988',
            crisisTextLine: '741741',
            emergencyNumber: '911'
        }
    },
    
    // Subscription Configuration
    subscription: {
        // Trial settings
        trialDurationDays: 14,
        trialFeatures: ['basic_insights', 'peer_support', 'mood_tracking'],
        
        // Plan features
        plans: {
            basic: {
                name: 'Basic',
                price: { monthly: 0, annual: 0 },
                features: ['mood_tracking', 'basic_insights', 'peer_support'],
                limits: {
                    insightsPerDay: 3,
                    postsPerDay: 5,
                    counselorSessions: 0
                }
            },
            premium: {
                name: 'Premium',
                price: { monthly: 19.99, annual: 199.99 },
                features: ['mood_tracking', 'advanced_insights', 'peer_support', 'counselor_matching'],
                limits: {
                    insightsPerDay: 10,
                    postsPerDay: 20,
                    counselorSessions: 2
                }
            },
            professional: {
                name: 'Professional',
                price: { monthly: 49.99, annual: 499.99 },
                features: ['mood_tracking', 'premium_insights', 'peer_support', 'unlimited_counselor_sessions', 'crisis_support'],
                limits: {
                    insightsPerDay: -1, // unlimited
                    postsPerDay: -1, // unlimited
                    counselorSessions: -1 // unlimited
                }
            }
        }
    }
};

// Environment-specific overrides
if (CONFIG.isDevelopment) {
    // Development overrides
    CONFIG.features.debugMode = true;
    CONFIG.features.errorReporting = false;
    CONFIG.api.timeout = 60000; // Longer timeout for development
    CONFIG.security.sessionTimeout = 60 * 60 * 1000; // 1 hour for development
}

if (CONFIG.isProduction) {
    // Production overrides
    CONFIG.features.debugMode = false;
    CONFIG.features.errorReporting = true;
    CONFIG.ui.enableAnimations = true; // Keep animations in production
}

// Utility functions
CONFIG.utils = {
    // Check if feature is enabled
    isFeatureEnabled: (feature) => {
        return CONFIG.features[feature] === true;
    },
    
    // Get plan configuration
    getPlanConfig: (planName) => {
        return CONFIG.subscription.plans[planName] || CONFIG.subscription.plans.basic;
    },
    
    // Check if user has access to feature
    hasFeatureAccess: (userPlan, feature) => {
        const planConfig = CONFIG.utils.getPlanConfig(userPlan);
        return planConfig.features.includes(feature);
    },
    
    // Get API endpoint
    getApiEndpoint: (endpoint) => {
        return CONFIG.api.endpoints.base + CONFIG.api.endpoints[endpoint];
    },
    
    // Check if in maintenance mode
    isMaintenanceMode: () => {
        return CONFIG.features.maintenanceMode;
    }
};

// Export configuration
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
} else {
    window.CONFIG = CONFIG;
}

// Initialize configuration on load
document.addEventListener('DOMContentLoaded', () => {
    console.log('MindVault Configuration loaded:', {
        environment: CONFIG.isDevelopment ? 'development' : 'production',
        features: Object.keys(CONFIG.features).filter(key => CONFIG.features[key]),
        supabaseUrl: CONFIG.api.supabase.url
    });
});
