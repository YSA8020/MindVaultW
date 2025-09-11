// Production Configuration for MindVault
// This file should be updated with your actual Supabase credentials

const PRODUCTION_CONFIG = {
    // Supabase Configuration - Replace with your actual values
    SUPABASE_URL: 'YOUR_SUPABASE_URL', // e.g., 'https://your-project.supabase.co'
    SUPABASE_ANON_KEY: 'YOUR_SUPABASE_ANON_KEY', // Your anon key from Supabase dashboard
    
    // Environment
    ENVIRONMENT: 'production',
    
    // Features
    FEATURES: {
        USE_SUPABASE: true, // Set to false to use IndexedDB fallback
        ENABLE_ANALYTICS: true,
        ENABLE_CRISIS_SUPPORT: true,
        ENABLE_PAYMENT_PROCESSING: true
    },
    
    // API Configuration
    API: {
        TIMEOUT: 10000, // 10 seconds
        RETRY_ATTEMPTS: 3,
        RETRY_DELAY: 1000 // 1 second
    },
    
    // Security
    SECURITY: {
        PASSWORD_MIN_LENGTH: 8,
        SESSION_TIMEOUT: 24 * 60 * 60 * 1000, // 24 hours
        MAX_LOGIN_ATTEMPTS: 5
    }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PRODUCTION_CONFIG;
} else {
    window.PRODUCTION_CONFIG = PRODUCTION_CONFIG;
}
