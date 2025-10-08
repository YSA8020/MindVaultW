// MindVault Error Handling System
// Production-ready error handling and logging

class MindVaultErrorHandler {
    constructor() {
        this.initialized = false;
        this.errorQueue = [];
        this.maxQueueSize = 100;
        this.flushInterval = 30000; // 30 seconds
    }

    async init() {
        try {
            // Set up global error handlers
            this.setupGlobalErrorHandlers();
            
            // Set up periodic error flushing
            this.setupErrorFlushing();
            
            this.initialized = true;
            console.log('Error handler initialized');
        } catch (error) {
            console.error('Failed to initialize error handler:', error);
        }
    }

    setupGlobalErrorHandlers() {
        // Handle uncaught JavaScript errors
        window.addEventListener('error', (event) => {
            this.handleError({
                type: 'javascript_error',
                message: event.message,
                filename: event.filename,
                lineno: event.lineno,
                colno: event.colno,
                stack: event.error?.stack,
                timestamp: new Date().toISOString(),
                url: window.location.href,
                userAgent: navigator.userAgent
            });
        });

        // Handle unhandled promise rejections
        window.addEventListener('unhandledrejection', (event) => {
            this.handleError({
                type: 'unhandled_promise_rejection',
                message: event.reason?.message || 'Unhandled promise rejection',
                stack: event.reason?.stack,
                timestamp: new Date().toISOString(),
                url: window.location.href,
                userAgent: navigator.userAgent
            });
        });

        // Handle network errors
        window.addEventListener('offline', () => {
            this.handleError({
                type: 'network_error',
                message: 'Network connection lost',
                timestamp: new Date().toISOString(),
                url: window.location.href
            });
        });

        window.addEventListener('online', () => {
            this.logInfo('Network connection restored');
        });
    }

    setupErrorFlushing() {
        // Flush errors periodically
        setInterval(() => {
            this.flushErrors();
        }, this.flushInterval);
    }

    handleError(errorData) {
        try {
            // Add error to queue
            this.errorQueue.push({
                id: this.generateErrorId(),
                ...errorData,
                severity: this.determineSeverity(errorData),
                userId: this.getCurrentUserId(),
                sessionId: this.getSessionId()
            });

            // Keep queue size manageable
            if (this.errorQueue.length > this.maxQueueSize) {
                this.errorQueue.shift(); // Remove oldest error
            }

            // Log to console in development
            if (CONFIG?.isDevelopment || CONFIG?.features?.debugMode) {
                console.error('Error captured:', errorData);
            }

            // Show user-friendly error message if needed
            if (this.shouldShowUserError(errorData)) {
                this.showUserError(errorData);
            }

            // Immediately flush critical errors
            if (this.isCriticalError(errorData)) {
                this.flushErrors();
            }
        } catch (error) {
            console.error('Error in error handler:', error);
        }
    }

    logError(message, error = null, context = {}) {
        this.handleError({
            type: 'application_error',
            message: message,
            stack: error?.stack,
            context: context,
            timestamp: new Date().toISOString(),
            url: window.location.href
        });
    }

    logWarning(message, context = {}) {
        this.handleError({
            type: 'warning',
            message: message,
            context: context,
            timestamp: new Date().toISOString(),
            url: window.location.href,
            severity: 'warning'
        });
    }

    logInfo(message, context = {}) {
        if (CONFIG?.isDevelopment || CONFIG?.features?.debugMode) {
            console.log('Info:', message, context);
        }
    }

    determineSeverity(errorData) {
        const criticalKeywords = ['fatal', 'critical', 'crash', 'security', 'auth'];
        const errorMessage = (errorData.message || '').toLowerCase();
        
        if (criticalKeywords.some(keyword => errorMessage.includes(keyword))) {
            return 'critical';
        }
        
        if (errorData.type === 'network_error') {
            return 'high';
        }
        
        if (errorData.type === 'javascript_error') {
            return 'medium';
        }
        
        return 'low';
    }

