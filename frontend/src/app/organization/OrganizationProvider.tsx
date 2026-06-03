import React from 'react';
import { resolveOrganizationFromSubdomain } from './resolveOrganizationFromSubdomain';
import { OrganizationContext } from './OrganizationContext';

export function OrganizationProvider({ children }: { children: React.ReactNode }) {
  const organization = React.useMemo(
    () => resolveOrganizationFromSubdomain(window.location.hostname),
    [],
  );
  return (
    <OrganizationContext.Provider value={organization}>{children}</OrganizationContext.Provider>
  );
}
