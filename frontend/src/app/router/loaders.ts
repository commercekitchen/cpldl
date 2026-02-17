import { organizationClient } from '../organization/organizationClient';

export async function rootLoader() {
  const orgConfig = await organizationClient.getConfig();
  return { orgConfig };
}
