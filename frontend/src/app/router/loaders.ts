import { organizationClient } from '../organization/organizationClient';
import { fetchLocale } from '../locale/localeApi';

export async function rootLoader() {
  const [orgConfig, locale] = await Promise.all([
    organizationClient.getConfig(),
    fetchLocale(),
  ]);
  return { orgConfig, locale };
}
