export type UserType = 'user' | 'professional' | 'admin';

export type Plan = 'basic' | 'premium' | 'professional';

export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  user_type: UserType;
  plan: Plan;
  trial_start?: string;
  trial_end?: string;
  created_at: string;
  updated_at: string;
}

export interface MoodEntry {
  id: string;
  user_id: string;
  mood: string;
  mood_score: number;
  notes?: string;
  created_at: string;
}

export interface Post {
  id: string;
  user_id?: string;
  content: string;
  category?: string;
  is_anonymous: boolean;
  created_at: string;
}

export interface CounselorProfile {
  id: string;
  user_id: string;
  specializations: string[];
  bio: string;
  experience_years: number;
  rating: number;
  is_verified: boolean;
  availability: any;
}

export interface Session {
  id: string;
  professional_id: string;
  client_id: string;
  scheduled_at: string;
  duration: number;
  status: 'scheduled' | 'completed' | 'cancelled';
  notes?: string;
}

export interface TrialStatus {
  isActive: boolean;
  remainingDays: number;
  trialEnd: Date | null;
  plan: string;
}


