// MindVault Rate Limiting System
// Client-side rate limiting and request throttling

class RateLimiter {
    constructor() {
        this.requests = new Map(); // Track requests by endpoint
        this.blockedEndpoints = new Set(); // Track blocked endpoints
        this.maxRequests = 60; // Default max requests per hour
        this.windowMs = 60 * 60 * 1000; // 1 hour in milliseconds
    }

    // Check if request is allowed
    async checkRateLimit(endpoint, maxRequests = null, windowMs = null) {
        try {
            const key = endpoint;
            const now = Date.now();
            const maxReq = maxRequests || this.maxRequests;
            const window = windowMs || this.windowMs;

            // Check if endpoint is blocked
            if (this.blockedEndpoints.has(key)) {
                const blockedData = this.requests.get(key);
                if (blockedData && blockedData.blockedUntil > now) {
                    return {
                        allowed: false,
                        remaining: 0,
                        resetTime: blockedData.blockedUntil,
                        message: 'Rate limit exceeded. Please try again later.'
                    };
                } else {
                    // Unblock if time has passed
                    this.blockedEndpoints.delete(key);
                }
            }

            // Get or initialize request data
            let requestData = this.requests.get(key);
            
            if (!requestData || requestData.windowStart + window < now) {
                // New time window
                requestData = {
                    count: 0,
                    windowStart: now,
                    windowEnd: now + window
                };
                this.requests.set(key, requestData);
            }

            // Check if limit exceeded
            if (requestData.count >= maxReq) {
                // Block endpoint temporarily
                this.blockedEndpoints.add(key);
                requestData.blockedUntil = now + window;
                
                return {
                    allowed: false,
                    remaining: 0,
                    resetTime: requestData.blockedUntil,
                    message: 'Rate limit exceeded. Please try again later.'
                };
            }

            // Increment request count
            requestData.count++;

            return {
                allowed: true,
                remaining: maxReq - requestData.count,
                resetTime: requestData.windowEnd,
                message: null
            };
        } catch (error) {
            console.error('Rate limit check failed:', error);
            // Allow request on error (fail open)
            return {
                allowed: true,
                remaining: this.maxRequests,
                resetTime: Date.now() + this.windowMs,
                message: null
            };
        }
    }

    // Track request
    async trackRequest(endpoint) {
        const result = await this.checkRateLimit(endpoint);
        
        if (!result.allowed) {
            throw new Error(result.message || 'Rate limit exceeded');
        }
        
        return result;
    }

    // Get remaining requests for endpoint
    getRemainingRequests(endpoint) {
        const requestData = this.requests.get(endpoint);
        if (!requestData) {
            return this.maxRequests;
        }
        return Math.max(0, this.maxRequests - requestData.count);
    }

    // Reset rate limit for endpoint
    resetRateLimit(endpoint) {
        this.requests.delete(endpoint);
        this.blockedEndpoints.delete(endpoint);
    }

    // Reset all rate limits
    resetAll() {
        this.requests.clear();
        this.blockedEndpoints.clear();
    }

    // Set custom rate limit
    setRateLimit(maxRequests, windowMs) {
        this.maxRequests = maxRequests;
        this.windowMs = windowMs;
    }
}

// Request throttling wrapper
class RequestThrottler {
    constructor() {
        this.rateLimiter = new RateLimiter();
        this.pendingRequests = new Map();
        this.requestQueue = [];
        this.processing = false;
    }

    // Throttled request
    async throttleRequest(endpoint, requestFn, maxRequests = 60, windowMs = 60000) {
        try {
            // Check rate limit
            const rateLimit = await this.rateLimiter.checkRateLimit(endpoint, maxRequests, windowMs);
            
            if (!rateLimit.allowed) {
                throw new Error(rateLimit.message);
            }

            // Execute request
            const result = await requestFn();
            
            return {
                success: true,
                data: result,
                remainingRequests: rateLimit.remaining
            };
        } catch (error) {
            if (error.message.includes('Rate limit exceeded')) {
                return {
                    success: false,
                    error: error.message,
                    remainingRequests: 0
                };
            }
            throw error;
        }
    }

    // Queue request for later execution
    queueRequest(endpoint, requestFn, priority = 0) {
        this.requestQueue.push({
            endpoint,
            requestFn,
            priority,
            timestamp: Date.now()
        });

        // Sort by priority and timestamp
        this.requestQueue.sort((a, b) => {
            if (a.priority !== b.priority) {
                return b.priority - a.priority;
            }
            return a.timestamp - b.timestamp;
        });

        // Process queue
        this.processQueue();
    }

    // Process request queue
    async processQueue() {
        if (this.processing || this.requestQueue.length === 0) {
            return;
        }

        this.processing = true;

        while (this.requestQueue.length > 0) {
            const request = this.requestQueue.shift();
            
            try {
                await this.throttleRequest(request.endpoint, request.requestFn);
            } catch (error) {
                console.error('Queued request failed:', error);
            }

            // Small delay between requests
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        this.processing = false;
    }
}

// IP-based rate limiting
class IPRateLimiter {
    constructor() {
        this.ipRequests = new Map();
        this.blockedIPs = new Set();
        this.maxRequestsPerIP = 100; // Max requests per IP per hour
        this.windowMs = 60 * 60 * 1000; // 1 hour
    }

