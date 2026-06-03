import { apiFetch } from '../api/apiFetch';

export async function fetchLocale(): Promise<string> {
  const res = await apiFetch('/api/v1/locale');
  if (!res.ok) return 'en';
  const data = (await res.json()) as { locale: string };
  return data.locale ?? 'en';
}

export async function updateLocale(locale: string): Promise<string> {
  const res = await apiFetch('/api/v1/locale', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ locale }),
  });
  if (!res.ok) return locale;
  const data = (await res.json()) as { locale: string };
  return data.locale ?? locale;
}
