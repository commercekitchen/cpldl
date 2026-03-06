import { createContext, useContext } from 'react';

type LocaleContextValue = {
  locale: string;
  setLocale: (locale: string) => Promise<void>;
};

export const LocaleContext = createContext<LocaleContextValue | null>(null);

export function useLocale(): LocaleContextValue {
  const ctx = useContext(LocaleContext);
  if (!ctx) throw new Error('useLocale must be used within LocaleProvider');
  return ctx;
}
