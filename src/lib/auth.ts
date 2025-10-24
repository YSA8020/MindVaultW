import { SupabaseService, User } from './supabase';

export interface TrialStatus {
  isActive: boolean;
  remainingDays: number;
  trialEnd: Date | null;
  plan: string;
}

export class AuthManager {
  static getCurrentUserFromStorage(): User | null {
    if (typeof window === 'undefined') return null;
    
    const userData = localStorage.getItem('userData');
    if (userData) {
      try {
        return JSON.parse(userData);
      } catch (error) {
        console.error('Error parsing user data:', error);
        return null;
      }
    }
    return null;
  }

  static setCurrentUserInStorage(user: User | null): void {
    if (typeof window === 'undefined') return;
    
    if (user) {
      localStorage.setItem('userData', JSON.stringify(user));
      localStorage.setItem('isLoggedIn', 'true');
      localStorage.setItem('userId', user.id);
    } else {
      localStorage.removeItem('userData');
      localStorage.removeItem('isLoggedIn');
      localStorage.removeItem('userId');
    }
  }

  static isLoggedIn(): boolean {
    if (typeof window === 'undefined') return false;
    return localStorage.getItem('isLoggedIn') === 'true';
  }

  static getTrialStatus(user: User | null): TrialStatus | null {
    if (!user) return null;

    const now = new Date();
    const trialEnd = user.trial_end ? new Date(user.trial_end) : null;
    
    if (!trialEnd) {
      return {
        isActive: false,
        remainingDays: 0,
        trialEnd: null,
        plan: user.plan,
      };
    }

    const remainingDays = Math.ceil((trialEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

    return {
      isActive: remainingDays > 0,
      remainingDays: Math.max(0, remainingDays),
      trialEnd,
      plan: user.plan,
    };
  }

  static hasFeatureAccess(user: User | null, feature: string): boolean {
    if (!user) return false;

    const trialStatus = this.getTrialStatus(user);
    const plan = user.plan;

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
      return plan === 'premium' || plan === 'professional' || (trialStatus?.isActive ?? false);
    }

    if (professionalFeatures.includes(feature)) {
      return plan === 'professional' || ((trialStatus?.isActive ?? false) && plan === 'professional');
    }

    return false;
  }

  static async logout(): Promise<void> {
    try {
      await SupabaseService.signOut();
    } catch (error) {
      console.error('Error signing out:', error);
    } finally {
      this.setCurrentUserInStorage(null);
      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }
  }

  static needsUpgrade(user: User | null): boolean {
    const trialStatus = this.getTrialStatus(user);
    return trialStatus !== null && !trialStatus.isActive && user?.plan === 'basic';
  }

  static getUpgradeMessage(user: User | null): string | null {
    const trialStatus = this.getTrialStatus(user);

    if (trialStatus && trialStatus.isActive) {
      return `Your ${trialStatus.plan} trial has ${trialStatus.remainingDays} days remaining.`;
    } else if (this.needsUpgrade(user)) {
      return 'Your trial has expired. Upgrade to continue using premium features.';
    }

    return null;
  }
}