    async checkIPRateLimit(ipAddress) {
        try {
            const now = Date.now();

            // Check if IP is blocked
            if (this.blockedIPs.has(ipAddress)) {
                return {
                    allowed: false,
                    remaining: 0,
                    message: 'IP address has been temporarily blocked due to excessive requests.'
                };
            }

            // Get or initialize IP request data
            let ipData = this.ipRequests.get(ipAddress);
            
            if (!ipData || ipData.windowStart + this.windowMs < now) {
                ipData = {
                    count: 0,
                    windowStart: now,
                    windowEnd: now + this.windowMs
                };
                this.ipRequests.set(ipAddress, ipData);
            }

            // Check if limit exceeded
            if (ipData.count >= this.maxRequestsPerIP) {
                this.blockedIPs.add(ipAddress);
                
                return {
                    allowed: false,
                    remaining: 0,
                    message: 'IP address has been temporarily blocked due to excessive requests.'
                };
            }

            // Increment request count
            ipData.count++;

            return {
                allowed: true,
                remaining: this.maxRequestsPerIP - ipData.count,
                message: null
            };
        } catch (error) {
            console.error('IP rate limit check failed:', error);
            return {
                allowed: true,
                remaining: this.maxRequestsPerIP,
                message: null
            };
        }
    }

    blockIP(ipAddress, durationMs = 3600000) {
        this.blockedIPs.add(ipAddress);
        
        // Auto-unblock after duration
        setTimeout(() => {
            this.blockedIPs.delete(ipAddress);
        }, durationMs);
    }

    unblockIP(ipAddress) {
        this.blockedIPs.delete(ipAddress);
    }
}

// Failed login attempt tracker
class FailedLoginTracker {
    constructor() {
        this.attempts = new Map();
        this.maxAttempts = 5;
        this.lockoutDuration = 15 * 60 * 1000; // 15 minutes
        this.lockedAccounts = new Map();
    }

    recordFailedAttempt(email, ipAddress) {
        const key = `${email}:${ipAddress}`;
        const now = Date.now();

        // Get or initialize attempt data
        let attemptData = this.attempts.get(key);
        
        if (!attemptData) {
            attemptData = {
                count: 0,
                firstAttempt: now,
                lastAttempt: now
            };
            this.attempts.set(key, attemptData);
        }

        // Increment count
        attemptData.count++;
        attemptData.lastAttempt = now;

        // Check if account should be locked
        if (attemptData.count >= this.maxAttempts) {
            this.lockAccount(email, ipAddress);
            return {
                locked: true,
                attemptsRemaining: 0,
                lockoutDuration: this.lockoutDuration,
                message: 'Account locked due to multiple failed login attempts. Please try again in 15 minutes.'
            };
        }

        return {
            locked: false,
            attemptsRemaining: this.maxAttempts - attemptData.count,
            lockoutDuration: 0,
            message: `Incorrect password. ${this.maxAttempts - attemptData.count} attempts remaining.`
        };
    }

    lockAccount(email, ipAddress) {
        const key = `${email}:${ipAddress}`;
        const unlockTime = Date.now() + this.lockoutDuration;
        
        this.lockedAccounts.set(key, unlockTime);

        // Auto-unlock after duration
        setTimeout(() => {
            this.lockedAccounts.delete(key);
            this.attempts.delete(key);
        }, this.lockoutDuration);
    }

    isAccountLocked(email, ipAddress) {
        const key = `${email}:${ipAddress}`;
        const unlockTime = this.lockedAccounts.get(key);
        
        if (!unlockTime) {
            return false;
        }

        if (unlockTime > Date.now()) {
            return {
                locked: true,
                unlockTime: unlockTime,
                remainingTime: unlockTime - Date.now()
            };
        }

        // Unlock if time has passed
        this.lockedAccounts.delete(key);
        this.attempts.delete(key);
        return false;
    }

    resetAttempts(email, ipAddress) {
        const key = `${email}:${ipAddress}`;
        this.attempts.delete(key);
        this.lockedAccounts.delete(key);
    }
}

// Create global instances
const rateLimiter = new RateLimiter();
const requestThrottler = new RequestThrottler();
const ipRateLimiter = new IPRateLimiter();
const failedLoginTracker = new FailedLoginTracker();

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { 
        RateLimiter, 
        RequestThrottler, 
        IPRateLimiter, 
        FailedLoginTracker,
        rateLimiter,
        requestThrottler,
        ipRateLimiter,
        failedLoginTracker
    };
} else {
    window.RateLimiter = RateLimiter;
    window.RequestThrottler = RequestThrottler;
    window.IPRateLimiter = IPRateLimiter;
    window.FailedLoginTracker = FailedLoginTracker;
    window.rateLimiter = rateLimiter;
    window.requestThrottler = requestThrottler;
    window.ipRateLimiter = ipRateLimiter;
    window.failedLoginTracker = failedLoginTracker;
}
