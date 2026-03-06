import React, { useCallback, useState } from 'react';
import { updateLocale } from './localeApi';
import { LocaleContext } from './LocaleContext';

export function LocaleProvider({
  initialLocale,
  children,
}: {
  initialLocale: string;
  children: React.ReactNode;
}) {
  const [locale, setLocaleState] = useState(initialLocale);

  const setLocale = useCallback(async (next: string) => {
    const confirmed = await updateLocale(next);
    setLocaleState(confirmed);
  }, []);

  return <LocaleContext.Provider value={{ locale, setLocale }}>{children}</LocaleContext.Provider>;
}
