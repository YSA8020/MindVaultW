import { useState, useEffect } from 'react';
import { User } from '@/lib/supabase';
import { AuthManager, TrialStatus } from '@/lib/auth';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Check authentication status on mount
    const checkAuth = () => {
      const isLoggedIn = AuthManager.isLoggedIn();
      const currentUser = AuthManager.getCurrentUserFromStorage();
      
      setIsAuthenticated(isLoggedIn);
      setUser(currentUser);
      setLoading(false);
    };

    checkAuth();
  }, []);

  const login = (userData: User) => {
    AuthManager.setCurrentUserInStorage(userData);
    setUser(userData);
    setIsAuthenticated(true);
  };

  const logout = async () => {
    await AuthManager.logout();
    setUser(null);
    setIsAuthenticated(false);
  };

  const hasFeatureAccess = (feature: string): boolean => {
    return AuthManager.hasFeatureAccess(user, feature);
  };

  const getTrialStatus = (): TrialStatus | null => {
    return AuthManager.getTrialStatus(user);
  };

  const needsUpgrade = (): boolean => {
    return AuthManager.needsUpgrade(user);
  };

  const getUpgradeMessage = (): string | null => {
    return AuthManager.getUpgradeMessage(user);
  };

  return {
    user,
    loading,
    isAuthenticated,
    login,
    logout,
    hasFeatureAccess,
    getTrialStatus,
    needsUpgrade,
    getUpgradeMessage,
  };
}


