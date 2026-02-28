import React, { useEffect, useMemo, useState } from 'react';
import { apiFetch } from '../app/api/apiFetch';
import { AuthContext, type AuthContextValue, type AuthStatus, type User } from './authState';

async function apiJson(path: string, init: RequestInit = {}) {
  const res = await apiFetch(path, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });

  const isJson = (res.headers.get('content-type') || '').includes('application/json');
  const body = isJson ? await res.json().catch(() => null) : null;

  if (!res.ok) {
    const message = body?.error || body?.message || `Request failed: ${res.status}`;
    throw new Error(message);
  }

  return body;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>('loading');
  const [user, setUser] = useState<User | null>(null);

  const refresh = async () => {
    setStatus('loading');
    try {
      const me = await apiJson('/api/v1/me', { method: 'GET' });
      setUser(me);
      setStatus('authenticated');
    } catch {
      setUser(null);
      setStatus('unauthenticated');
    }
  };

  const login = async (email: string, password: string) => {
    const session = (await apiJson('/api/v1/session', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })) as { is_org_admin?: boolean; redirect_to?: string } | null;
    await refresh();
    return session;
  };

  const loginWithPhone = async (phone: string) => {
    const session = (await apiJson('/api/v1/session', {
      method: 'POST',
      body: JSON.stringify({ phone_number: { phone } }),
    })) as { is_org_admin?: boolean; redirect_to?: string } | null;
    await refresh();
    return session;
  };

  const logout = async () => {
    await apiJson('/api/v1/session', { method: 'DELETE' });
    setUser(null);
    setStatus('unauthenticated');
  };

  const value = useMemo<AuthContextValue>(
    () => ({ status, user, refresh, login, loginWithPhone, logout }),
    [status, user],
  );

  useEffect(() => {
    let active = true;

    const bootstrapAuth = async () => {
      try {
        const me = await apiJson('/api/v1/me', { method: 'GET' });
        if (!active) return;
        setUser(me);
        setStatus('authenticated');
      } catch {
        if (!active) return;
        setUser(null);
        setStatus('unauthenticated');
      }
    };

    void bootstrapAuth();

    return () => {
      active = false;
    };
  }, []);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
