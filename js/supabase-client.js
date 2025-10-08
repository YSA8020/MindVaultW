// Supabase Client for MindVault
// This replaces the IndexedDB system with Supabase backend

class MindVaultSupabaseClient {
    constructor() {
        this.supabase = null;
        this.initialized = false;
    }

    async init() {
        try {
            // Load Supabase client library if not already loaded
            if (typeof window.supabase === 'undefined') {
                await this.loadSupabaseLibrary();
            }

            // Initialize Supabase client
            this.supabase = window.supabase.createClient(
                SUPABASE_CONFIG.url,
                SUPABASE_CONFIG.anonKey
            );

            this.initialized = true;
            console.log('Supabase client initialized successfully');
            return true;
        } catch (error) {
            console.error('Failed to initialize Supabase client:', error);
            throw error;
        }
    }

    async loadSupabaseLibrary() {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    }

    // User Management Methods
    async createUser(userData) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            // Hash password (in production, this should be done server-side)
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
                    newsletter: userData.newsletter,
                    trial_start: new Date().toISOString(),
                    trial_end: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw error;
            }

            console.log('User created successfully:', data);
            return data;
        } catch (error) {
            console.error('Error creating user:', error);
            throw error;
        }
    }

    async getUserByEmail(email) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('*')
                .eq('email', email)
                .single();

            if (error && error.code !== 'PGRST116') { // PGRST116 = no rows returned
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting user by email:', error);
            throw error;
        }
    }

    async getUserById(id) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .select('*')
                .eq('id', id)
                .single();

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting user by ID:', error);
            throw error;
        }
    }

    async updateUser(id, updates) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('users')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error updating user:', error);
            throw error;
        }
    }

    // Authentication Methods
    async signUp(email, password, userData) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: {
                        first_name: userData.firstName,
                        last_name: userData.lastName,
                        user_type: userData.userType,
                        plan: userData.plan
                    }
                }
            });

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error signing up:', error);
            throw error;
        }
    }

    async signIn(email, password) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error signing in:', error);
            throw error;
        }
    }

    async signOut() {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { error } = await this.supabase.auth.signOut();
            if (error) {
                throw error;
            }
        } catch (error) {
            console.error('Error signing out:', error);
            throw error;
        }
    }

    async getCurrentUser() {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data: { user }, error } = await this.supabase.auth.getUser();
            if (error) {
                throw error;
            }
            return user;
        } catch (error) {
            console.error('Error getting current user:', error);
            throw error;
        }
    }

    // Posts Management
    async createPost(postData) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('posts')
                .insert([{
                    user_id: postData.userId,
                    content: postData.content,
                    category: postData.category,
                    is_anonymous: postData.isAnonymous || true
                }])
                .select()
                .single();

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error creating post:', error);
            throw error;
        }
    }

    async getPosts(limit = 50) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('posts')
                .select('*')
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting posts:', error);
            throw error;
        }
    }

    // Mood Entries Management
    async createMoodEntry(moodData) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
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

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error creating mood entry:', error);
            throw error;
        }
    }

    async getMoodEntries(userId, limit = 30) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('mood_entries')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting mood entries:', error);
            throw error;
        }
    }

    // Insights Management
    async createInsight(insightData) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
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

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error creating insight:', error);
            throw error;
        }
    }

    async getInsights(userId, limit = 10) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('insights')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting insights:', error);
            throw error;
        }
    }

    // Counselor Profiles
    async getCounselorProfiles(limit = 20) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .from('counselor_profiles')
                .select(`
                    *,
                    users!inner(first_name, last_name, email)
                `)
                .eq('is_verified', true)
                .order('rating', { ascending: false })
                .limit(limit);

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting counselor profiles:', error);
            throw error;
        }
    }

    // Utility Methods
    async hashPassword(password) {
        // Simple hash function - in production, use proper bcrypt or similar
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    }

    // Check if user is authenticated
    isAuthenticated() {
        return this.initialized && this.supabase.auth.getSession();
    }

    // Get user statistics
    async getUserStats(userId) {
        if (!this.initialized) {
            throw new Error('Supabase client not initialized');
        }

        try {
            const { data, error } = await this.supabase
                .rpc('get_user_stats', { user_uuid: userId });

            if (error) {
                throw error;
            }

            return data;
        } catch (error) {
            console.error('Error getting user stats:', error);
            throw error;
        }
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MindVaultSupabaseClient;
} else {
    window.MindVaultSupabaseClient = MindVaultSupabaseClient;
}
