// MindVault Analytics Configuration
// Google Analytics and custom analytics setup

class MindVaultAnalytics {
    constructor() {
        this.initialized = false;
        this.gaTrackingId = 'G-V1ZZ3VLV2L';
        this.userId = null;
        this.sessionId = null;
        this.debugMode = false;
    }

    async init(config = {}) {
        try {
            // Set configuration
            this.gaTrackingId = config.gaTrackingId || CONFIG?.analytics?.gaTrackingId;
            this.debugMode = config.debugMode || CONFIG?.isDevelopment || false;
            
            if (!this.gaTrackingId) {
                console.warn('Google Analytics tracking ID not provided');
                return;
            }

            // Initialize Google Analytics
            await this.initGoogleAnalytics();
            
            // Set up custom event tracking
            this.setupCustomEventTracking();
            
            // Set up user tracking
            this.setupUserTracking();
            
            this.initialized = true;
            console.log('Analytics initialized with GA ID:', this.gaTrackingId);
        } catch (error) {
            console.error('Failed to initialize analytics:', error);
        }
    }

    async initGoogleAnalytics() {
        // Load Google Analytics script
        const script = document.createElement('script');
        script.async = true;
        script.src = `https://www.googletagmanager.com/gtag/js?id=${this.gaTrackingId}`;
        document.head.appendChild(script);

        // Initialize gtag
        window.dataLayer = window.dataLayer || [];
        function gtag() {
            dataLayer.push(arguments);
        }
        window.gtag = gtag;

        gtag('js', new Date());
        gtag('config', this.gaTrackingId, {
            debug_mode: this.debugMode,
            send_page_view: true,
            anonymize_ip: true,
            cookie_flags: 'SameSite=None;Secure'
        });

        // Wait for script to load
        return new Promise((resolve) => {
            script.onload = () => {
                console.log('Google Analytics loaded');
                resolve();
            };
        });
    }

    setupCustomEventTracking() {
        // Track form submissions
        document.addEventListener('submit', (event) => {
            const form = event.target;
            if (form.tagName === 'FORM') {
                this.trackEvent('form_submit', {
                    form_id: form.id,
                    form_action: form.action,
                    form_method: form.method,
                    page_location: window.location.href
                });
            }
        });

        // Track button clicks
        document.addEventListener('click', (event) => {
            const target = event.target;
            if (target.tagName === 'BUTTON' || target.tagName === 'A') {
                this.trackEvent('button_click', {
                    button_id: target.id,
                    button_text: target.textContent?.trim().substring(0, 100),
                    button_class: target.className,
                    page_location: window.location.href
                });
            }
        });

        // Track file downloads
        document.addEventListener('click', (event) => {
            const target = event.target;
            if (target.tagName === 'A' && target.href) {
                const url = new URL(target.href);
                if (url.pathname.match(/\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|rar)$/i)) {
                    this.trackEvent('file_download', {
                        file_name: url.pathname.split('/').pop(),
                        file_extension: url.pathname.split('.').pop(),
                        page_location: window.location.href
                    });
                }
            }
        });

