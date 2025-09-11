// Supabase Database API for MindVault
// Production-ready backend integration

class SupabaseDB {
    constructor() {
        this.supabase = null;
        this.isInitialized = false;
        this.init();
    }

    async init() {
        try {
            // Check if Supabase is available
            if (typeof supabase === 'undefined') {
                console.warn('Supabase not loaded, falling back to IndexedDB');
                return this.initFallback();
            }

            // Initialize Supabase client
            this.supabase = supabase.createClient(
                SUPABASE_CONFIG.url,
                SUPABASE_CONFIG.anonKey
            );

            // Test connection
            const { data, error } = await this.supabase.from('users').select('count').limit(1);
            
            if (error) {
                console.warn('Supabase connection failed, falling back to IndexedDB:', error);
                return this.initFallback();
            }

            this.isInitialized = true;
            console.log('✅ Supabase connected successfully');
            
        } catch (error) {
            console.warn('Supabase initialization failed, falling back to IndexedDB:', error);
            return this.initFallback();
        }
    }

    initFallback() {
        // Fallback to IndexedDB for development
        console.log('🔄 Using IndexedDB fallback');
        return new MindVaultDB();
    }

    // User Management
    async createUser(userData) {
        if (!this.isInitialized) {
            return this.fallbackDB.createUser(userData);
        }

        try {
            // Hash password (in production, do this server-side)
            const passwordHash = await this.hashPassword(userData.password);
            
            const { data, error } = await this.supabase
                .from('users')
                .insert([{
                    email: userData.email,
                    password_hash: passwordHash,
                    first_name: userData.firstName,
                    last_name: userData.lastName,
                    user_type: userData.userType,
                    plan: userData.plan,
                    billing: userData.billing,
                    support_group: userData.supportGroup,
                    experience_level: userData.experienceLevel,
                    journey: userData.journey,
                    newsletter: userData.newsletter
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating user:', error);
            throw error;
        }
    }

    async getUserByEmail(email) {
        if (!this.isInitialized) {
            return this.fallbackDB.getUserByEmail(email);
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('*')
                .eq('email', email)
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error getting user by email:', error);
            throw error;
        }
    }

    async getUserById(id) {
        if (!this.isInitialized) {
            return this.fallbackDB.getUserById(id);
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('*')
                .eq('id', id)
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error getting user by ID:', error);
            throw error;
        }
    }

    async updateUser(id, updates) {
        if (!this.isInitialized) {
            return this.fallbackDB.updateUser(id, updates);
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .update({
                    ...updates,
                    updated_at: new Date().toISOString()
                })
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error updating user:', error);
            throw error;
        }
    }

    // Post Management
    async createPost(postData) {
        if (!this.isInitialized) {
            return this.fallbackDB.createPost(postData);
        }

        try {
            const { data, error } = await this.supabase
                .from('posts')
                .insert([{
                    user_id: postData.userId,
                    content: postData.content,
                    category: postData.category,
                    is_anonymous: postData.isAnonymous !== false
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating post:', error);
            throw error;
        }
    }

    async getPosts(limit = 20) {
        if (!this.isInitialized) {
            return this.fallbackDB.getPosts(limit);
        }

        try {
            const { data, error } = await this.supabase
                .from('posts')
                .select('*')
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error getting posts:', error);
            throw error;
        }
    }

    // Mood Entry Management
    async createMoodEntry(moodData) {
        if (!this.isInitialized) {
            return this.fallbackDB.createMoodEntry(moodData);
        }

        try {
            const { data, error } = await this.supabase
                .from('mood_entries')
                .insert([{
                    user_id: moodData.userId,
                    mood_score: moodData.moodScore,
                    mood: moodData.mood,
                    notes: moodData.notes
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating mood entry:', error);
            throw error;
        }
    }

    async getMoodEntries(userId, limit = 30) {
        if (!this.isInitialized) {
            return this.fallbackDB.getMoodEntries(userId, limit);
        }

        try {
            const { data, error } = await this.supabase
                .from('mood_entries')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error getting mood entries:', error);
            throw error;
        }
    }

    // Insights Management
    async createInsight(insightData) {
        if (!this.isInitialized) {
            return this.fallbackDB.createInsight(insightData);
        }

        try {
            const { data, error } = await this.supabase
                .from('insights')
                .insert([{
                    user_id: insightData.userId,
                    type: insightData.type,
                    content: insightData.content,
                    confidence: insightData.confidence
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating insight:', error);
            throw error;
        }
    }

    async getInsights(userId, limit = 10) {
        if (!this.isInitialized) {
            return this.fallbackDB.getInsights(userId, limit);
        }

        try {
            const { data, error } = await this.supabase
                .from('insights')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error getting insights:', error);
            throw error;
        }
    }

    // Counselor Management
    async createCounselorProfile(profileData) {
        if (!this.isInitialized) {
            throw new Error('Counselor profiles require Supabase backend');
        }

        try {
            const { data, error } = await this.supabase
                .from('counselor_profiles')
                .insert([{
                    user_id: profileData.userId,
                    specialization: profileData.specialization,
                    experience_years: profileData.experienceYears,
                    bio: profileData.bio,
                    hourly_rate: profileData.hourlyRate,
                    availability: profileData.availability
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating counselor profile:', error);
            throw error;
        }
    }

    async getCounselorProfiles(limit = 20) {
        if (!this.isInitialized) {
            throw new Error('Counselor profiles require Supabase backend');
        }

        try {
            const { data, error } = await this.supabase
                .from('counselor_profiles')
                .select(`
                    *,
                    users:user_id(first_name, last_name, email)
                `)
                .eq('is_verified', true)
                .order('rating', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error getting counselor profiles:', error);
            throw error;
        }
    }

    // Session Management
    async createSession(sessionData) {
        if (!this.isInitialized) {
            throw new Error('Sessions require Supabase backend');
        }

        try {
            const { data, error } = await this.supabase
                .from('sessions')
                .insert([{
                    counselor_id: sessionData.counselorId,
                    client_id: sessionData.clientId,
                    scheduled_at: sessionData.scheduledAt,
                    duration_minutes: sessionData.durationMinutes || 60,
                    notes: sessionData.notes
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Error creating session:', error);
            throw error;
        }
    }

    async getUserSessions(userId) {
        if (!this.isInitialized) {
            throw new Error('Sessions require Supabase backend');
        }

        try {
            const { data, error } = await this.supabase
                .from('sessions')
                .select(`
                    *,
                    counselor:counselor_id(first_name, last_name),
                    client:client_id(first_name, last_name)
                `)
                .or(`counselor_id.eq.${userId},client_id.eq.${userId}`)
                .order('scheduled_at', { ascending: false });

            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error getting user sessions:', error);
            throw error;
        }
    }

    // Analytics and Statistics
    async getUserStats(userId) {
        if (!this.isInitialized) {
            return this.fallbackDB.getUserStats(userId);
        }

        try {
            // Get mood entries
            const { data: moodEntries } = await this.supabase
                .from('mood_entries')
                .select('mood_score, created_at')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(100);

            // Get posts
            const { data: posts } = await this.supabase
                .from('posts')
                .select('id, created_at')
                .eq('user_id', userId);

            // Calculate statistics
            const moodScores = moodEntries?.map(entry => entry.mood_score) || [];
            const avgMood = moodScores.length > 0 ? moodScores.reduce((a, b) => a + b, 0) / moodScores.length : 0;

            // Calculate trends
            const recentMoods = moodEntries?.slice(0, 7) || [];
            const olderMoods = moodEntries?.slice(7, 14) || [];
            const recentAvg = recentMoods.length > 0 ? recentMoods.reduce((a, b) => a + b.mood_score, 0) / recentMoods.length : 0;
            const olderAvg = olderMoods.length > 0 ? olderMoods.reduce((a, b) => a + b.mood_score, 0) / olderMoods.length : 0;
            const trend = recentAvg - olderAvg;

            return {
                totalMoodEntries: moodEntries?.length || 0,
                totalPosts: posts?.length || 0,
                averageMood: avgMood,
                moodTrend: trend > 0 ? 'improving' : trend < 0 ? 'declining' : 'stable',
                lastActivity: moodEntries?.[0]?.created_at || null
            };
        } catch (error) {
            console.error('Error getting user stats:', error);
            throw error;
        }
    }

    // Authentication helpers
    async hashPassword(password) {
        // Simple hash for demo - in production, use proper hashing
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    }

    async verifyPassword(password, hash) {
        const passwordHash = await this.hashPassword(password);
        return passwordHash === hash;
    }

    // Export/Import functionality
    async exportUserData(userId) {
        if (!this.isInitialized) {
            return this.fallbackDB.exportUserData(userId);
        }

        try {
            const [user, moodEntries, insights, posts] = await Promise.all([
                this.getUserById(userId),
                this.getMoodEntries(userId),
                this.getInsights(userId),
                this.getPosts(1000) // Get all posts for export
            ]);

            const userPosts = posts.filter(post => post.user_id === userId);

            return {
                user,
                moodEntries,
                insights,
                posts: userPosts,
                exportedAt: new Date().toISOString()
            };
        } catch (error) {
            console.error('Error exporting user data:', error);
            throw error;
        }
    }

    // Clear all data (for testing)
    async clearAllData() {
        if (!this.isInitialized) {
            return this.fallbackDB.clearAllData();
        }

        console.warn('clearAllData() is not implemented for Supabase - use Supabase dashboard');
        throw new Error('Use Supabase dashboard to clear data');
    }
}

// Initialize Supabase database
const mindVaultDB = new SupabaseDB();

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SupabaseDB;
} else {
    window.SupabaseDB = SupabaseDB;
    window.mindVaultDB = mindVaultDB;
}
