// Authentication and Session Management for MindVault
// This script handles user authentication and session management

class AuthManager {
    constructor() {
        this.currentUser = null;
        this.isAuthenticated = false;
        this.init();
    }

    init() {
        // Check if user is logged in
        const isLoggedIn = localStorage.getItem('isLoggedIn');
        const userId = localStorage.getItem('userId');
        
        if (isLoggedIn === 'true' && userId) {
            this.isAuthenticated = true;
            this.loadUserData(userId);
        }
    }

    async loadUserData(userId) {
        try {
            if (window.mindVaultDB) {
                this.currentUser = await mindVaultDB.getUserById(userId);
            } else {
                // Fallback to localStorage
                const userData = localStorage.getItem('userData');
                if (userData) {
                    this.currentUser = JSON.parse(userData);
                }
            }
        } catch (error) {
            console.error('Error loading user data:', error);
            this.logout();
        }
    }

    isLoggedIn() {
        return this.isAuthenticated && this.currentUser !== null;
    }

    getCurrentUser() {
        return this.currentUser;
    }

    getUserId() {
        return this.currentUser ? this.currentUser.id : null;
    }

    getUserPlan() {
        return this.currentUser ? this.currentUser.plan : 'basic';
    }

    getTrialStatus() {
        if (!this.currentUser) return null;
        
        const now = new Date();
        const trialEnd = new Date(this.currentUser.trialEnd);
        const remainingDays = Math.ceil((trialEnd - now) / (1000 * 60 * 60 * 24));
        
        return {
            isActive: remainingDays > 0,
            remainingDays: Math.max(0, remainingDays),
            trialEnd: trialEnd,
            plan: this.currentUser.plan
        };
    }

    hasFeatureAccess(feature) {
        if (!this.currentUser) return false;
        
        const plan = this.currentUser.plan;
        const trialStatus = this.getTrialStatus();
        
        // Basic features available to all users
        const basicFeatures = ['anonymous_sharing', 'mood_tracking', 'ai_insights_basic', 'crisis_support'];
        
        // Premium features
        const premiumFeatures = ['counselor_matching', 'peer_support', 'unlimited_ai_insights', 'advanced_analytics'];
        
        // Professional features
        const professionalFeatures = ['counselor_dashboard', 'client_management', 'api_access'];
        
        if (basicFeatures.includes(feature)) {
            return true;
        }
        
        if (premiumFeatures.includes(feature)) {
            return plan === 'premium' || plan === 'professional' || (trialStatus && trialStatus.isActive);
        }
        
        if (professionalFeatures.includes(feature)) {
            return plan === 'professional' || (trialStatus && trialStatus.isActive && plan === 'professional');
        }
        
        return false;
    }

    logout() {
        this.currentUser = null;
        this.isAuthenticated = false;
        
        // Clear localStorage
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('userId');
        localStorage.removeItem('userName');
        localStorage.removeItem('userData');
        
        // Redirect to login page
        window.location.href = 'login.html';
    }

    requireAuth() {
        if (!this.isLoggedIn()) {
            window.location.href = 'login.html';
            return false;
        }
        return true;
    }

    requireFeature(feature) {
        if (!this.requireAuth()) {
            return false;
        }
        
        if (!this.hasFeatureAccess(feature)) {
            // Redirect to subscription page
            window.location.href = 'subscription.html';
            return false;
        }
        
        return true;
    }

    // Update user data
    async updateUser(updates) {
        if (!this.currentUser) return false;
        
        try {
            if (window.mindVaultDB) {
                const updatedUser = await mindVaultDB.updateUser(this.currentUser.id, updates);
                this.currentUser = updatedUser;
                
                // Update localStorage
                localStorage.setItem('userData', JSON.stringify(updatedUser));
                
                return true;
            }
        } catch (error) {
            console.error('Error updating user:', error);
            return false;
        }
    }

    // Check if user needs to upgrade
    needsUpgrade() {
        const trialStatus = this.getTrialStatus();
        return trialStatus && !trialStatus.isActive && this.currentUser.plan === 'basic';
    }

    // Get upgrade prompt message
    getUpgradeMessage() {
        const trialStatus = this.getTrialStatus();
        
        if (trialStatus && trialStatus.isActive) {
            return `Your ${trialStatus.plan} trial has ${trialStatus.remainingDays} days remaining.`;
        } else if (this.needsUpgrade()) {
            return 'Your trial has expired. Upgrade to continue using premium features.';
        }
        
        return null;
    }
}

// Initialize authentication manager
const authManager = new AuthManager();

// Helper functions for easy access
function isLoggedIn() {
    return authManager.isLoggedIn();
}

function getCurrentUser() {
    return authManager.getCurrentUser();
}

function getUserPlan() {
    return authManager.getUserPlan();
}

function hasFeatureAccess(feature) {
    return authManager.hasFeatureAccess(feature);
}

function requireAuth() {
    return authManager.requireAuth();
}

function requireFeature(feature) {
    return authManager.requireFeature(feature);
}

function logout() {
    authManager.logout();
}

function getTrialStatus() {
    return authManager.getTrialStatus();
}

// Auto-redirect if not authenticated (for protected pages)
document.addEventListener('DOMContentLoaded', function() {
    // List of pages that require authentication
    const protectedPages = ['dashboard.html', 'share.html', 'insights.html'];
    const currentPage = window.location.pathname.split('/').pop();
    
    if (protectedPages.includes(currentPage)) {
        if (!requireAuth()) {
            return; // Will redirect to login
        }
        
        // Update UI with user data
        const user = getCurrentUser();
        if (user) {
            // Update welcome messages
            const welcomeElements = document.querySelectorAll('[id*="welcome"], [id*="user-name"]');
            welcomeElements.forEach(element => {
                if (element.textContent.includes('User') || element.textContent.includes('Welcome')) {
                    element.textContent = element.textContent.replace('User', user.firstName);
                }
            });
        }
    }
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AuthManager;
} else {
    window.AuthManager = AuthManager;
    window.authManager = authManager;
}
