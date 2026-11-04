import { createContext } from 'react';

export type AuthStatus = 'loading' | 'authenticated' | 'unauthenticated';

export type User = {
  id: number;
  uuid?: string;
  email: string | null;
  phoneNumber: string | null;
  is_org_admin?: boolean;
  isTrainer?: boolean;
  // Server-decided admin area access: everything, the reports page only, or none.
  adminAccess?: 'full' | 'reports' | null;
  organization_subdomain?: string;
  surveyCompleted?: boolean;
  optOutOfRecommendations?: boolean;
  profileValid?: boolean;
};

export type AuthContextValue = {
  status: AuthStatus;
  user: User | null;
  refresh: () => Promise<void>;
  login: (
    email: string,
    password: string,
  ) => Promise<{ is_org_admin?: boolean; redirect_to?: string } | null>;
  loginWithPhone: (
    phone: string,
  ) => Promise<{ is_org_admin?: boolean; redirect_to?: string } | null>;
  logout: () => Promise<void>;
};

export const AuthContext = createContext<AuthContextValue | undefined>(undefined);
