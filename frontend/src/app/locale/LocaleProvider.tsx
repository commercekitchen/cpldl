import React, { useCallback, useEffect, useState } from 'react';
import { updateLocale } from './localeApi';
import { LocaleContext } from './LocaleContext';
import i18n from '../i18n/i18n';

export function LocaleProvider({
  initialLocale,
  onAfterChange,
  children,
}: {
  initialLocale: string;
  onAfterChange?: () => void;
  children: React.ReactNode;
}) {
  const [locale, setLocaleState] = useState(initialLocale);

  useEffect(() => {
    void i18n.changeLanguage(initialLocale);
  }, [initialLocale]);

  const setLocale = useCallback(async (next: string) => {
    const confirmed = await updateLocale(next);
    setLocaleState(confirmed);
    await i18n.changeLanguage(confirmed);
    onAfterChange?.();
  }, [onAfterChange]);

  return <LocaleContext.Provider value={{ locale, setLocale }}>{children}</LocaleContext.Provider>;
}
