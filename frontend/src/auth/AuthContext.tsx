import React, { createContext, useContext, useMemo, useState } from "react";
import { apiFetch } from "../app/api/apiFetch";

type AuthStatus = "loading" | "authenticated" | "unauthenticated";

type User = {
  id: number;
  email: string;
};

type AuthContextValue = {
  status: AuthStatus;
  user: User | null;
  refresh: () => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

async function apiJson(path: string, init: RequestInit = {}) {
  const res = await apiFetch(path, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });

  const isJson = (res.headers.get("content-type") || "").includes("application/json");
  const body = isJson ? await res.json().catch(() => null) : null;

  if (!res.ok) {
    const message = body?.error || body?.message || `Request failed: ${res.status}`;
    throw new Error(message);
  }

  return body;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>("unauthenticated");
  const [user, setUser] = useState<User | null>(null);

  const refresh = async () => {
    setStatus("loading");
    try {
      const me = await apiJson("/api/v1/me", { method: "GET" });
      setUser(me);
      setStatus("authenticated");
    } catch {
      setUser(null);
      setStatus("unauthenticated");
    }
  };

  const login = async (email: string, password: string) => {
    // Adjust endpoint/payload to match your Rails auth implementation.
    await apiJson("/api/v1/session", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
    await refresh();
  };

  const logout = async () => {
    await apiJson("/api/v1/session", { method: "DELETE" });
    setUser(null);
    setStatus("unauthenticated");
  };

  const value = useMemo<AuthContextValue>(
    () => ({ status, user, refresh, login, logout }),
    [status, user]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
