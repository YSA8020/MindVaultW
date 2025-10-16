// MindVault Production Logging System
// Comprehensive logging for production monitoring

class MindVaultLogger {
    constructor() {
        this.initialized = false;
        this.logQueue = [];
        this.maxQueueSize = 50;
        this.flushInterval = 60000; // 1 minute
        this.sessionId = this.generateSessionId();
        this.userId = null;
        this.pageLoadTime = Date.now();
    }

    async init() {
        try {
            // Set up user tracking
            this.setupUserTracking();
            
            // Set up performance monitoring
            this.setupPerformanceMonitoring();
            
            // Set up user interaction tracking
            this.setupInteractionTracking();
            
            // Set up periodic log flushing
            this.setupLogFlushing();
            
            this.initialized = true;
            console.log('Production logger initialized');
        } catch (error) {
            console.error('Failed to initialize production logger:', error);
        }
    }

    setupUserTracking() {
        // Track user login/logout
        document.addEventListener('userLogin', (event) => {
            this.userId = event.detail.userId;
            this.logEvent('user_login', {
                userId: this.userId,
                timestamp: new Date().toISOString()
            });
        });

        document.addEventListener('userLogout', (event) => {
            this.logEvent('user_logout', {
                userId: this.userId,
                timestamp: new Date().toISOString()
            });
            this.userId = null;
        });

        // Track page views
        this.logEvent('page_view', {
            url: window.location.href,
            referrer: document.referrer,
            timestamp: new Date().toISOString()
        });
    }

    setupPerformanceMonitoring() {
        // Track page load performance
        window.addEventListener('load', () => {
            const loadTime = Date.now() - this.pageLoadTime;
            this.logEvent('page_load_performance', {
                loadTime: loadTime,
                url: window.location.href,
                timestamp: new Date().toISOString()
            });
        });

        // Track Core Web Vitals
        if ('PerformanceObserver' in window) {
            // Largest Contentful Paint
            new PerformanceObserver((entryList) => {
                const entries = entryList.getEntries();
                const lastEntry = entries[entries.length - 1];
                this.logEvent('core_web_vital', {
                    metric: 'LCP',
                    value: lastEntry.startTime,
                    url: window.location.href,
                    timestamp: new Date().toISOString()
                });
            }).observe({ entryTypes: ['largest-contentful-paint'] });

            // First Input Delay
            new PerformanceObserver((entryList) => {
                const entries = entryList.getEntries();
                entries.forEach(entry => {
                    this.logEvent('core_web_vital', {
                        metric: 'FID',
                        value: entry.processingStart - entry.startTime,
                        url: window.location.href,
                        timestamp: new Date().toISOString()
                    });
                });
            }).observe({ entryTypes: ['first-input'] });

            // Cumulative Layout Shift
            new PerformanceObserver((entryList) => {
                const entries = entryList.getEntries();
                entries.forEach(entry => {
                    if (!entry.hadRecentInput) {
                        this.logEvent('core_web_vital', {
                            metric: 'CLS',
                            value: entry.value,
                            url: window.location.href,
                            timestamp: new Date().toISOString()
                        });
                    }
                });
            }).observe({ entryTypes: ['layout-shift'] });
        }
    }

    setupInteractionTracking() {
        // Track form submissions
        document.addEventListener('submit', (event) => {
            const form = event.target;
            if (form.tagName === 'FORM') {
                this.logEvent('form_submission', {
                    formId: form.id,
                    formAction: form.action,
                    formMethod: form.method,
                    url: window.location.href,
                    timestamp: new Date().toISOString()
                });
            }
        });

        // Track button clicks
        document.addEventListener('click', (event) => {
            const target = event.target;
            if (target.tagName === 'BUTTON' || target.tagName === 'A') {
                this.logEvent('button_click', {
                    elementId: target.id,
                    elementClass: target.className,
                    elementText: target.textContent?.trim().substring(0, 100),
                    url: window.location.href,
                    timestamp: new Date().toISOString()
                });
            }
        });

        // Track navigation
        let lastUrl = window.location.href;
        setInterval(() => {
            if (window.location.href !== lastUrl) {
                this.logEvent('navigation', {
                    from: lastUrl,
                    to: window.location.href,
                    timestamp: new Date().toISOString()
                });
                lastUrl = window.location.href;
            }
        }, 1000);
    }

    setupLogFlushing() {
        // Flush logs periodically
        setInterval(() => {
            this.flushLogs();
        }, this.flushInterval);

        // Flush logs before page unload
        window.addEventListener('beforeunload', () => {
            this.flushLogs();
        });
    }

    logEvent(eventType, data = {}) {
        try {
            const logEntry = {
                id: this.generateLogId(),
                eventType,
                data,
                userId: this.userId,
                sessionId: this.sessionId,
                url: window.location.href,
                userAgent: navigator.userAgent,
                timestamp: new Date().toISOString(),
                viewport: {
                    width: window.innerWidth,
                    height: window.innerHeight
                },
                screen: {
                    width: screen.width,
                    height: screen.height
                }
            };

            this.logQueue.push(logEntry);

            // Keep queue size manageable
            if (this.logQueue.length > this.maxQueueSize) {
                this.logQueue.shift();
            }

            // Log to console in development
            if (CONFIG?.isDevelopment || CONFIG?.features?.debugMode) {
                console.log('Event logged:', logEntry);
            }
        } catch (error) {
            console.error('Failed to log event:', error);
        }
    }

    async flushLogs() {
        if (this.logQueue.length === 0) {
            return;
        }

        try {
            // Send logs to Supabase
            if (window.supabaseClient) {
                const { data, error } = await window.supabaseClient
                    .from('user_activity_logs')
                    .insert(this.logQueue.map(log => ({
                        log_id: log.id,
                        event_type: log.eventType,
                        event_data: log.data,
                        user_id: log.userId,
                        session_id: log.sessionId,
                        url: log.url,
                        user_agent: log.userAgent,
                        viewport: log.viewport,
                        screen: log.screen,
                        timestamp: log.timestamp
                    })));

                if (error) {
                    console.error('Failed to log events to Supabase:', error);
                } else {
                    console.log('Successfully logged', this.logQueue.length, 'events to Supabase');
                    this.logQueue = [];
                }
            }
        } catch (error) {
            console.error('Failed to flush logs:', error);
        }
    }

    // Public API methods
    static logEvent(eventType, data = {}) {
        if (window.mindVaultLogger) {
            window.mindVaultLogger.logEvent(eventType, data);
        } else {
            console.log('Logger not initialized:', eventType, data);
        }
    }

    static logUserAction(action, context = {}) {
        MindVaultLogger.logEvent('user_action', {
            action,
            ...context
        });
    }

    static logFeatureUsage(feature, context = {}) {
        MindVaultLogger.logEvent('feature_usage', {
            feature,
            ...context
        });
    }

    static logPerformance(metric, value, context = {}) {
        MindVaultLogger.logEvent('performance_metric', {
            metric,
            value,
            ...context
        });
    }

    generateLogId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    generateSessionId() {
        let sessionId = sessionStorage.getItem('mindVaultSessionId');
        if (!sessionId) {
            sessionId = this.generateLogId();
            sessionStorage.setItem('mindVaultSessionId', sessionId);
        }
        return sessionId;
    }
}

// Initialize logger when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    try {
        window.mindVaultLogger = new MindVaultLogger();
        await window.mindVaultLogger.init();
        console.log('Production logger ready');
    } catch (error) {
        console.error('Failed to initialize production logger:', error);
    }
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { MindVaultLogger };
} else {
    window.MindVaultLogger = MindVaultLogger;
}
