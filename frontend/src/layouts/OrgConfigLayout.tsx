import { Outlet, useLoaderData, useRevalidator } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { createMuiThemeForOrganization } from '../app/organization/theme';
import { LocaleProvider } from '../app/locale/LocaleProvider';
import { organizationClient } from '../app/organization/organizationClient';
import type { OrganizationConfig } from '../app/organization/types';

export function OrgConfigLayout() {
  const { orgConfig, locale } = useLoaderData() as { orgConfig: OrganizationConfig; locale: string };
  const { revalidate } = useRevalidator();

  const theme = createMuiThemeForOrganization(orgConfig);

  const handleAfterLocaleChange = () => {
    organizationClient.clearCache();
    revalidate();
  };

  return (
    <LocaleProvider initialLocale={locale} onAfterChange={handleAfterLocaleChange}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Outlet />
      </ThemeProvider>
    </LocaleProvider>
  );
}
