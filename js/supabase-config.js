// Supabase Configuration for MindVault
// Replace these with your actual Supabase project credentials

const SUPABASE_CONFIG = {
    // Your Supabase project URL
    url: 'https://swacnbyayimigfzgzgvm.supabase.co',
    
    // Your Supabase anon key
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3YWNuYnlheWltaWdmemd6Z3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5MDMzNjcsImV4cCI6MjA3NTQ3OTM2N30.5AKdysWwZkB_YVGTQl3eDqhgfcpRio0hTnjFo6rloZA',
    
    // Optional: Service role key for admin operations (keep this secret!)
    serviceKey: 'YOUR_SUPABASE_SERVICE_KEY' // Only use server-side!
};

// Database schema for MindVault
const DATABASE_SCHEMA = {
    tables: {
        users: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                email: 'varchar UNIQUE NOT NULL',
                password_hash: 'varchar NOT NULL',
                first_name: 'varchar NOT NULL',
                last_name: 'varchar NOT NULL',
                user_type: 'varchar NOT NULL CHECK (user_type IN (\'user\', \'peer\', \'counselor\'))',
                plan: 'varchar NOT NULL DEFAULT \'basic\' CHECK (plan IN (\'basic\', \'premium\', \'professional\'))',
                billing: 'varchar NOT NULL DEFAULT \'monthly\' CHECK (billing IN (\'monthly\', \'annual\'))',
                support_group: 'varchar',
                experience_level: 'varchar',
                journey: 'text',
                newsletter: 'boolean DEFAULT false',
                payment_completed: 'boolean DEFAULT false',
                payment_method: 'varchar',
                payment_date: 'timestamp',
                trial_start: 'timestamp DEFAULT now()',
                trial_end: 'timestamp DEFAULT (now() + interval \'14 days\')',
                last_login: 'timestamp',
                created_at: 'timestamp DEFAULT now()',
                updated_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_users_email ON users(email);',
                'CREATE INDEX idx_users_user_type ON users(user_type);',
                'CREATE INDEX idx_users_plan ON users(plan);'
            ]
        },
        
        posts: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                user_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                content: 'text NOT NULL',
                category: 'varchar NOT NULL',
                is_anonymous: 'boolean DEFAULT true',
                likes_count: 'integer DEFAULT 0',
                comments_count: 'integer DEFAULT 0',
                created_at: 'timestamp DEFAULT now()',
                updated_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_posts_user_id ON posts(user_id);',
                'CREATE INDEX idx_posts_category ON posts(category);',
                'CREATE INDEX idx_posts_created_at ON posts(created_at DESC);'
            ]
        },
        
        mood_entries: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                user_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                mood_score: 'integer NOT NULL CHECK (mood_score >= 1 AND mood_score <= 10)',
                mood: 'varchar NOT NULL',
                notes: 'text',
                created_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_mood_entries_user_id ON mood_entries(user_id);',
                'CREATE INDEX idx_mood_entries_created_at ON mood_entries(created_at DESC);'
            ]
        },
        
        insights: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                user_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                type: 'varchar NOT NULL',
                content: 'text NOT NULL',
                confidence: 'decimal(3,2) CHECK (confidence >= 0 AND confidence <= 1)',
                created_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_insights_user_id ON insights(user_id);',
                'CREATE INDEX idx_insights_type ON insights(type);',
                'CREATE INDEX idx_insights_created_at ON insights(created_at DESC);'
            ]
        },
        
        comments: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                post_id: 'uuid REFERENCES posts(id) ON DELETE CASCADE',
                user_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                content: 'text NOT NULL',
                is_anonymous: 'boolean DEFAULT true',
                created_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_comments_post_id ON comments(post_id);',
                'CREATE INDEX idx_comments_user_id ON comments(user_id);'
            ]
        },
        
        counselor_profiles: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                user_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                specialization: 'varchar NOT NULL',
                experience_years: 'integer NOT NULL',
                bio: 'text',
                hourly_rate: 'decimal(10,2)',
                availability: 'jsonb',
                rating: 'decimal(3,2) DEFAULT 0',
                total_sessions: 'integer DEFAULT 0',
                is_verified: 'boolean DEFAULT false',
                created_at: 'timestamp DEFAULT now()',
                updated_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_counselor_profiles_user_id ON counselor_profiles(user_id);',
                'CREATE INDEX idx_counselor_profiles_specialization ON counselor_profiles(specialization);'
            ]
        },
        
        sessions: {
            columns: {
                id: 'uuid PRIMARY KEY DEFAULT gen_random_uuid()',
                counselor_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                client_id: 'uuid REFERENCES users(id) ON DELETE CASCADE',
                status: 'varchar NOT NULL DEFAULT \'scheduled\' CHECK (status IN (\'scheduled\', \'completed\', \'cancelled\'))',
                scheduled_at: 'timestamp NOT NULL',
                duration_minutes: 'integer DEFAULT 60',
                notes: 'text',
                rating: 'integer CHECK (rating >= 1 AND rating <= 5)',
                created_at: 'timestamp DEFAULT now()',
                updated_at: 'timestamp DEFAULT now()'
            },
            indexes: [
                'CREATE INDEX idx_sessions_counselor_id ON sessions(counselor_id);',
                'CREATE INDEX idx_sessions_client_id ON sessions(client_id);',
                'CREATE INDEX idx_sessions_scheduled_at ON sessions(scheduled_at);'
            ]
        }
    },
    
    // Row Level Security (RLS) policies
    rls_policies: {
        users: [
            'CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);',
            'CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);'
        ],
        posts: [
            'CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);',
            'CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);',
            'CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = user_id);',
            'CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = user_id);'
        ],
        mood_entries: [
            'CREATE POLICY "Users can view own mood entries" ON mood_entries FOR SELECT USING (auth.uid() = user_id);',
            'CREATE POLICY "Users can create mood entries" ON mood_entries FOR INSERT WITH CHECK (auth.uid() = user_id);',
            'CREATE POLICY "Users can update own mood entries" ON mood_entries FOR UPDATE USING (auth.uid() = user_id);',
            'CREATE POLICY "Users can delete own mood entries" ON mood_entries FOR DELETE USING (auth.uid() = user_id);'
        ],
        insights: [
            'CREATE POLICY "Users can view own insights" ON insights FOR SELECT USING (auth.uid() = user_id);',
            'CREATE POLICY "Users can create insights" ON insights FOR INSERT WITH CHECK (auth.uid() = user_id);'
        ],
        comments: [
            'CREATE POLICY "Anyone can view comments" ON comments FOR SELECT USING (true);',
            'CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);',
            'CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid() = user_id);',
            'CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);'
        ],
        counselor_profiles: [
            'CREATE POLICY "Anyone can view counselor profiles" ON counselor_profiles FOR SELECT USING (true);',
            'CREATE POLICY "Counselors can manage own profile" ON counselor_profiles FOR ALL USING (auth.uid() = user_id);'
        ],
        sessions: [
            'CREATE POLICY "Users can view own sessions" ON sessions FOR SELECT USING (auth.uid() = counselor_id OR auth.uid() = client_id);',
            'CREATE POLICY "Users can create sessions" ON sessions FOR INSERT WITH CHECK (auth.uid() = counselor_id OR auth.uid() = client_id);',
            'CREATE POLICY "Users can update own sessions" ON sessions FOR UPDATE USING (auth.uid() = counselor_id OR auth.uid() = client_id);'
        ]
    }
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { SUPABASE_CONFIG, DATABASE_SCHEMA };
} else {
    window.SUPABASE_CONFIG = SUPABASE_CONFIG;
    window.DATABASE_SCHEMA = DATABASE_SCHEMA;
}