    isCriticalError(errorData) {
        return errorData.severity === 'critical' || 
               errorData.type === 'security_error' ||
               errorData.message?.includes('authentication');
    }

    shouldShowUserError(errorData) {
        // Don't show technical errors to users
        if (errorData.type === 'javascript_error' && !CONFIG?.isDevelopment) {
            return false;
        }
        
        // Show network errors
        if (errorData.type === 'network_error') {
            return true;
        }
        
        // Show authentication errors
        if (errorData.message?.includes('authentication') || 
            errorData.message?.includes('login')) {
            return true;
        }
        
        return false;
    }

    showUserError(errorData) {
        // Create user-friendly error messages
        let userMessage = 'Something went wrong. Please try again.';
        
        if (errorData.type === 'network_error') {
            userMessage = 'Network connection issue. Please check your internet connection.';
        } else if (errorData.message?.includes('authentication')) {
            userMessage = 'Authentication failed. Please log in again.';
        } else if (errorData.message?.includes('permission')) {
            userMessage = 'You don\'t have permission to perform this action.';
        }
        
        // Show notification (you can customize this based on your UI)
        this.showNotification(userMessage, 'error');
    }

    showNotification(message, type = 'info') {
        // Create a simple notification system
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 p-4 rounded-lg shadow-lg z-50 ${
            type === 'error' ? 'bg-red-500 text-white' :
            type === 'warning' ? 'bg-yellow-500 text-black' :
            'bg-blue-500 text-white'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 5000);
    }

    async flushErrors() {
        if (this.errorQueue.length === 0) {
            return;
        }
        
        try {
            // In production, send errors to your error reporting service
            if (CONFIG?.isProduction && CONFIG?.errorReporting?.reportToServer) {
                await this.sendErrorsToServer(this.errorQueue);
            }
            
            // Clear the queue after successful send
            this.errorQueue = [];
        } catch (error) {
            console.error('Failed to flush errors:', error);
        }
    }

    async sendErrorsToServer(errors) {
        // This would send errors to your error reporting service
        // For now, we'll just log them
        console.log('Sending errors to server:', errors.length, 'errors');
        
        // Example: Send to your backend API
        // await fetch('/api/errors', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({ errors })
        // });
    }

    generateErrorId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    getCurrentUserId() {
        return localStorage.getItem('userId') || 'anonymous';
    }

    getSessionId() {
        let sessionId = sessionStorage.getItem('sessionId');
        if (!sessionId) {
            sessionId = this.generateErrorId();
            sessionStorage.setItem('sessionId', sessionId);
        }
        return sessionId;
    }

    // Public API methods
    static async init() {
        const handler = new MindVaultErrorHandler();
        await handler.init();
        return handler;
    }

    static logError(message, error = null, context = {}) {
        if (window.mindVaultErrorHandler) {
            window.mindVaultErrorHandler.logError(message, error, context);
        } else {
            console.error('Error handler not initialized:', message, error, context);
        }
    }

    static logWarning(message, context = {}) {
        if (window.mindVaultErrorHandler) {
            window.mindVaultErrorHandler.logWarning(message, context);
        } else {
            console.warn('Warning:', message, context);
        }
    }

    static logInfo(message, context = {}) {
        if (window.mindVaultErrorHandler) {
            window.mindVaultErrorHandler.logInfo(message, context);
        } else {
            console.log('Info:', message, context);
        }
    }
}

// Initialize error handler when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    try {
        window.mindVaultErrorHandler = await MindVaultErrorHandler.init();
        console.log('Error handler ready');
    } catch (error) {
        console.error('Failed to initialize error handler:', error);
    }
});

// Create global ErrorHandler instance
const ErrorHandler = new MindVaultErrorHandler();

// Initialize ErrorHandler
ErrorHandler.init();

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { MindVaultErrorHandler, ErrorHandler };
} else {
    window.MindVaultErrorHandler = MindVaultErrorHandler;
    window.ErrorHandler = ErrorHandler;
}
