import React from 'react';
import type { Organization } from './types';

export const OrganizationContext = React.createContext<Organization | null>(null);

export function useOrganization() {
  const organization = React.useContext(OrganizationContext);
  if (!organization) throw new Error('OrganizationContext not set');
  return organization;
}
