# MindVault Environment Configuration Template
# Copy this file to config.js and fill in your actual values

const CONFIG = {
    // Supabase Configuration
    SUPABASE_URL: 'https://your-project-id.supabase.co',
    SUPABASE_ANON_KEY: 'your-anon-key-here',
    
    // Environment
    ENVIRONMENT: 'development', // 'development' or 'production'
    
    // Features
    FEATURES: {
        USE_SUPABASE: true, // Set to false to use IndexedDB fallback
        ENABLE_ANALYTICS: true,
        ENABLE_CRISIS_SUPPORT: true
    }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
} else {
    window.CONFIG = CONFIG;
}
