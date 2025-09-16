// Simple Database API for MindVault
// This is a client-side database simulation for demo purposes
// In production, this would be replaced with a real backend API

class MindVaultDB {
    constructor() {
        this.dbName = 'mindvault_db';
        this.version = 1;
        this.db = null;
        this.init();
    }

    async init() {
        // Initialize IndexedDB for client-side storage
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.version);
            
            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                this.db = request.result;
                resolve(this.db);
            };
            
            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                
                // Create object stores
                if (!db.objectStoreNames.contains('users')) {
                    const userStore = db.createObjectStore('users', { keyPath: 'id' });
                    userStore.createIndex('email', 'email', { unique: true });
                }
                
                if (!db.objectStoreNames.contains('posts')) {
                    const postStore = db.createObjectStore('posts', { keyPath: 'id', autoIncrement: true });
                    postStore.createIndex('userId', 'userId');
                    postStore.createIndex('timestamp', 'timestamp');
                }
                
                if (!db.objectStoreNames.contains('moodEntries')) {
                    const moodStore = db.createObjectStore('moodEntries', { keyPath: 'id', autoIncrement: true });
                    moodStore.createIndex('userId', 'userId');
                    moodStore.createIndex('timestamp', 'timestamp');
                }
                
                if (!db.objectStoreNames.contains('insights')) {
                    const insightStore = db.createObjectStore('insights', { keyPath: 'id', autoIncrement: true });
                    insightStore.createIndex('userId', 'userId');
                    insightStore.createIndex('timestamp', 'timestamp');
                }
            };
        });
    }

    // User Management
    async createUser(userData) {
        const transaction = this.db.transaction(['users'], 'readwrite');
        const store = transaction.objectStore('users');
        
        const user = {
            id: Date.now().toString(),
            ...userData,
            createdAt: new Date().toISOString(),
            isActive: true,
            trialStart: new Date().toISOString(),
            trialEnd: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString()
        };
        
        return new Promise((resolve, reject) => {
            const request = store.add(user);
            request.onsuccess = () => resolve(user);
            request.onerror = () => reject(request.error);
        });
    }

    async getUserByEmail(email) {
        const transaction = this.db.transaction(['users'], 'readonly');
        const store = transaction.objectStore('users');
        const index = store.index('email');
        
        return new Promise((resolve, reject) => {
            const request = index.get(email);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async getUserById(id) {
        const transaction = this.db.transaction(['users'], 'readonly');
        const store = transaction.objectStore('users');
        
        return new Promise((resolve, reject) => {
            const request = store.get(id);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async updateUser(id, updates) {
        const transaction = this.db.transaction(['users'], 'readwrite');
        const store = transaction.objectStore('users');
        
        return new Promise((resolve, reject) => {
            const getRequest = store.get(id);
            getRequest.onsuccess = () => {
                const user = getRequest.result;
                if (user) {
                    const updatedUser = { ...user, ...updates, updatedAt: new Date().toISOString() };
                    const putRequest = store.put(updatedUser);
                    putRequest.onsuccess = () => resolve(updatedUser);
                    putRequest.onerror = () => reject(putRequest.error);
                } else {
                    reject(new Error('User not found'));
                }
            };
            getRequest.onerror = () => reject(getRequest.error);
        });
    }

    // Post Management
    async createPost(postData) {
        const transaction = this.db.transaction(['posts'], 'readwrite');
        const store = transaction.objectStore('posts');
        
        const post = {
            ...postData,
            timestamp: new Date().toISOString(),
            likes: 0,
            comments: []
        };
        
        return new Promise((resolve, reject) => {
            const request = store.add(post);
            request.onsuccess = () => resolve({ ...post, id: request.result });
            request.onerror = () => reject(request.error);
        });
    }

    async getPosts(limit = 20) {
        const transaction = this.db.transaction(['posts'], 'readonly');
        const store = transaction.objectStore('posts');
        const index = store.index('timestamp');
        
        return new Promise((resolve, reject) => {
            const request = index.openCursor(null, 'prev');
            const posts = [];
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && posts.length < limit) {
                    posts.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(posts);
                }
            };
            request.onerror = () => reject(request.error);
        });
    }

    // Mood Entry Management
    async createMoodEntry(moodData) {
        const transaction = this.db.transaction(['moodEntries'], 'readwrite');
        const store = transaction.objectStore('moodEntries');
        
        const moodEntry = {
            ...moodData,
            timestamp: new Date().toISOString()
        };
        
        return new Promise((resolve, reject) => {
            const request = store.add(moodEntry);
            request.onsuccess = () => resolve({ ...moodEntry, id: request.result });
            request.onerror = () => reject(request.error);
        });
    }

    async getMoodEntries(userId, limit = 30) {
        const transaction = this.db.transaction(['moodEntries'], 'readonly');
        const store = transaction.objectStore('moodEntries');
        const index = store.index('userId');
        
        return new Promise((resolve, reject) => {
            const request = index.openCursor(IDBKeyRange.only(userId));
            const entries = [];
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && entries.length < limit) {
                    entries.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(entries);
                }
            };
            request.onerror = () => reject(request.error);
        });
    }

    // Insights Management
    async createInsight(insightData) {
        const transaction = this.db.transaction(['insights'], 'readwrite');
        const store = transaction.objectStore('insights');
        
        const insight = {
            ...insightData,
            timestamp: new Date().toISOString()
        };
        
        return new Promise((resolve, reject) => {
            const request = store.add(insight);
            request.onsuccess = () => resolve({ ...insight, id: request.result });
            request.onerror = () => reject(request.error);
        });
    }

    async getInsights(userId, limit = 10) {
        const transaction = this.db.transaction(['insights'], 'readonly');
        const store = transaction.objectStore('insights');
        const index = store.index('userId');
        
        return new Promise((resolve, reject) => {
            const request = index.openCursor(IDBKeyRange.only(userId));
            const insights = [];
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && insights.length < limit) {
                    insights.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(insights);
                }
            };
            request.onerror = () => reject(request.error);
        });
    }

    // Analytics and Statistics
    async getUserStats(userId) {
        const moodEntries = await this.getMoodEntries(userId, 100);
        const posts = await this.getPosts(100);
        const userPosts = posts.filter(post => post.userId === userId);
        
        // Calculate mood statistics
        const moodScores = moodEntries.map(entry => entry.moodScore || 0);
        const avgMood = moodScores.length > 0 ? moodScores.reduce((a, b) => a + b, 0) / moodScores.length : 0;
        
        // Calculate trends
        const recentMoods = moodEntries.slice(-7);
        const olderMoods = moodEntries.slice(-14, -7);
        const recentAvg = recentMoods.length > 0 ? recentMoods.reduce((a, b) => a + (b.moodScore || 0), 0) / recentMoods.length : 0;
        const olderAvg = olderMoods.length > 0 ? olderMoods.reduce((a, b) => a + (b.moodScore || 0), 0) / olderMoods.length : 0;
        const trend = recentAvg - olderAvg;
        
        return {
            totalMoodEntries: moodEntries.length,
            totalPosts: userPosts.length,
            averageMood: avgMood,
            moodTrend: trend > 0 ? 'improving' : trend < 0 ? 'declining' : 'stable',
            lastActivity: moodEntries.length > 0 ? moodEntries[moodEntries.length - 1].timestamp : null
        };
    }

    // Export/Import functionality
    async exportUserData(userId) {
        const user = await this.getUserById(userId);
        const moodEntries = await this.getMoodEntries(userId);
        const insights = await this.getInsights(userId);
        const posts = await this.getPosts();
        const userPosts = posts.filter(post => post.userId === userId);
        
        return {
            user,
            moodEntries,
            insights,
            posts: userPosts,
            exportedAt: new Date().toISOString()
        };
    }

    // Clear all data (for testing)
    async clearAllData() {
        const stores = ['users', 'posts', 'moodEntries', 'insights'];
        const transaction = this.db.transaction(stores, 'readwrite');
        
        return Promise.all(stores.map(storeName => {
            return new Promise((resolve, reject) => {
                const store = transaction.objectStore(storeName);
                const request = store.clear();
                request.onsuccess = () => resolve();
                request.onerror = () => reject(request.error);
            });
        }));
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MindVaultDB;
} else {
    window.MindVaultDB = MindVaultDB;
    // Don't auto-initialize - let each page handle its own instance
}
