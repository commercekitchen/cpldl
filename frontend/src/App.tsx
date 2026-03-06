import { RouterProvider } from 'react-router-dom';
import { OrganizationProvider } from './app/organization/OrganizationProvider';
import { createAppRouter } from './app/router/router';
import { AuthProvider } from './auth/AuthContext';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './app/queryClient';
import { I18nextProvider } from 'react-i18next';
import i18n from './app/i18n/i18n';

function App() {
  const router = createAppRouter();

  return (
    <I18nextProvider i18n={i18n}>
      <QueryClientProvider client={queryClient}>
        <OrganizationProvider>
          <AuthProvider>
            <RouterProvider router={router} />
          </AuthProvider>
        </OrganizationProvider>
      </QueryClientProvider>
    </I18nextProvider>
  );
}

export default App;