        // Track external links
        document.addEventListener('click', (event) => {
            const target = event.target;
            if (target.tagName === 'A' && target.href) {
                const url = new URL(target.href);
                if (url.hostname !== window.location.hostname) {
                    this.trackEvent('external_link_click', {
                        link_url: target.href,
                        link_text: target.textContent?.trim().substring(0, 100),
                        page_location: window.location.href
                    });
                }
            }
        });
    }

    setupUserTracking() {
        // Track user login
        document.addEventListener('userLogin', (event) => {
            this.userId = event.detail.userId;
            this.setUserId(this.userId);
            this.trackEvent('login', {
                method: event.detail.method || 'unknown',
                user_id: this.userId
            });
        });

        // Track user logout
        document.addEventListener('userLogout', (event) => {
            this.trackEvent('logout', {
                user_id: this.userId
            });
            this.userId = null;
            this.setUserId(null);
        });

        // Track user registration
        document.addEventListener('userRegistration', (event) => {
            this.trackEvent('sign_up', {
                method: event.detail.method || 'email',
                user_id: event.detail.userId
            });
        });

        // Track professional signup
        document.addEventListener('professionalSignup', (event) => {
            this.trackEvent('professional_signup', {
                license_type: event.detail.licenseType,
                professional_type: event.detail.professionalType,
                user_id: event.detail.userId
            });
        });
    }

    // Public API methods
    trackEvent(eventName, parameters = {}) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            // Track with Google Analytics
            if (window.gtag) {
                window.gtag('event', eventName, {
                    ...parameters,
                    custom_parameter_1: parameters.user_id || 'anonymous',
                    custom_parameter_2: this.sessionId,
                    custom_parameter_3: window.location.pathname
                });
            }

            // Also track with our custom logger
            if (window.MindVaultLogger) {
                MindVaultLogger.logEvent('analytics_event', {
                    event_name: eventName,
                    ...parameters
                });
            }

            if (this.debugMode) {
                console.log('Analytics event tracked:', eventName, parameters);
            }
        } catch (error) {
            console.error('Failed to track event:', error);
        }
    }

    trackPageView(pagePath = null, pageTitle = null) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            const path = pagePath || window.location.pathname;
            const title = pageTitle || document.title;

            if (window.gtag) {
                window.gtag('config', this.gaTrackingId, {
                    page_path: path,
                    page_title: title
                });
            }

            if (this.debugMode) {
                console.log('Page view tracked:', path, title);
            }
        } catch (error) {
            console.error('Failed to track page view:', error);
        }
    }

    setUserId(userId) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('config', this.gaTrackingId, {
                    user_id: userId
                });
            }

            this.userId = userId;
        } catch (error) {
            console.error('Failed to set user ID:', error);
        }
    }

    setUserProperties(properties) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('config', this.gaTrackingId, {
                    custom_map: properties
                });
            }
        } catch (error) {
            console.error('Failed to set user properties:', error);
        }
    }

    trackConversion(conversionId, value = null, currency = 'USD') {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('event', 'conversion', {
                    send_to: conversionId,
                    value: value,
                    currency: currency
                });
            }

            this.trackEvent('conversion', {
                conversion_id: conversionId,
                value: value,
                currency: currency
            });
        } catch (error) {
            console.error('Failed to track conversion:', error);
        }
    }

    // E-commerce tracking
    trackPurchase(transactionId, items, value, currency = 'USD') {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('event', 'purchase', {
                    transaction_id: transactionId,
                    value: value,
                    currency: currency,
                    items: items
                });
            }

            this.trackEvent('purchase', {
                transaction_id: transactionId,
                items: items,
                value: value,
                currency: currency
            });
        } catch (error) {
            console.error('Failed to track purchase:', error);
        }
    }

    // Custom dimensions and metrics
    setCustomDimension(index, value) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('config', this.gaTrackingId, {
                    [`custom_dimension_${index}`]: value
                });
            }
        } catch (error) {
            console.error('Failed to set custom dimension:', error);
        }
    }

    // Error tracking
    trackError(error, fatal = false) {
        if (!this.initialized) {
            console.warn('Analytics not initialized');
            return;
        }

        try {
            if (window.gtag) {
                window.gtag('event', 'exception', {
                    description: error.message,
                    fatal: fatal
                });
            }

            this.trackEvent('error', {
                error_message: error.message,
                error_stack: error.stack,
                fatal: fatal,
                page_location: window.location.href
            });
        } catch (err) {
            console.error('Failed to track error:', err);
        }
    }
}

// Initialize analytics when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    try {
        window.mindVaultAnalytics = new MindVaultAnalytics();
        
        // Initialize with configuration
        const config = {
            gaTrackingId: CONFIG?.analytics?.gaTrackingId,
            debugMode: CONFIG?.isDevelopment || false
        };
        
        await window.mindVaultAnalytics.init(config);
        console.log('Analytics ready');
    } catch (error) {
        console.error('Failed to initialize analytics:', error);
    }
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { MindVaultAnalytics };
} else {
    window.MindVaultAnalytics = MindVaultAnalytics;
}
